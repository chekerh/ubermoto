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
import { AdminAuditLogService, AdminAuditAction } from './admin-audit-log.service';

@Injectable()
export class AdminService {
  constructor(
    @InjectModel(User.name) private userModel: Model<UserDocument>,
    @InjectModel(Driver.name) private driverModel: Model<DriverDocument>,
    @InjectModel(Delivery.name) private deliveryModel: Model<DeliveryDocument>,
    @InjectModel(DocumentEntity.name) private documentModel: Model<DocumentDocument>,
    private readonly usersService: UsersService,
    private readonly documentsService: DocumentsService,
    private readonly adminAuditLogService: AdminAuditLogService,
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
    // Find unverified driver users
    const pendingUsers = await this.userModel
      .find({ role: UserRole.DRIVER, isVerified: false })
      .select('-password')
      .exec();

    // Attach driver profile data for each user
    const results = await Promise.all(
      pendingUsers.map(async (user) => {
        const driverProfile = await this.driverModel
          .findOne({ userId: user._id })
          .exec();
        return {
          ...user.toObject(),
          driverProfile: driverProfile ? driverProfile.toObject() : null,
        };
      }),
    );

    return results;
  }

  async getPendingDocuments() {
    return this.documentModel
      .find({ status: DocumentStatus.PENDING })
      .populate('userId')
      .sort({ createdAt: -1 })
      .exec();
  }

  async verifyDriver(userId: string, adminId: string) {
    // Verify the user account
    await this.usersService.updateVerificationStatus(userId, true);

    // Also mark the driver profile as verified
    const driver = await this.driverModel.findOne({ userId }).exec();
    if (driver) {
      await this.driverModel.findByIdAndUpdate(driver._id, { isVerified: true }).exec();
    }

    // Log admin action
    await this.adminAuditLogService.create({
      adminId,
      adminRole: UserRole.ADMIN,
      action: AdminAuditAction.DRIVER_VERIFY,
      targetId: userId,
      targetRole: UserRole.DRIVER,
      targetUserId: userId,
    });

    return { message: 'Driver verified successfully' };
  }

  async rejectDriver(userId: string, reason: string, adminId: string) {
    // Update driver verification status to false
    await this.usersService.updateVerificationStatus(userId, false);

    // Log admin action
    await this.adminAuditLogService.create({
      adminId,
      adminRole: UserRole.ADMIN,
      action: AdminAuditAction.DRIVER_REJECT,
      targetId: userId,
      targetRole: UserRole.DRIVER,
      targetUserId: userId,
      reason,
    });

    return { message: 'Driver rejected successfully' };
  }

  async updateDocumentStatus(
    documentId: string,
    status: DocumentStatus,
    adminId: string,
    rejectionReason?: string,
  ) {
    const document = await this.documentsService.updateStatus(
      documentId,
      status,
      adminId,
      rejectionReason,
    );

    // Log admin action
    await this.adminAuditLogService.create({
      adminId,
      adminRole: UserRole.ADMIN,
      action:
        status === DocumentStatus.APPROVED
          ? AdminAuditAction.DOCUMENT_APPROVE
          : AdminAuditAction.DOCUMENT_REJECT,
      targetId: documentId,
      reason: rejectionReason,
    });

    return document;
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
