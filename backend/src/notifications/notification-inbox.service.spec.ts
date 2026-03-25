import { Test, TestingModule } from '@nestjs/testing';
import { getModelToken } from '@nestjs/mongoose';
import { NotFoundException } from '@nestjs/common';
import { NotificationInboxService } from './notification-inbox.service';
import { Notification, NotificationType } from './schemas/notification.schema';

describe('NotificationInboxService', () => {
  let service: NotificationInboxService;
  let mockNotificationModel: any;

  const userId = '507f1f77bcf86cd799439011';
  const notifId = '507f1f77bcf86cd799439012';

  const mockNotif = {
    _id: notifId,
    userId,
    title: 'Delivery assigned',
    body: 'Your order is on the way',
    type: NotificationType.DELIVERY_ASSIGNED,
    isRead: false,
  };

  beforeEach(async () => {
    // Constructor mock — supports `new this.notificationModel(data).save()`
    mockNotificationModel = jest.fn().mockImplementation(() => ({
      save: jest.fn().mockResolvedValue(mockNotif),
    }));
    mockNotificationModel.find = jest.fn();
    mockNotificationModel.countDocuments = jest.fn();
    mockNotificationModel.findOneAndUpdate = jest.fn();
    mockNotificationModel.findOneAndDelete = jest.fn();
    mockNotificationModel.updateMany = jest.fn();

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        NotificationInboxService,
        { provide: getModelToken(Notification.name), useValue: mockNotificationModel },
      ],
    }).compile();

    service = module.get<NotificationInboxService>(NotificationInboxService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  // ── createForUser ────────────────────────────────────────────────────────────

  describe('createForUser', () => {
    it('should create and return a notification document', async () => {
      const result = await service.createForUser(
        userId,
        'Delivery assigned',
        'Your order is on the way',
        NotificationType.DELIVERY_ASSIGNED,
      );

      expect(mockNotificationModel).toHaveBeenCalledTimes(1);
      expect(result.title).toBe('Delivery assigned');
      expect(result.isRead).toBe(false);
    });

    it('should default type to SYSTEM when not provided', async () => {
      await service.createForUser(userId, 'Hello', 'Welcome!');

      const constructorArg = mockNotificationModel.mock.calls[0][0];
      expect(constructorArg.type).toBe(NotificationType.SYSTEM);
    });

    it('should set referenceId when provided', async () => {
      const refId = '507f1f77bcf86cd799439020';
      await service.createForUser(
        userId,
        'Delivery done',
        'Your delivery is complete',
        NotificationType.DELIVERY_COMPLETED,
        refId,
        'delivery',
      );

      const constructorArg = mockNotificationModel.mock.calls[0][0];
      expect(constructorArg.referenceType).toBe('delivery');
    });
  });

  // ── findAllForUser ───────────────────────────────────────────────────────────

  describe('findAllForUser', () => {
    it('should return paginated notifications with unread count', async () => {
      mockNotificationModel.find.mockReturnValue({
        sort: jest.fn().mockReturnValue({
          skip: jest.fn().mockReturnValue({
            limit: jest.fn().mockReturnValue({
              exec: jest.fn().mockResolvedValue([mockNotif]),
            }),
          }),
        }),
      });
      mockNotificationModel.countDocuments
        .mockReturnValueOnce({ exec: jest.fn().mockResolvedValue(10) }) // total
        .mockReturnValueOnce({ exec: jest.fn().mockResolvedValue(4) }); // unread

      const result = await service.findAllForUser(userId, 1, 20);

      expect(result.notifications).toHaveLength(1);
      expect(result.meta.total).toBe(10);
      expect(result.meta.unreadCount).toBe(4);
      expect(result.meta.page).toBe(1);
      expect(result.meta.limit).toBe(20);
    });

    it('should calculate correct skip offset for page 2', async () => {
      mockNotificationModel.find.mockReturnValue({
        sort: jest.fn().mockReturnValue({
          skip: jest.fn().mockReturnValue({
            limit: jest.fn().mockReturnValue({
              exec: jest.fn().mockResolvedValue([]),
            }),
          }),
        }),
      });
      mockNotificationModel.countDocuments
        .mockReturnValueOnce({ exec: jest.fn().mockResolvedValue(0) })
        .mockReturnValueOnce({ exec: jest.fn().mockResolvedValue(0) });

      await service.findAllForUser(userId, 2, 10);

      const sortMock = mockNotificationModel.find.mock.results[0].value.sort;
      const skipCall = sortMock.mock.results[0].value.skip;
      expect(skipCall).toHaveBeenCalledWith(10); // (page 2 - 1) * limit 10
    });
  });

  // ── markAsRead ───────────────────────────────────────────────────────────────

  describe('markAsRead', () => {
    it('should throw NotFoundException when notification is not found', async () => {
      mockNotificationModel.findOneAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });

      await expect(service.markAsRead(notifId, userId)).rejects.toThrow(NotFoundException);
    });

    it('should mark the notification as read and return it', async () => {
      const readNotif = { ...mockNotif, isRead: true };
      mockNotificationModel.findOneAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue(readNotif),
      });

      const result = await service.markAsRead(notifId, userId);
      expect(result.isRead).toBe(true);
    });
  });

  // ── markAllAsRead ────────────────────────────────────────────────────────────

  describe('markAllAsRead', () => {
    it('should return the count of updated notifications', async () => {
      mockNotificationModel.updateMany.mockReturnValue({
        exec: jest.fn().mockResolvedValue({ modifiedCount: 3 }),
      });

      const result = await service.markAllAsRead(userId);
      expect(result.updated).toBe(3);
    });

    it('should return zero when all notifications were already read', async () => {
      mockNotificationModel.updateMany.mockReturnValue({
        exec: jest.fn().mockResolvedValue({ modifiedCount: 0 }),
      });

      const result = await service.markAllAsRead(userId);
      expect(result.updated).toBe(0);
    });
  });

  // ── delete ───────────────────────────────────────────────────────────────────

  describe('delete', () => {
    it('should throw NotFoundException when notification is not found', async () => {
      mockNotificationModel.findOneAndDelete.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });

      await expect(service.delete(notifId, userId)).rejects.toThrow(NotFoundException);
    });

    it('should delete the notification and return a success message', async () => {
      mockNotificationModel.findOneAndDelete.mockReturnValue({
        exec: jest.fn().mockResolvedValue(mockNotif),
      });

      const result = await service.delete(notifId, userId);
      expect(result.message).toBe('Notification deleted');
    });
  });
});
