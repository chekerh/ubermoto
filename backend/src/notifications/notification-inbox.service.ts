import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import {
  Notification,
  NotificationDocument,
  NotificationType,
} from './schemas/notification.schema';

@Injectable()
export class NotificationInboxService {
  constructor(
    @InjectModel(Notification.name)
    private notificationModel: Model<NotificationDocument>,
  ) {}

  async createForUser(
    userId: string,
    title: string,
    body: string,
    type: NotificationType = NotificationType.SYSTEM,
    referenceId?: string,
    referenceType?: string,
  ): Promise<NotificationDocument> {
    const notification = new this.notificationModel({
      userId: new Types.ObjectId(userId),
      title,
      body,
      type,
      referenceId: referenceId ? new Types.ObjectId(referenceId) : undefined,
      referenceType,
    });
    return notification.save();
  }

  async findAllForUser(userId: string, page = 1, limit = 20) {
    const skip = (page - 1) * limit;
    const [notifications, total] = await Promise.all([
      this.notificationModel
        .find({ userId: new Types.ObjectId(userId) })
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .exec(),
      this.notificationModel.countDocuments({ userId: new Types.ObjectId(userId) }).exec(),
    ]);

    const unreadCount = await this.notificationModel
      .countDocuments({ userId: new Types.ObjectId(userId), isRead: false })
      .exec();

    return {
      notifications,
      meta: { total, page, limit, unreadCount },
    };
  }

  async markAsRead(notificationId: string, userId: string) {
    const notification = await this.notificationModel
      .findOneAndUpdate(
        { _id: new Types.ObjectId(notificationId), userId: new Types.ObjectId(userId) },
        { isRead: true },
        { new: true },
      )
      .exec();

    if (!notification) {
      throw new NotFoundException('Notification not found');
    }

    return notification;
  }

  async markAllAsRead(userId: string) {
    const result = await this.notificationModel
      .updateMany({ userId: new Types.ObjectId(userId), isRead: false }, { isRead: true })
      .exec();
    return { updated: result.modifiedCount };
  }

  async delete(notificationId: string, userId: string) {
    const notification = await this.notificationModel
      .findOneAndDelete({
        _id: new Types.ObjectId(notificationId),
        userId: new Types.ObjectId(userId),
      })
      .exec();

    if (!notification) {
      throw new NotFoundException('Notification not found');
    }

    return { message: 'Notification deleted' };
  }
}
