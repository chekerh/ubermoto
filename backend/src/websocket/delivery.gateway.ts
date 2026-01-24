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
import { UserRole } from '../users/schemas/user.schema';

interface AuthenticatedSocket extends Socket {
  userId?: string;
  userRole?: UserRole;
}

@Injectable()
@WebSocketGateway({
  cors: {
    origin: '*', // Configure for production
  },
  namespace: '/delivery',
})
export class DeliveryGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server!: Server;

  private logger: Logger = new Logger('DeliveryGateway');

  constructor(private readonly jwtService: JwtService) {}

  async handleConnection(client: AuthenticatedSocket) {
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

  handleDisconnect(client: AuthenticatedSocket) {
    this.logger.log(`Client disconnected: ${client.userId}`);
  }

  @SubscribeMessage('subscribe_to_delivery')
  handleSubscribeToDelivery(
    @MessageBody() data: { deliveryId: string },
    @ConnectedSocket() client: AuthenticatedSocket,
  ) {
    client.join(`delivery_${data.deliveryId}`);
    this.logger.log(`User ${client.userId} subscribed to delivery ${data.deliveryId}`);
    return { success: true };
  }

  @SubscribeMessage('unsubscribe_from_delivery')
  handleUnsubscribeFromDelivery(
    @MessageBody() data: { deliveryId: string },
    @ConnectedSocket() client: AuthenticatedSocket,
  ) {
    client.leave(`delivery_${data.deliveryId}`);
    this.logger.log(`User ${client.userId} unsubscribed from delivery ${data.deliveryId}`);
    return { success: true };
  }

  @SubscribeMessage('update_location')
  handleUpdateLocation(
    @MessageBody() data: { deliveryId: string; latitude: number; longitude: number },
    @ConnectedSocket() client: AuthenticatedSocket,
  ) {
    // Only drivers can update location
    if (client.userRole !== UserRole.DRIVER) {
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

    // Also notify the customer and driver individually
    if (delivery.userId) {
      this.server.to(`user_${delivery.userId}`).emit('delivery_status_update', {
        deliveryId,
        status: delivery.status,
        driverId: delivery.driverId,
        updatedAt: delivery.updatedAt,
      });
    }

    if (delivery.driverId) {
      this.server.to(`user_${delivery.driverId}`).emit('delivery_status_update', {
        deliveryId,
        status: delivery.status,
        driverId: delivery.driverId,
        updatedAt: delivery.updatedAt,
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

  emitDeliveryAssigned(deliveryId: string, driverId: string, delivery: any) {
    // Notify the assigned driver
    this.server.to(`user_${driverId}`).emit('delivery_assigned', {
      deliveryId,
      delivery: {
        pickupLocation: delivery.pickupLocation,
        deliveryAddress: delivery.deliveryAddress,
        deliveryType: delivery.deliveryType,
        estimatedCost: delivery.estimatedCost,
        distance: delivery.distance,
      },
    });

    // Notify the customer
    this.server.to(`user_${delivery.userId}`).emit('driver_assigned', {
      deliveryId,
      driverId,
    });
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
