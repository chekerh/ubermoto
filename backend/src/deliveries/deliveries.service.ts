import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Delivery, DeliveryDocument, DeliveryStatus } from './schemas/delivery.schema';
import { CreateDeliveryDto } from './dto/create-delivery.dto';
import { MotorcyclesService } from '../motorcycles/motorcycles.service';
import { CostCalculatorService } from '../core/utils/cost-calculator.service';
import { DeliveryMatchingService } from './delivery-matching.service';
import { DeliveryGateway } from '../websocket/delivery.gateway';

@Injectable()
export class DeliveriesService {
  constructor(
    @InjectModel(Delivery.name)
    private deliveryModel: Model<DeliveryDocument>,
    private motorcyclesService: MotorcyclesService,
    private costCalculatorService: CostCalculatorService,
    private deliveryMatchingService: DeliveryMatchingService,
    private deliveryGateway: DeliveryGateway,
  ) {}

  async create(createDeliveryDto: CreateDeliveryDto, userId: string): Promise<DeliveryDocument> {
    let estimatedCost: number | undefined;
    const distance = createDeliveryDto.distance;

    // If motorcycle is specified, calculate cost based on fuel consumption
    if (createDeliveryDto.motorcycleId && distance) {
      try {
        const motorcycle = await this.motorcyclesService.findOne(createDeliveryDto.motorcycleId);
        estimatedCost = this.costCalculatorService.calculateDeliveryCost({
          distance,
          fuelConsumption: motorcycle.fuelConsumption,
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

  async updateStatus(id: string, status: DeliveryStatus): Promise<DeliveryDocument> {
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

  async calculateCost(deliveryId: string, distance: number, motorcycleId: string): Promise<number> {
    const motorcycle = await this.motorcyclesService.findOne(motorcycleId);
    const cost = this.costCalculatorService.calculateDeliveryCost({
      distance,
      fuelConsumption: motorcycle.fuelConsumption,
    });

    // Update delivery with calculated cost
    await this.deliveryModel.findByIdAndUpdate(deliveryId, {
      distance,
      estimatedCost: cost,
      motorcycleId,
    });

    return cost;
  }

  async acceptDelivery(deliveryId: string, driverId: string): Promise<DeliveryDocument> {
    return this.deliveryMatchingService.assignDeliveryToDriver(deliveryId, driverId);
  }

  async startDelivery(deliveryId: string, driverId: string): Promise<DeliveryDocument> {
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
    driverId: string,
    actualCost?: number,
  ): Promise<DeliveryDocument> {
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

    // Make driver available again and increment delivery count
    await this.deliveryMatchingService.completeDelivery(deliveryId);

    return delivery;
  }

  async getDriverDeliveries(driverId: string): Promise<DeliveryDocument[]> {
    return this.deliveryMatchingService.getDriverDeliveries(driverId);
  }

  async getAvailableDeliveries(): Promise<DeliveryDocument[]> {
    return this.deliveryMatchingService.getAvailableDeliveries();
  }
}
