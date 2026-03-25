import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { User, UserDocument, UserRole } from '../users/schemas/user.schema';
import { Driver, DriverDocument } from '../drivers/schemas/driver.schema';
import { Delivery, DeliveryDocument, DeliveryStatus } from '../deliveries/schemas/delivery.schema';
import {
  DocumentEntity,
  DocumentDocument,
  DocumentStatus,
} from '../documents/schemas/document.schema';
import { UsersService } from '../users/users.service';
import { DocumentsService } from '../documents/documents.service';
import { AdminAuditLogService, AdminAuditAction } from './admin-audit-log.service';
import { AdminAuditLog, AdminAuditLogDocument } from './schemas/admin-audit-log.schema';

@Injectable()
export class AdminService {
  constructor(
    @InjectModel(User.name) private userModel: Model<UserDocument>,
    @InjectModel(Driver.name) private driverModel: Model<DriverDocument>,
    @InjectModel(Delivery.name) private deliveryModel: Model<DeliveryDocument>,
    @InjectModel(DocumentEntity.name) private documentModel: Model<DocumentDocument>,
    @InjectModel(AdminAuditLog.name)
    private adminAuditLogModel: Model<AdminAuditLogDocument>,
    private readonly usersService: UsersService,
    private readonly documentsService: DocumentsService,
    private readonly adminAuditLogService: AdminAuditLogService,
  ) {}

  private buildPeriodFormat(period: string) {
    switch (period) {
      case 'weekly':
        return '%Y-W%V';
      case 'monthly':
        return '%Y-%m';
      case 'daily':
      default:
        return '%Y-%m-%d';
    }
  }

  private getConnectionStateLabel(state: number) {
    switch (state) {
      case 1:
        return 'connected';
      case 2:
        return 'connecting';
      case 3:
        return 'disconnecting';
      default:
        return 'disconnected';
    }
  }

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
        const driverProfile = await this.driverModel.findOne({ userId: user._id }).exec();
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

  async getFraudAnalytics() {
    const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);

    const [
      totalDeliveries,
      cancelledDeliveries,
      highSurgeDeliveries,
      unverifiedActiveDrivers,
      suspiciousCustomers,
      suspiciousDrivers,
    ] = await Promise.all([
      this.deliveryModel.countDocuments({ createdAt: { $gte: thirtyDaysAgo } }).exec(),
      this.deliveryModel
        .countDocuments({
          createdAt: { $gte: thirtyDaysAgo },
          status: DeliveryStatus.CANCELLED,
        })
        .exec(),
      this.deliveryModel
        .countDocuments({
          createdAt: { $gte: thirtyDaysAgo },
          surgeMultiplier: { $gte: 2 },
        })
        .exec(),
      this.driverModel.countDocuments({ isVerified: false, isAvailable: true }).exec(),
      this.deliveryModel
        .aggregate([
          {
            $match: {
              createdAt: { $gte: thirtyDaysAgo },
              status: DeliveryStatus.CANCELLED,
              userId: { $ne: null },
            },
          },
          {
            $group: {
              _id: '$userId',
              cancellations: { $sum: 1 },
            },
          },
          {
            $match: {
              cancellations: { $gte: 2 },
            },
          },
          { $sort: { cancellations: -1 } },
          { $limit: 5 },
        ])
        .exec(),
      this.deliveryModel
        .aggregate([
          {
            $match: {
              createdAt: { $gte: thirtyDaysAgo },
              status: DeliveryStatus.CANCELLED,
              driverId: { $ne: null },
            },
          },
          {
            $group: {
              _id: '$driverId',
              cancellations: { $sum: 1 },
            },
          },
          {
            $match: {
              cancellations: { $gte: 2 },
            },
          },
          { $sort: { cancellations: -1 } },
          { $limit: 5 },
        ])
        .exec(),
    ]);

    const cancellationRate = totalDeliveries > 0 ? cancelledDeliveries / totalDeliveries : 0;

    return {
      window: '30d',
      riskScore: Number(
        Math.min(
          100,
          cancellationRate * 100 + highSurgeDeliveries * 2 + unverifiedActiveDrivers * 5,
        ).toFixed(2),
      ),
      summary: {
        totalDeliveries,
        cancelledDeliveries,
        cancellationRate: Number((cancellationRate * 100).toFixed(2)),
        highSurgeDeliveries,
        unverifiedActiveDrivers,
      },
      suspiciousCustomers,
      suspiciousDrivers,
    };
  }

  async getRevenueAnalytics(period = 'daily') {
    const normalizedPeriod = ['daily', 'weekly', 'monthly'].includes(period) ? period : 'daily';
    const format = this.buildPeriodFormat(normalizedPeriod);

    const [periodStats, regionStats] = await Promise.all([
      this.deliveryModel
        .aggregate([
          { $match: { status: DeliveryStatus.COMPLETED } },
          {
            $group: {
              _id: {
                period: {
                  $dateToString: {
                    format,
                    date: '$createdAt',
                  },
                },
              },
              deliveries: { $sum: 1 },
              revenue: {
                $sum: {
                  $add: [
                    { $ifNull: ['$actualCost', '$estimatedCost'] },
                    { $ifNull: ['$tipAmount', 0] },
                  ],
                },
              },
              tips: { $sum: { $ifNull: ['$tipAmount', 0] } },
            },
          },
          { $sort: { '_id.period': 1 } },
        ])
        .exec(),
      this.deliveryModel
        .aggregate([
          { $match: { status: DeliveryStatus.COMPLETED } },
          {
            $group: {
              _id: { $ifNull: ['$region', 'unassigned'] },
              deliveries: { $sum: 1 },
              revenue: {
                $sum: {
                  $add: [
                    { $ifNull: ['$actualCost', '$estimatedCost'] },
                    { $ifNull: ['$tipAmount', 0] },
                  ],
                },
              },
            },
          },
          { $sort: { revenue: -1 } },
        ])
        .exec(),
    ]);

    const totalRevenue = periodStats.reduce((sum, entry) => sum + (entry.revenue || 0), 0);
    const totalTips = periodStats.reduce((sum, entry) => sum + (entry.tips || 0), 0);
    const completedDeliveries = periodStats.reduce(
      (sum, entry) => sum + (entry.deliveries || 0),
      0,
    );

    return {
      period: normalizedPeriod,
      summary: {
        totalRevenue,
        totalTips,
        completedDeliveries,
        averageOrderValue:
          completedDeliveries > 0 ? Number((totalRevenue / completedDeliveries).toFixed(2)) : 0,
      },
      byPeriod: periodStats.map((entry) => ({
        period: entry._id.period,
        deliveries: entry.deliveries,
        revenue: entry.revenue,
        tips: entry.tips,
      })),
      byRegion: regionStats.map((entry) => ({
        region: entry._id,
        deliveries: entry.deliveries,
        revenue: entry.revenue,
      })),
    };
  }

  async getDriverActivity(driverId: string) {
    const isObjectId = Types.ObjectId.isValid(driverId);
    const driver = await this.driverModel
      .findOne(
        isObjectId
          ? {
              $or: [
                { _id: new Types.ObjectId(driverId) },
                { userId: new Types.ObjectId(driverId) },
              ],
            }
          : { userId: driverId },
      )
      .exec();

    if (!driver) {
      throw new NotFoundException('Driver not found');
    }

    const [deliveryBreakdown, recentDeliveries, adminActions] = await Promise.all([
      this.deliveryModel
        .aggregate([
          { $match: { driverId: driver._id } },
          {
            $group: {
              _id: '$status',
              count: { $sum: 1 },
            },
          },
        ])
        .exec(),
      this.deliveryModel
        .find({ driverId: driver._id })
        .sort({ updatedAt: -1 })
        .limit(10)
        .populate('userId', 'name email')
        .exec(),
      this.adminAuditLogModel
        .find({
          $or: [{ targetId: driver._id.toString() }, { targetUserId: driver.userId }],
        })
        .sort({ createdAt: -1 })
        .limit(10)
        .populate('adminId', 'name email')
        .exec(),
    ]);

    const breakdown = deliveryBreakdown.reduce(
      (acc, entry) => {
        acc[entry._id] = entry.count;
        return acc;
      },
      {
        pending: 0,
        accepted: 0,
        picked_up: 0,
        in_progress: 0,
        completed: 0,
        cancelled: 0,
      } as Record<string, number>,
    );

    return {
      driver: {
        id: driver._id,
        userId: driver.userId,
        isAvailable: driver.isAvailable,
        isVerified: driver.isVerified,
        totalDeliveries: driver.totalDeliveries,
        rating: driver.rating,
        createdAt: (driver as any).createdAt,
        updatedAt: (driver as any).updatedAt,
      },
      deliverySummary: breakdown,
      recentDeliveries,
      adminActions,
    };
  }

  async getSystemHealth() {
    const startedAt = new Date(Date.now() - process.uptime() * 1000);
    const memoryUsage = process.memoryUsage();
    const readyState = this.userModel.db.readyState;
    const databaseStatus = this.getConnectionStateLabel(readyState);

    const [pendingDeliveries, activeDeliveries, onlineDrivers, pendingDocuments] =
      await Promise.all([
        this.deliveryModel.countDocuments({ status: DeliveryStatus.PENDING }).exec(),
        this.deliveryModel
          .countDocuments({
            status: {
              $in: [DeliveryStatus.ACCEPTED, DeliveryStatus.PICKED_UP, DeliveryStatus.IN_PROGRESS],
            },
          })
          .exec(),
        this.driverModel.countDocuments({ isAvailable: true }).exec(),
        this.documentModel.countDocuments({ status: DocumentStatus.PENDING }).exec(),
      ]);

    return {
      status: databaseStatus === 'connected' ? 'healthy' : 'degraded',
      timestamp: new Date().toISOString(),
      uptimeSeconds: Number(process.uptime().toFixed(0)),
      startedAt: startedAt.toISOString(),
      database: {
        status: databaseStatus,
        readyState,
        name: this.userModel.db.name,
      },
      queues: {
        pendingDeliveries,
        activeDeliveries,
        pendingDocuments,
      },
      drivers: {
        online: onlineDrivers,
      },
      system: {
        rssMb: Number((memoryUsage.rss / 1024 / 1024).toFixed(2)),
        heapUsedMb: Number((memoryUsage.heapUsed / 1024 / 1024).toFixed(2)),
        heapTotalMb: Number((memoryUsage.heapTotal / 1024 / 1024).toFixed(2)),
      },
    };
  }

  async getDeliveriesReport(period = 'daily') {
    const normalizedPeriod = ['daily', 'weekly', 'monthly'].includes(period) ? period : 'daily';
    const format = this.buildPeriodFormat(normalizedPeriod);

    const report = await this.deliveryModel
      .aggregate([
        {
          $group: {
            _id: {
              period: { $dateToString: { format, date: '$createdAt' } },
              status: '$status',
            },
            count: { $sum: 1 },
            totalRevenue: {
              $sum: {
                $add: [
                  { $ifNull: ['$actualCost', '$estimatedCost'] },
                  { $ifNull: ['$tipAmount', 0] },
                ],
              },
            },
          },
        },
        { $sort: { '_id.period': 1 } },
      ])
      .exec();

    const grouped: Record<string, Record<string, unknown>> = {};
    for (const entry of report) {
      const p = entry._id.period as string;
      const s = entry._id.status as string;
      if (!grouped[p]) grouped[p] = { period: p };
      grouped[p][s] = entry.count;
      if (s === 'completed') grouped[p].revenue = entry.totalRevenue;
    }

    return {
      period: normalizedPeriod,
      rows: Object.values(grouped),
    };
  }

  async getDriversReport(period = 'monthly') {
    const normalizedPeriod = ['daily', 'weekly', 'monthly'].includes(period) ? period : 'monthly';
    const format = this.buildPeriodFormat(normalizedPeriod);

    const [driverStats, earningsByPeriod] = await Promise.all([
      this.driverModel.find().populate('userId', 'name email createdAt').exec(),
      this.deliveryModel
        .aggregate([
          { $match: { status: DeliveryStatus.COMPLETED, driverId: { $ne: null } } },
          {
            $group: {
              _id: {
                driverId: '$driverId',
                period: { $dateToString: { format, date: '$createdAt' } },
              },
              deliveries: { $sum: 1 },
              revenue: {
                $sum: {
                  $add: [
                    { $ifNull: ['$actualCost', '$estimatedCost'] },
                    { $ifNull: ['$tipAmount', 0] },
                  ],
                },
              },
            },
          },
          { $sort: { '_id.period': 1 } },
        ])
        .exec(),
    ]);

    return {
      period: normalizedPeriod,
      totalDrivers: driverStats.length,
      verifiedDrivers: driverStats.filter((d) => d.isVerified).length,
      availableDrivers: driverStats.filter((d) => d.isAvailable).length,
      earningsByPeriod,
    };
  }
}
