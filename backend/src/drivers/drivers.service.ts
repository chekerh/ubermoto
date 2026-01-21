import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Driver, DriverDocument } from './schemas/driver.schema';
import { UsersService } from '../users/users.service';
import { UserRole } from '../users/schemas/user.schema';

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
    private readonly usersService: UsersService,
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
    const existingDriver = await this.driverModel.findOne({ userId: createDriverDto.userId }).exec();
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
    const driver = await this.driverModel.findById(id).populate('userId').populate('motorcycleId').exec();
    if (!driver) {
      throw new NotFoundException(`Driver with ID ${id} not found`);
    }
    return driver;
  }

  async findByUserId(userId: string): Promise<DriverDocument | null> {
    return this.driverModel.findOne({ userId }).populate('userId').populate('motorcycleId').exec();
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

    return driver;
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
}