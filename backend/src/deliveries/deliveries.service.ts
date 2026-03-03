import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Delivery, DeliveryDocument, DeliveryStatus } from './schemas/delivery.schema';
import { CreateDeliveryDto } from './dto/create-delivery.dto';
import { MotorcyclesService } from '../motorcycles/motorcycles.service';
import { CostCalculatorService } from '../core/utils/cost-calculator.service';
import { DeliveryMatchingService } from './delivery-matching.service';
import { DeliveryGateway } from '../websocket/delivery.gateway';
import { SurgeService } from '../surge/surge.service';
import { DriversService } from '../drivers/drivers.service';

@Injectable()
export class DeliveriesService {
  constructor(
    @InjectModel(Delivery.name)
    private deliveryModel: Model<DeliveryDocument>,
    private motorcyclesService: MotorcyclesService,
    private costCalculatorService: CostCalculatorService,
    private deliveryMatchingService: DeliveryMatchingService,
    private deliveryGateway: DeliveryGateway,
    private surgeService: SurgeService,
    private driversService: DriversService,
  ) {}

  async create(createDeliveryDto: CreateDeliveryDto, userId: string): Promise<DeliveryDocument> {
    let estimatedCost: number | undefined;
    const distance = createDeliveryDto.distance;

    // If motorcycle is specified, calculate cost based on fuel consumption
    let surgeMultiplier = 1;
    if (createDeliveryDto.motorcycleId && distance) {
      try {
        const motorcycle = await this.motorcyclesService.findOne(createDeliveryDto.motorcycleId);
        if (createDeliveryDto.region) {
          surgeMultiplier = await this.surgeService.getMultiplierFor(
            createDeliveryDto.region,
            new Date(),
          );
        }
        estimatedCost = this.costCalculatorService.calculateDeliveryCost({
          distance,
          fuelConsumption: motorcycle.fuelConsumption,
          timeMultiplier: surgeMultiplier,
        });
      } catch (error) {
        // If motorcycle not found, continue without cost calculation
        console.warn('Motorcycle not found for cost calculation:', error);
      }
    }

    const delivery = new this.deliveryModel({
      ...createDeliveryDto,
      userId: new Types.ObjectId(userId),
      motorcycleId: createDeliveryDto.motorcycleId
        ? new Types.ObjectId(createDeliveryDto.motorcycleId)
        : undefined,
      distance,
      estimatedCost,
      surgeMultiplier,
      status: DeliveryStatus.PENDING,
    });

    const savedDelivery = await delivery.save();

    // Notify available drivers of new delivery
    setImmediate(() => {
      this.deliveryMatchingService.notifyDriversOfNewDelivery(savedDelivery._id.toString());
    });

    return savedDelivery;
  }

  async findAll(userId?: string): Promise<DeliveryDocument[]> {
    const query = userId ? { userId: new Types.ObjectId(userId) } : {};
    return this.deliveryModel.find(query).populate('motorcycleId').exec();
  }

  async findOne(id: string): Promise<DeliveryDocument> {
    const delivery = await this.deliveryModel.findById(id).populate('motorcycleId').exec();
    if (!delivery) {
      throw new NotFoundException(`Delivery with ID ${id} not found`);
    }
    return delivery;
  }

  private static readonly VALID_TRANSITIONS: Record<string, DeliveryStatus[]> = {
    [DeliveryStatus.PENDING]: [DeliveryStatus.ACCEPTED, DeliveryStatus.CANCELLED],
    [DeliveryStatus.ACCEPTED]: [DeliveryStatus.PICKED_UP, DeliveryStatus.CANCELLED],
    [DeliveryStatus.PICKED_UP]: [DeliveryStatus.IN_PROGRESS, DeliveryStatus.COMPLETED, DeliveryStatus.CANCELLED],
    [DeliveryStatus.IN_PROGRESS]: [DeliveryStatus.COMPLETED, DeliveryStatus.CANCELLED],
    [DeliveryStatus.COMPLETED]: [],
    [DeliveryStatus.CANCELLED]: [],
  };

  private validateStatusTransition(currentStatus: DeliveryStatus, newStatus: DeliveryStatus): void {
    const allowedTransitions = DeliveriesService.VALID_TRANSITIONS[currentStatus] || [];
    if (!allowedTransitions.includes(newStatus)) {
      throw new BadRequestException(
        `Cannot transition from '${currentStatus}' to '${newStatus}'. Allowed: ${allowedTransitions.join(', ') || 'none'}`,
      );
    }
  }

  async updateStatus(id: string, status: DeliveryStatus): Promise<DeliveryDocument> {
    const existing = await this.deliveryModel.findById(id).exec();
    if (!existing) {
      throw new NotFoundException(`Delivery with ID ${id} not found`);
    }

    this.validateStatusTransition(existing.status, status);

    const delivery = await this.deliveryModel
      .findByIdAndUpdate(id, { status }, { new: true })
      .populate('motorcycleId')
      .exec();
    if (!delivery) {
      throw new NotFoundException(`Delivery with ID ${id} not found`);
    }

    // Emit real-time status update
    this.deliveryGateway.emitDeliveryStatusUpdate(id, delivery);

    return delivery;
  }

  async calculateCost(
    deliveryId: string,
    distance: number,
    motorcycleId: string,
    region?: string,
  ): Promise<number> {
    const motorcycle = await this.motorcyclesService.findOne(motorcycleId);
    let surgeMultiplier = 1;
    if (region) {
      surgeMultiplier = await this.surgeService.getMultiplierFor(region, new Date());
    }
    const cost = this.costCalculatorService.calculateDeliveryCost({
      distance,
      fuelConsumption: motorcycle.fuelConsumption,
      timeMultiplier: surgeMultiplier,
    });

    // Update delivery with calculated cost
    await this.deliveryModel.findByIdAndUpdate(deliveryId, {
      distance,
      estimatedCost: cost,
      motorcycleId,
      surgeMultiplier,
      region,
    });

    return cost;
  }

  /**
   * Resolve a userId to a Driver document ID.
   * The controller passes req.user.sub (userId), but the delivery schema
   * stores driverId as a reference to the Driver collection.
   */
  private async resolveDriverId(userId: string): Promise<string> {
    const driver = await this.driversService.findByUserId(userId);
    if (!driver) {
      throw new NotFoundException('Driver profile not found for this user');
    }
    return driver._id.toString();
  }

  async acceptDelivery(deliveryId: string, userId: string): Promise<DeliveryDocument> {
    const driverId = await this.resolveDriverId(userId);
    return this.deliveryMatchingService.assignDeliveryToDriver(deliveryId, driverId);
  }

  async startDelivery(deliveryId: string, userId: string): Promise<DeliveryDocument> {
    const driverId = await this.resolveDriverId(userId);
    const delivery = await this.deliveryModel
      .findOneAndUpdate(
        { _id: deliveryId, driverId, status: DeliveryStatus.ACCEPTED },
        { status: DeliveryStatus.PICKED_UP },
        { new: true },
      )
      .populate('driverId')
      .populate('motorcycleId')
      .exec();

    if (!delivery) {
      throw new NotFoundException('Delivery not found or not in accepted status');
    }

    // Emit real-time status update
    this.deliveryGateway.emitDeliveryStatusUpdate(deliveryId, delivery);

    return delivery;
  }

  async completeDelivery(
    deliveryId: string,
    userId: string,
    actualCost?: number,
  ): Promise<DeliveryDocument> {
    const driverId = await this.resolveDriverId(userId);
    const updateData: any = { status: DeliveryStatus.COMPLETED };
    if (actualCost !== undefined) {
      updateData.actualCost = actualCost;
    }

    const delivery = await this.deliveryModel
      .findOneAndUpdate({ _id: deliveryId, driverId }, updateData, { new: true })
      .populate('driverId')
      .populate('motorcycleId')
      .exec();

    if (!delivery) {
      throw new NotFoundException('Delivery not found');
    }

    // Emit real-time status update before making driver available
    this.deliveryGateway.emitDeliveryStatusUpdate(deliveryId, delivery);

    // Make driver available again and increment delivery count (without re-setting status)
    if (delivery.driverId) {
      await this.deliveryMatchingService.makeDriverAvailableAfterDelivery(delivery.driverId.toString());
    }

    return delivery;
  }

  async getDriverDeliveries(userId: string): Promise<DeliveryDocument[]> {
    const driverId = await this.resolveDriverId(userId);
    return this.deliveryMatchingService.getDriverDeliveries(driverId);
  }

  async getAvailableDeliveries(): Promise<DeliveryDocument[]> {
    return this.deliveryMatchingService.getAvailableDeliveries();
  }

  async cancelDelivery(deliveryId: string, userId: string): Promise<DeliveryDocument> {
    const delivery = await this.deliveryModel.findById(deliveryId).exec();
    if (!delivery) {
      throw new NotFoundException('Delivery not found');
    }

    // Only the customer who created the delivery or the assigned driver can cancel
    const isOwner = delivery.userId?.toString() === userId;
    let isDriver = false;
    if (delivery.driverId) {
      try {
        const driverId = await this.resolveDriverId(userId);
        isDriver = delivery.driverId.toString() === driverId;
      } catch (_) {
        // User is not a driver — that's fine
      }
    }
    if (!isOwner && !isDriver) {
      throw new BadRequestException('You are not authorized to cancel this delivery');
    }

    this.validateStatusTransition(delivery.status, DeliveryStatus.CANCELLED);

    const cancelled = await this.deliveryModel
      .findByIdAndUpdate(deliveryId, { status: DeliveryStatus.CANCELLED }, { new: true })
      .populate('driverId')
      .populate('motorcycleId')
      .exec();

    if (!cancelled) {
      throw new NotFoundException('Delivery not found');
    }

    // Free up the driver if one was assigned
    if (cancelled.driverId) {
      await this.deliveryMatchingService.makeDriverAvailableAfterDelivery(cancelled.driverId.toString());
    }

    this.deliveryGateway.emitDeliveryStatusUpdate(deliveryId, cancelled);

    return cancelled;
  }
}
