import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { User, UserDocument, UserRole } from '../users/schemas/user.schema';
import { Driver, DriverDocument } from '../drivers/schemas/driver.schema';
import { Delivery, DeliveryDocument } from '../deliveries/schemas/delivery.schema';
import {
  DocumentEntity,
  DocumentDocument,
  DocumentStatus,
} from '../documents/schemas/document.schema';
import { UsersService } from '../users/users.service';
import { DocumentsService } from '../documents/documents.service';

@Injectable()
export class AdminService {
  constructor(
    @InjectModel(User.name) private userModel: Model<UserDocument>,
    @InjectModel(Driver.name) private driverModel: Model<DriverDocument>,
    @InjectModel(Delivery.name) private deliveryModel: Model<DeliveryDocument>,
    @InjectModel(DocumentEntity.name) private documentModel: Model<DocumentDocument>,
    private readonly usersService: UsersService,
    private readonly documentsService: DocumentsService,
  ) {}

  async getDashboardStats() {
    const [
      totalUsers,
      totalDrivers,
      verifiedDrivers,
      pendingDrivers,
      totalDeliveries,
      completedDeliveries,
      pendingDocuments,
    ] = await Promise.all([
      this.userModel.countDocuments().exec(),
      this.driverModel.countDocuments().exec(),
      this.userModel.countDocuments({ role: UserRole.DRIVER, isVerified: true }).exec(),
      this.userModel.countDocuments({ role: UserRole.DRIVER, isVerified: false }).exec(),
      this.deliveryModel.countDocuments().exec(),
      this.deliveryModel.countDocuments({ status: 'completed' }).exec(),
      this.documentModel.countDocuments({ status: DocumentStatus.PENDING }).exec(),
    ]);

    return {
      users: {
        total: totalUsers,
        customers: totalUsers - totalDrivers,
        drivers: {
          total: totalDrivers,
          verified: verifiedDrivers,
          pending: pendingDrivers,
        },
      },
      deliveries: {
        total: totalDeliveries,
        completed: completedDeliveries,
        pending: totalDeliveries - completedDeliveries,
      },
      documents: {
        pending: pendingDocuments,
      },
    };
  }

  async getPendingDrivers() {
    return this.userModel
      .find({ role: UserRole.DRIVER, isVerified: false })
      .populate({
        path: 'driverProfile',
        model: 'Driver',
      })
      .exec();
  }

  async getPendingDocuments() {
    return this.documentModel
      .find({ status: DocumentStatus.PENDING })
      .populate('userId')
      .sort({ createdAt: -1 })
      .exec();
  }

  async verifyDriver(driverId: string, _adminId: string) {
    // Update driver verification status
    await this.usersService.updateVerificationStatus(driverId, true);

    // TODO: Send notification to driver
    // TODO: Log admin action

    return { message: 'Driver verified successfully' };
  }

  async rejectDriver(driverId: string, _reason: string, _adminId: string) {
    // Update driver verification status to false
    await this.usersService.updateVerificationStatus(driverId, false);

    // TODO: Send rejection notification to driver with reason
    // TODO: Log admin action

    return { message: 'Driver rejected successfully' };
  }

  async updateDocumentStatus(
    documentId: string,
    status: DocumentStatus,
    adminId: string,
    rejectionReason?: string,
  ) {
    return this.documentsService.updateStatus(documentId, status, adminId, rejectionReason);
  }

  async getDeliveryStats() {
    const stats = await this.deliveryModel
      .aggregate([
        {
          $group: {
            _id: '$status',
            count: { $sum: 1 },
            totalCost: { $sum: '$estimatedCost' },
          },
        },
      ])
      .exec();

    const result: Record<string, number> = {
      pending: 0,
      in_progress: 0,
      completed: 0,
      cancelled: 0,
      totalRevenue: 0,
    };

    stats.forEach((stat: any) => {
      const status = stat._id as string;
      if (result.hasOwnProperty(status)) {
        result[status] = stat.count;
      }
      if (status === 'completed') {
        result.totalRevenue = stat.totalCost || 0;
      }
    });

    return result;
  }

  async getUserStats() {
    const [totalUsers, activeUsers, driverStats] = await Promise.all([
      this.userModel.countDocuments().exec(),
      this.userModel
        .countDocuments({ updatedAt: { $gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) } })
        .exec(),
      this.userModel
        .aggregate([
          { $match: { role: UserRole.DRIVER } },
          {
            $group: {
              _id: '$isVerified',
              count: { $sum: 1 },
            },
          },
        ])
        .exec(),
    ]);

    const verifiedDrivers = driverStats.find((stat) => stat._id === true)?.count || 0;
    const unverifiedDrivers = driverStats.find((stat) => stat._id === false)?.count || 0;

    return {
      total: totalUsers,
      active: activeUsers,
      drivers: {
        verified: verifiedDrivers,
        unverified: unverifiedDrivers,
      },
    };
  }
}
