import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import {
  NotificationPreference,
  NotificationPreferenceDocument,
} from './schemas/notification-preference.schema';

@Injectable()
export class NotificationsService {
  constructor(
    @InjectModel(NotificationPreference.name)
    private prefModel: Model<NotificationPreferenceDocument>,
  ) {}

  async getPreferences(userId: string) {
    const pref = await this.prefModel.findOne({ userId }).exec();
    return pref || { userId, categoriesOptIn: [] };
  }

  async updatePreferences(userId: string, categories: string[]) {
    return this.prefModel
      .findOneAndUpdate({ userId }, { categoriesOptIn: categories }, { upsert: true, new: true })
      .exec();
  }
}
