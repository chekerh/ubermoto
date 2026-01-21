import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Delivery, DeliveryDocument, DeliveryStatus } from './schemas/delivery.schema';
import { Driver, DriverDocument } from '../drivers/schemas/driver.schema';
import { DeliveryGateway } from '../websocket/delivery.gateway';

export interface DriverMatch {
  driver: DriverDocument;
  user: any; // Will be populated by mongoose
  distance?: number;
  estimatedTime?: number;
  score: number;
}

@Injectable()
export class DeliveryMatchingService {
  constructor(
    @InjectModel(Delivery.name) private deliveryModel: Model<DeliveryDocument>,
    @InjectModel(Driver.name) private driverModel: Model<DriverDocument>,
    private readonly deliveryGateway: DeliveryGateway,
  ) {}

  async findAvailableDrivers(deliveryId: string): Promise<DriverMatch[]> {
    const delivery = await this.deliveryModel.findById(deliveryId).exec();
    if (!delivery) {
      throw new NotFoundException('Delivery not found');
    }

    // Find all verified drivers who are available
    const availableDrivers = await this.driverModel
      .find({
        isAvailable: true,
      })
      .populate('userId')
      .exec();

    // Filter to only verified drivers
    const verifiedDrivers = availableDrivers.filter(
      (driver) => (driver.userId as any)?.isVerified === true
    );

    // Calculate match scores for each driver
    const driverMatches: DriverMatch[] = await Promise.all(
      verifiedDrivers.map(async (driver) => {
        const score = await this.calculateMatchScore(driver, delivery);
        return {
          driver,
          user: driver.userId,
          score,
        };
      })
    );

    // Sort by score (highest first)
    return driverMatches.sort((a, b) => b.score - a.score);
  }

  async assignDeliveryToDriver(deliveryId: string, driverId: string): Promise<DeliveryDocument> {
    const delivery = await this.deliveryModel.findById(deliveryId).exec();
    if (!delivery) {
      throw new NotFoundException('Delivery not found');
    }

    const driver = await this.driverModel.findById(driverId).exec();
    if (!driver) {
      throw new NotFoundException('Driver not found');
    }

    // Update delivery with driver assignment
    const updatedDelivery = await this.deliveryModel
      .findByIdAndUpdate(
        deliveryId,
        {
          driverId,
          motorcycleId: driver.motorcycleId,
          status: DeliveryStatus.ACCEPTED,
        },
        { new: true }
      )
      .populate('driverId')
      .populate('motorcycleId')
      .exec();

    if (!updatedDelivery) {
      throw new NotFoundException('Delivery not found');
    }

    // Mark driver as unavailable (busy with delivery)
    await this.driverModel.findByIdAndUpdate(driverId, { isAvailable: false }).exec();

    // Emit WebSocket events
    this.deliveryGateway.emitDeliveryAssigned(deliveryId, driverId, updatedDelivery);
    this.deliveryGateway.emitDeliveryStatusUpdate(deliveryId, updatedDelivery);

    return updatedDelivery;
  }

  async completeDelivery(deliveryId: string): Promise<DeliveryDocument> {
    const delivery = await this.deliveryModel
      .findByIdAndUpdate(
        deliveryId,
        { status: DeliveryStatus.COMPLETED },
        { new: true }
      )
      .populate('driverId')
      .exec();

    if (!delivery) {
      throw new NotFoundException('Delivery not found');
    }

    // Make driver available again and increment delivery count
    if (delivery.driverId) {
      await this.driverModel.findByIdAndUpdate(delivery.driverId, {
        isAvailable: true,
        $inc: { totalDeliveries: 1 },
      }).exec();

      // Emit driver availability update
      this.deliveryGateway.emitDriverAvailable(delivery.driverId.toString());
    }

    // Emit delivery status update
    this.deliveryGateway.emitDeliveryStatusUpdate(deliveryId, delivery);

    return delivery;
  }

  async cancelDelivery(deliveryId: string): Promise<DeliveryDocument> {
    const delivery = await this.deliveryModel
      .findByIdAndUpdate(
        deliveryId,
        { status: DeliveryStatus.CANCELLED },
        { new: true }
      )
      .populate('driverId')
      .exec();

    if (!delivery) {
      throw new NotFoundException('Delivery not found');
    }

    // Make driver available again if they were assigned
    if (delivery.driverId) {
      await this.driverModel.findByIdAndUpdate(delivery.driverId, {
        isAvailable: true,
      }).exec();
    }

    return delivery;
  }

  async getDriverDeliveries(driverId: string): Promise<DeliveryDocument[]> {
    return this.deliveryModel
      .find({
        driverId,
        status: { $in: [DeliveryStatus.ACCEPTED, DeliveryStatus.PICKED_UP] },
      })
      .sort({ createdAt: -1 })
      .exec();
  }

  async getAvailableDeliveries(): Promise<DeliveryDocument[]> {
    return this.deliveryModel
      .find({
        status: DeliveryStatus.PENDING,
        driverId: { $exists: false },
      })
      .populate('userId')
      .sort({ createdAt: 1 })
      .exec();
  }

  private async calculateMatchScore(driver: DriverDocument, _delivery: DeliveryDocument): Promise<number> {
    let score = 0;

    // Base score for available verified driver
    score += 50;

    // Rating bonus (max 20 points)
    score += (driver.rating || 0) * 4;

    // Experience bonus (max 15 points for deliveries completed)
    const experienceBonus = Math.min((driver.totalDeliveries || 0) * 0.5, 15);
    score += experienceBonus;

    // TODO: Add location-based scoring when GPS coordinates are available
    // For now, all drivers get the same location score
    score += 10;

    // TODO: Add time-based preferences (peak hours, etc.)
    // TODO: Add motorcycle type suitability for delivery type

    return Math.round(score);
  }

  async notifyDriversOfNewDelivery(deliveryId: string): Promise<void> {
    const delivery = await this.deliveryModel.findById(deliveryId).exec();
    if (!delivery) {
      return;
    }

    // Emit new delivery event to all drivers via WebSocket
    this.deliveryGateway.emitNewDelivery(delivery);
  }
}