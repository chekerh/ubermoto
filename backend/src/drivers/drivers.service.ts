import {
  Injectable,
  NotFoundException,
  ConflictException,
  BadRequestException,
  ForbiddenException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Driver, DriverDocument } from './schemas/driver.schema';
import { Payout, PayoutDocument, PayoutStatus } from './schemas/payout.schema';
import { Delivery, DeliveryDocument, DeliveryStatus } from '../deliveries/schemas/delivery.schema';
import { UsersService } from '../users/users.service';
import { UserRole } from '../users/schemas/user.schema';
import { UploadDocumentsDto, UpdateDriverDocumentsDto } from './dto/upload-documents.dto';
import { UpdateDriverScheduleDto } from './dto/update-driver-schedule.dto';
import { DeliveryGateway } from '../websocket/delivery.gateway';

export interface CreateDriverDto {
  userId: string;
  licenseNumber: string;
  phoneNumber: string;
  motorcycleId?: string;
}

@Injectable()
export class DriversService {
  constructor(
    @InjectModel(Driver.name) private driverModel: Model<DriverDocument>,
    @InjectModel(Delivery.name) private deliveryModel: Model<DeliveryDocument>,
    @InjectModel(Payout.name) private payoutModel: Model<PayoutDocument>,
    private readonly usersService: UsersService,
    private readonly deliveryGateway: DeliveryGateway,
  ) {}

  async create(createDriverDto: CreateDriverDto): Promise<DriverDocument> {
    // Verify user exists and is a driver
    const user = await this.usersService.findById(createDriverDto.userId);
    if (!user) {
      throw new NotFoundException('User not found');
    }

    if (user.role !== UserRole.DRIVER) {
      throw new ConflictException('User is not registered as a driver');
    }

    // Check if driver profile already exists
    const existingDriver = await this.driverModel
      .findOne({ userId: createDriverDto.userId })
      .exec();
    if (existingDriver) {
      throw new ConflictException('Driver profile already exists for this user');
    }

    const driver = new this.driverModel({
      userId: createDriverDto.userId,
      licenseNumber: createDriverDto.licenseNumber,
      phoneNumber: createDriverDto.phoneNumber,
      motorcycleId: createDriverDto.motorcycleId,
    });

    return driver.save();
  }

  async findAll(): Promise<DriverDocument[]> {
    return this.driverModel.find().populate('userId').populate('motorcycleId').exec();
  }

  async findOne(id: string): Promise<DriverDocument> {
    const driver = await this.driverModel
      .findById(id)
      .populate('userId')
      .populate('motorcycleId')
      .exec();
    if (!driver) {
      throw new NotFoundException(`Driver with ID ${id} not found`);
    }
    return driver;
  }

  async findByUserId(userId: string): Promise<DriverDocument | null> {
    return this.driverModel.findOne({ userId }).populate('userId').populate('motorcycleId').exec();
  }

  /** User id string backing this driver profile (handles populated `userId`). */
  getOwnerUserIdString(driver: DriverDocument): string {
    const u = driver.userId as unknown as { _id?: { toString(): string }; toString(): string };
    if (!u) {
      return '';
    }
    return u._id ? u._id.toString() : u.toString();
  }

  async assertAdminOrSelfDriverRecord(
    driverMongoId: string,
    requesterSub: string,
    role: UserRole,
  ): Promise<DriverDocument> {
    const driver = await this.findOne(driverMongoId);
    if (role === UserRole.ADMIN) {
      return driver;
    }
    if (role !== UserRole.DRIVER) {
      throw new ForbiddenException('Only drivers and admins can access this resource');
    }
    if (this.getOwnerUserIdString(driver) !== requesterSub) {
      throw new ForbiddenException('You can only access your own driver profile');
    }
    return driver;
  }

  async assertAdminOrMatchingUser(
    targetUserId: string,
    requesterSub: string,
    role: UserRole,
  ): Promise<void> {
    if (role === UserRole.ADMIN) {
      return;
    }
    if (targetUserId !== requesterSub) {
      throw new ForbiddenException('Forbidden');
    }
  }

  async updateMotorcycle(id: string, motorcycleId: string): Promise<DriverDocument> {
    const driver = await this.driverModel
      .findByIdAndUpdate(id, { motorcycleId }, { new: true })
      .populate('userId')
      .populate('motorcycleId')
      .exec();

    if (!driver) {
      throw new NotFoundException(`Driver with ID ${id} not found`);
    }

    return driver;
  }

  async incrementDeliveryCount(id: string): Promise<DriverDocument> {
    const driver = await this.driverModel
      .findByIdAndUpdate(id, { $inc: { totalDeliveries: 1 } }, { new: true })
      .populate('userId')
      .populate('motorcycleId')
      .exec();

    if (!driver) {
      throw new NotFoundException(`Driver with ID ${id} not found`);
    }

    return driver;
  }

  async updateRating(id: string, rating: number): Promise<DriverDocument> {
    const driver = await this.driverModel
      .findByIdAndUpdate(id, { rating }, { new: true })
      .populate('userId')
      .populate('motorcycleId')
      .exec();

    if (!driver) {
      throw new NotFoundException(`Driver with ID ${id} not found`);
    }

    return driver;
  }

  async uploadDocuments(
    id: string,
    uploadDocumentsDto: UploadDocumentsDto,
  ): Promise<DriverDocument> {
    const driver = await this.driverModel
      .findByIdAndUpdate(id, uploadDocumentsDto, { new: true })
      .populate('userId')
      .populate('motorcycleId')
      .exec();

    if (!driver) {
      throw new NotFoundException(`Driver with ID ${id} not found`);
    }

    return driver;
  }

  async updateDocuments(
    id: string,
    updateDocumentsDto: UpdateDriverDocumentsDto,
  ): Promise<DriverDocument> {
    const driver = await this.driverModel
      .findByIdAndUpdate(id, updateDocumentsDto, { new: true })
      .populate('userId')
      .populate('motorcycleId')
      .exec();

    if (!driver) {
      throw new NotFoundException(`Driver with ID ${id} not found`);
    }

    return driver;
  }

  async updateVerificationStatus(id: string, isVerified: boolean): Promise<DriverDocument> {
    const driver = await this.driverModel
      .findByIdAndUpdate(id, { isVerified }, { new: true })
      .populate('userId')
      .populate('motorcycleId')
      .exec();

    if (!driver) {
      throw new NotFoundException(`Driver with ID ${id} not found`);
    }

    return driver;
  }

  async updateAvailability(id: string, isAvailable: boolean): Promise<DriverDocument> {
    const driver = await this.driverModel
      .findByIdAndUpdate(id, { isAvailable }, { new: true })
      .populate('userId')
      .populate('motorcycleId')
      .exec();

    if (!driver) {
      throw new NotFoundException(`Driver with ID ${id} not found`);
    }

    // Emit real-time availability update
    if (isAvailable) {
      this.deliveryGateway.emitDriverAvailable(id);
    } else {
      this.deliveryGateway.emitDriverUnavailable(id);
    }

    return driver;
  }

  // ── Earnings & Performance ──────────────────────────────────────────────

  async getEarnings(driverId: string, period: 'daily' | 'weekly' | 'monthly' = 'monthly') {
    const driver = await this.findOne(driverId);

    const now = new Date();
    let startDate: Date;

    switch (period) {
      case 'daily':
        startDate = new Date(now.setHours(0, 0, 0, 0));
        break;
      case 'weekly':
        startDate = new Date(now.setDate(now.getDate() - 7));
        break;
      case 'monthly':
        startDate = new Date(now.setMonth(now.getMonth() - 1));
        break;
    }

    const completedDeliveries = await this.deliveryModel
      .find({
        driverId: driver._id,
        status: DeliveryStatus.COMPLETED,
        createdAt: { $gte: startDate },
      })
      .exec();

    const totalEarnings = completedDeliveries.reduce(
      (sum, delivery) => sum + (delivery.actualCost || delivery.estimatedCost || 0),
      0,
    );

    const deliveryCount = completedDeliveries.length;
    const averagePerDelivery = deliveryCount > 0 ? totalEarnings / deliveryCount : 0;

    return {
      period,
      totalEarnings: parseFloat(totalEarnings.toFixed(2)),
      deliveryCount,
      averagePerDelivery: parseFloat(averagePerDelivery.toFixed(2)),
      startDate,
      endDate: new Date(),
    };
  }

  async getPerformance(driverId: string) {
    const driver = await this.findOne(driverId);

    const allDeliveries = await this.deliveryModel.find({ driverId: driver._id }).exec();

    const completedDeliveries = allDeliveries.filter((d) => d.status === DeliveryStatus.COMPLETED);

    const totalDeliveries = allDeliveries.length;
    const completedCount = completedDeliveries.length;
    const completionRate = totalDeliveries > 0 ? (completedCount / totalDeliveries) * 100 : 0;

    return {
      totalDeliveries,
      completedDeliveries: completedCount,
      completionRate: parseFloat(completionRate.toFixed(2)),
      averageRating: driver.rating || 0,
      totalEarnings: await this.getTotalEarnings(driverId),
    };
  }

  async getDeliveryHistory(
    driverId: string,
    options: { skip?: number; limit?: number; status?: DeliveryStatus } = {},
  ) {
    const { skip = 0, limit = 20, status } = options;

    const driver = await this.findOne(driverId);

    const query: any = { driverId: driver._id };
    if (status) {
      query.status = status;
    }

    const deliveries = await this.deliveryModel
      .find(query)
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit)
      .populate('userId')
      .populate('motorcycleId')
      .exec();

    const total = await this.deliveryModel.countDocuments(query).exec();

    return {
      deliveries,
      pagination: {
        total,
        skip,
        limit,
        hasMore: skip + limit < total,
      },
    };
  }

  async updateLocation(driverId: string, latitude: number, longitude: number) {
    const driver = await this.driverModel
      .findByIdAndUpdate(
        driverId,
        {
          currentLocation: {
            type: 'Point',
            coordinates: [longitude, latitude],
          },
        },
        { new: true },
      )
      .exec();

    if (!driver) {
      throw new NotFoundException(`Driver with ID ${driverId} not found`);
    }

    // Emit location update via WebSocket
    this.deliveryGateway.server.emit('location:updated', {
      driverId,
      latitude,
      longitude,
      timestamp: new Date(),
    });

    return { success: true, message: 'Location updated successfully' };
  }

  async getLeaderboard(period: 'daily' | 'weekly' | 'monthly' = 'monthly', limit: number = 10) {
    const now = new Date();
    let startDate: Date;

    switch (period) {
      case 'daily':
        startDate = new Date(now.setHours(0, 0, 0, 0));
        break;
      case 'weekly':
        startDate = new Date(now.setDate(now.getDate() - 7));
        break;
      case 'monthly':
        startDate = new Date(now.setMonth(now.getMonth() - 1));
        break;
    }

    const drivers = await this.driverModel.find().populate('userId').exec();

    const leaderboard = await Promise.all(
      drivers.map(async (driver) => {
        const completedDeliveries = await this.deliveryModel
          .find({
            driverId: driver._id,
            status: DeliveryStatus.COMPLETED,
            createdAt: { $gte: startDate },
          })
          .exec();

        const totalEarnings = completedDeliveries.reduce(
          (sum, delivery) => sum + (delivery.actualCost || delivery.estimatedCost || 0),
          0,
        );

        return {
          driverId: driver._id,
          driverName: (driver.userId as any)?.name || 'Unknown',
          totalEarnings: parseFloat(totalEarnings.toFixed(2)),
          deliveryCount: completedDeliveries.length,
          rating: driver.rating || 0,
        };
      }),
    );

    // Sort by earnings and return top N
    return leaderboard.sort((a, b) => b.totalEarnings - a.totalEarnings).slice(0, limit);
  }

  private async getTotalEarnings(driverId: string): Promise<number> {
    const driver = await this.driverModel.findById(driverId).exec();
    if (!driver) return 0;

    const completedDeliveries = await this.deliveryModel
      .find({
        driverId: driver._id,
        status: DeliveryStatus.COMPLETED,
      })
      .exec();

    const total = completedDeliveries.reduce(
      (sum, delivery) => sum + (delivery.actualCost || delivery.estimatedCost || 0),
      0,
    );

    return parseFloat(total.toFixed(2));
  }

  async requestPayout(driverId: string, amount: number, paymentMethod = 'bank_transfer') {
    const driver = await this.findOne(driverId);

    const MINIMUM_PAYOUT = 50; // Minimum payout amount

    if (amount < MINIMUM_PAYOUT) {
      throw new BadRequestException(`Minimum payout amount is ${MINIMUM_PAYOUT} TND`);
    }

    // Check current balance
    const totalEarnings = await this.getTotalEarnings(driverId);
    const completedPayouts = await this.payoutModel
      .find({
        driverId: driver._id,
        status: PayoutStatus.COMPLETED,
      })
      .exec();

    const totalPaidOut = completedPayouts.reduce((sum, payout) => sum + payout.amount, 0);
    const availableBalance = totalEarnings - totalPaidOut;

    if (amount > availableBalance) {
      throw new BadRequestException(
        `Insufficient balance. Available: ${availableBalance.toFixed(2)} TND, Requested: ${amount} TND`,
      );
    }

    // Check for pending payouts
    const pendingPayout = await this.payoutModel
      .findOne({
        driverId: driver._id,
        status: { $in: [PayoutStatus.PENDING, PayoutStatus.PROCESSING] },
      })
      .exec();

    if (pendingPayout) {
      throw new BadRequestException('You already have a pending payout request');
    }

    const payout = new this.payoutModel({
      driverId: driver._id,
      amount,
      paymentMethod,
      requestedAt: new Date(),
      status: PayoutStatus.PENDING,
    });

    await payout.save();

    return {
      success: true,
      message: 'Payout request submitted successfully',
      payout: {
        id: payout._id,
        amount: payout.amount,
        status: payout.status,
        requestedAt: payout.requestedAt,
      },
      availableBalance: availableBalance - amount,
    };
  }

  async getPayoutHistory(driverId: string, options: { skip?: number; limit?: number } = {}) {
    const { skip = 0, limit = 20 } = options;

    const driver = await this.findOne(driverId);

    const payouts = await this.payoutModel
      .find({ driverId: driver._id })
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit)
      .exec();

    const total = await this.payoutModel.countDocuments({ driverId: driver._id }).exec();

    return {
      payouts,
      pagination: {
        total,
        skip,
        limit,
        hasMore: skip + limit < total,
      },
    };
  }

  async getSchedule(driverId: string) {
    const driver = await this.driverModel.findById(driverId).exec();
    if (!driver) {
      throw new NotFoundException(`Driver with ID ${driverId} not found`);
    }

    // Return schedule from driver document (assuming it's stored there)
    // If schedule is not in schema, return default availability
    return {
      driverId: driver._id,
      isAvailable: driver.isAvailable,
      schedule: driver.schedule || {
        monday: { enabled: true, startTime: '08:00', endTime: '20:00' },
        tuesday: { enabled: true, startTime: '08:00', endTime: '20:00' },
        wednesday: { enabled: true, startTime: '08:00', endTime: '20:00' },
        thursday: { enabled: true, startTime: '08:00', endTime: '20:00' },
        friday: { enabled: true, startTime: '08:00', endTime: '20:00' },
        saturday: { enabled: true, startTime: '09:00', endTime: '18:00' },
        sunday: { enabled: false, startTime: null, endTime: null },
      },
      timezone: 'Africa/Tunis',
    };
  }

  async updateSchedule(driverId: string, schedule: UpdateDriverScheduleDto) {
    const driver = await this.driverModel
      .findByIdAndUpdate(driverId, { schedule }, { new: true })
      .exec();

    if (!driver) {
      throw new NotFoundException(`Driver with ID ${driverId} not found`);
    }

    return {
      success: true,
      message: 'Schedule updated successfully',
      schedule: driver.schedule,
    };
  }
}
