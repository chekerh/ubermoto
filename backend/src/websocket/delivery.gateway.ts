import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  OnGatewayConnection,
  OnGatewayDisconnect,
  MessageBody,
  ConnectedSocket,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { Injectable, Logger } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { UserRole } from '../users/schemas/user.schema';
import { resolveSocketIoCorsOrigin } from './socket-cors.util';
import { Delivery, DeliveryDocument } from '../deliveries/schemas/delivery.schema';
import { Driver, DriverDocument } from '../drivers/schemas/driver.schema';

interface AuthenticatedSocket extends Socket {
  userId?: string;
  userRole?: UserRole;
}

interface SubscribeToDeliveryData {
  deliveryId: string;
}

interface UnsubscribeFromDeliveryData {
  deliveryId: string;
}

interface UpdateLocationData {
  deliveryId: string;
  latitude: number;
  longitude: number;
}

@Injectable()
@WebSocketGateway({
  cors: {
    origin: resolveSocketIoCorsOrigin(),
  },
  namespace: '/delivery',
})
export class DeliveryGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server!: Server;

  private logger: Logger = new Logger('DeliveryGateway');

  constructor(
    private readonly jwtService: JwtService,
    @InjectModel(Delivery.name) private readonly deliveryModel: Model<DeliveryDocument>,
    @InjectModel(Driver.name) private readonly driverModel: Model<DriverDocument>,
  ) {}

  /** Customer (owner), assigned driver, or admin may join `delivery_<id>` room. */
  private async canSubscribeToDelivery(
    deliveryId: string,
    client: AuthenticatedSocket,
  ): Promise<{ ok: true } | { ok: false; error: string }> {
    if (!client.userId || !client.userRole) {
      return { ok: false, error: 'Unauthorized' };
    }
    const delivery = await this.deliveryModel.findById(deliveryId).exec();
    if (!delivery) {
      return { ok: false, error: 'Delivery not found' };
    }
    if (client.userRole === UserRole.ADMIN) {
      return { ok: true };
    }
    if (delivery.userId && delivery.userId.toString() === client.userId) {
      return { ok: true };
    }
    if (client.userRole === UserRole.DRIVER) {
      const driver = await this.driverModel.findOne({ userId: client.userId }).exec();
      if (driver && delivery.driverId && delivery.driverId.toString() === driver._id.toString()) {
        return { ok: true };
      }
    }
    return { ok: false, error: 'Forbidden' };
  }

  async handleConnection(client: AuthenticatedSocket): Promise<void> {
    try {
      const token = client.handshake.auth.token || (client.handshake.query.token as string);

      if (!token) {
        client.disconnect();
        return;
      }

      // Verify JWT token
      const payload = this.jwtService.verify(token);
      client.userId = payload.sub;
      client.userRole = payload.role;

      // Join user-specific room
      client.join(`user_${client.userId}`);

      // Join role-specific room
      client.join(`role_${client.userRole}`);

      this.logger.log(`Client connected: ${client.userId} (${client.userRole})`);
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error(`Connection failed: ${errorMessage}`);
      client.disconnect();
    }
  }

  async handleDisconnect(client: AuthenticatedSocket): Promise<void> {
    this.logger.log(`Client disconnected: ${client.userId}`);
  }

  @SubscribeMessage('subscribeToDelivery')
  async handleSubscribeToDelivery(
    @MessageBody() data: SubscribeToDeliveryData,
    @ConnectedSocket() client: AuthenticatedSocket,
  ): Promise<{ success: boolean; error?: string }> {
    const gate = await this.canSubscribeToDelivery(data.deliveryId, client);
    if (!gate.ok) {
      this.logger.warn(
        `subscribeToDelivery denied user=${client.userId} delivery=${data.deliveryId}: ${gate.error}`,
      );
      return { success: false, error: gate.error };
    }
    client.join(`delivery_${data.deliveryId}`);
    this.logger.log(`User ${client.userId} subscribed to delivery ${data.deliveryId}`);
    return { success: true };
  }

  @SubscribeMessage('unsubscribeFromDelivery')
  async handleUnsubscribeFromDelivery(
    @MessageBody() data: UnsubscribeFromDeliveryData,
    @ConnectedSocket() client: AuthenticatedSocket,
  ): Promise<{ success: boolean }> {
    client.leave(`delivery_${data.deliveryId}`);
    this.logger.log(`User ${client.userId} unsubscribed from delivery ${data.deliveryId}`);
    return { success: true };
  }

  @SubscribeMessage('updateLocation')
  async handleUpdateLocation(
    @MessageBody() data: UpdateLocationData,
    @ConnectedSocket() client: AuthenticatedSocket,
  ): Promise<{ success: boolean } | { error: string }> {
    if (client.userRole !== UserRole.DRIVER || !client.userId) {
      return { error: 'Unauthorized' };
    }

    const delivery = await this.deliveryModel.findById(data.deliveryId).exec();
    if (!delivery) {
      return { error: 'Delivery not found' };
    }
    const driver = await this.driverModel.findOne({ userId: client.userId }).exec();
    if (!driver || !delivery.driverId || delivery.driverId.toString() !== driver._id.toString()) {
      return { error: 'Unauthorized' };
    }

    // Broadcast location update to delivery subscribers
    this.server.to(`delivery_${data.deliveryId}`).emit('location_update', {
      deliveryId: data.deliveryId,
      driverId: client.userId,
      latitude: data.latitude,
      longitude: data.longitude,
      timestamp: new Date().toISOString(),
    });

    return { success: true };
  }

  // Methods called by services to emit events
  emitDeliveryStatusUpdate(deliveryId: string, delivery: any) {
    this.server.to(`delivery_${deliveryId}`).emit('delivery_status_update', {
      deliveryId,
      status: delivery.status,
      driverId: delivery.driverId,
      updatedAt: delivery.updatedAt,
    });

    // Also notify the customer and driver individually (rooms = User `sub`, not Driver doc id)
    if (delivery.userId) {
      this.server.to(`user_${String(delivery.userId)}`).emit('delivery_status_update', {
        deliveryId,
        status: delivery.status,
        driverId: delivery.driverId,
        updatedAt: delivery.updatedAt,
      });
    }

    if (delivery.driverId) {
      const driverDocId = String(delivery.driverId);
      void this.driverModel
        .findById(driverDocId)
        .exec()
        .then((d) => {
          if (d?.userId) {
            this.server.to(`user_${String(d.userId)}`).emit('delivery_status_update', {
              deliveryId,
              status: delivery.status,
              driverId: delivery.driverId,
              updatedAt: delivery.updatedAt,
            });
          }
        });
    }
  }

  emitNewDelivery(delivery: any) {
    // Notify all available drivers
    this.server.to('role_DRIVER').emit('new_delivery', {
      deliveryId: delivery._id,
      pickupLocation: delivery.pickupLocation,
      deliveryAddress: delivery.deliveryAddress,
      deliveryType: delivery.deliveryType,
      estimatedCost: delivery.estimatedCost,
      distance: delivery.distance,
      createdAt: delivery.createdAt,
    });
  }

  emitDeliveryAssigned(deliveryId: string, driverMongoId: string, delivery: any): void {
    // driverMongoId is Driver collection _id; user rooms are keyed by User _id (JWT `sub`).
    void (async () => {
      const driverDoc = await this.driverModel.findById(driverMongoId).exec();
      const driverUserSub = driverDoc?.userId ? String(driverDoc.userId) : null;
      if (driverUserSub) {
        this.server.to(`user_${driverUserSub}`).emit('delivery_assigned', {
          deliveryId,
          delivery: {
            pickupLocation: delivery.pickupLocation,
            deliveryAddress: delivery.deliveryAddress,
            deliveryType: delivery.deliveryType,
            estimatedCost: delivery.estimatedCost,
            distance: delivery.distance,
          },
        });
      }

      if (delivery.userId) {
        this.server.to(`user_${String(delivery.userId)}`).emit('driver_assigned', {
          deliveryId,
          driverId: driverMongoId,
        });
      }
    })();
  }

  emitDriverAvailable(driverId: string) {
    // Notify admins of driver availability change
    this.server.to('role_ADMIN').emit('driver_status_update', {
      driverId,
      status: 'available',
      timestamp: new Date().toISOString(),
    });
  }

  emitDriverUnavailable(driverId: string) {
    // Notify admins of driver availability change
    this.server.to('role_ADMIN').emit('driver_status_update', {
      driverId,
      status: 'unavailable',
      timestamp: new Date().toISOString(),
    });
  }
}
