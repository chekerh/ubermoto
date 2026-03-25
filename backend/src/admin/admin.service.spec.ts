import { Test, TestingModule } from '@nestjs/testing';
import { getModelToken } from '@nestjs/mongoose';
import { NotFoundException } from '@nestjs/common';
import { AdminService } from './admin.service';
import { User } from '../users/schemas/user.schema';
import { Driver } from '../drivers/schemas/driver.schema';
import { Delivery, DeliveryStatus } from '../deliveries/schemas/delivery.schema';
import { DocumentEntity } from '../documents/schemas/document.schema';
import { AdminAuditLog } from './schemas/admin-audit-log.schema';
import { UsersService } from '../users/users.service';
import { DocumentsService } from '../documents/documents.service';
import { AdminAuditLogService } from './admin-audit-log.service';

describe('AdminService', () => {
  let service: AdminService;
  let mockUserModel: any;
  let mockDriverModel: any;
  let mockDeliveryModel: any;
  let mockDocumentModel: any;
  let mockAdminAuditLogModel: any;

  beforeEach(async () => {
    mockUserModel = {
      countDocuments: jest.fn(),
      aggregate: jest.fn(),
      db: { readyState: 1, name: 'nassib_test' },
    };

    mockDriverModel = {
      countDocuments: jest.fn(),
      findOne: jest.fn(),
    };

    mockDeliveryModel = {
      countDocuments: jest.fn(),
      aggregate: jest.fn(),
      find: jest.fn(),
    };

    mockDocumentModel = {
      countDocuments: jest.fn(),
    };

    mockAdminAuditLogModel = {
      find: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AdminService,
        { provide: getModelToken(User.name), useValue: mockUserModel },
        { provide: getModelToken(Driver.name), useValue: mockDriverModel },
        { provide: getModelToken(Delivery.name), useValue: mockDeliveryModel },
        { provide: getModelToken(DocumentEntity.name), useValue: mockDocumentModel },
        { provide: getModelToken(AdminAuditLog.name), useValue: mockAdminAuditLogModel },
        { provide: UsersService, useValue: { updateVerificationStatus: jest.fn() } },
        { provide: DocumentsService, useValue: { updateStatus: jest.fn() } },
        { provide: AdminAuditLogService, useValue: { create: jest.fn() } },
      ],
    }).compile();

    service = module.get<AdminService>(AdminService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('getFraudAnalytics', () => {
    it('should return fraud summary metrics', async () => {
      mockDeliveryModel.countDocuments
        .mockReturnValueOnce({ exec: jest.fn().mockResolvedValue(20) })
        .mockReturnValueOnce({ exec: jest.fn().mockResolvedValue(5) })
        .mockReturnValueOnce({ exec: jest.fn().mockResolvedValue(3) });
      mockDriverModel.countDocuments.mockReturnValue({ exec: jest.fn().mockResolvedValue(2) });
      mockDeliveryModel.aggregate
        .mockReturnValueOnce({
          exec: jest.fn().mockResolvedValue([{ _id: 'u1', cancellations: 3 }]),
        })
        .mockReturnValueOnce({
          exec: jest.fn().mockResolvedValue([{ _id: 'd1', cancellations: 2 }]),
        });

      const result = await service.getFraudAnalytics();

      expect(result.summary.totalDeliveries).toBe(20);
      expect(result.summary.cancelledDeliveries).toBe(5);
      expect(result.summary.cancellationRate).toBe(25);
      expect(result.suspiciousCustomers).toHaveLength(1);
      expect(result.suspiciousDrivers).toHaveLength(1);
    });
  });

  describe('getRevenueAnalytics', () => {
    it('should return revenue grouped by period and region', async () => {
      mockDeliveryModel.aggregate
        .mockReturnValueOnce({
          exec: jest.fn().mockResolvedValue([
            { _id: { period: '2026-03-16' }, deliveries: 2, revenue: 80, tips: 10 },
            { _id: { period: '2026-03-17' }, deliveries: 1, revenue: 40, tips: 5 },
          ]),
        })
        .mockReturnValueOnce({
          exec: jest.fn().mockResolvedValue([
            { _id: 'tunis', deliveries: 2, revenue: 90 },
            { _id: 'sfax', deliveries: 1, revenue: 30 },
          ]),
        });

      const result = await service.getRevenueAnalytics('daily');

      expect(result.period).toBe('daily');
      expect(result.summary.totalRevenue).toBe(120);
      expect(result.summary.totalTips).toBe(15);
      expect(result.summary.completedDeliveries).toBe(3);
      expect(result.byRegion[0].region).toBe('tunis');
    });
  });

  describe('getDriverActivity', () => {
    it('should throw when the driver is not found', async () => {
      mockDriverModel.findOne.mockReturnValue({ exec: jest.fn().mockResolvedValue(null) });

      await expect(service.getDriverActivity('507f1f77bcf86cd799439011')).rejects.toThrow(
        NotFoundException,
      );
    });

    it('should return driver activity details', async () => {
      const driver = {
        _id: 'driver-object-id',
        userId: 'user-object-id',
        isAvailable: true,
        isVerified: true,
        totalDeliveries: 12,
        rating: 4.8,
        createdAt: new Date('2026-03-01T00:00:00.000Z'),
        updatedAt: new Date('2026-03-16T00:00:00.000Z'),
      };

      mockDriverModel.findOne.mockReturnValue({ exec: jest.fn().mockResolvedValue(driver) });
      mockDeliveryModel.aggregate.mockReturnValue({
        exec: jest.fn().mockResolvedValue([
          { _id: DeliveryStatus.COMPLETED, count: 10 },
          { _id: DeliveryStatus.CANCELLED, count: 2 },
        ]),
      });
      mockDeliveryModel.find.mockReturnValue({
        sort: jest.fn().mockReturnValue({
          limit: jest.fn().mockReturnValue({
            populate: jest.fn().mockReturnValue({
              exec: jest.fn().mockResolvedValue([{ _id: 'delivery-1' }]),
            }),
          }),
        }),
      });
      mockAdminAuditLogModel.find.mockReturnValue({
        sort: jest.fn().mockReturnValue({
          limit: jest.fn().mockReturnValue({
            populate: jest.fn().mockReturnValue({
              exec: jest.fn().mockResolvedValue([{ action: 'DRIVER_VERIFY' }]),
            }),
          }),
        }),
      });

      const result = await service.getDriverActivity('507f1f77bcf86cd799439011');

      expect(result.driver.isVerified).toBe(true);
      expect(result.deliverySummary.completed).toBe(10);
      expect(result.recentDeliveries).toHaveLength(1);
      expect(result.adminActions).toHaveLength(1);
    });
  });

  describe('getSystemHealth', () => {
    it('should return healthy system details', async () => {
      mockDeliveryModel.countDocuments
        .mockReturnValueOnce({ exec: jest.fn().mockResolvedValue(4) })
        .mockReturnValueOnce({ exec: jest.fn().mockResolvedValue(3) });
      mockDriverModel.countDocuments.mockReturnValue({ exec: jest.fn().mockResolvedValue(7) });
      mockDocumentModel.countDocuments.mockReturnValue({ exec: jest.fn().mockResolvedValue(2) });

      const result = await service.getSystemHealth();

      expect(result.status).toBe('healthy');
      expect(result.database.status).toBe('connected');
      expect(result.queues.pendingDeliveries).toBe(4);
      expect(result.drivers.online).toBe(7);
      expect(result.system.heapUsedMb).toBeGreaterThanOrEqual(0);
    });
  });
});
