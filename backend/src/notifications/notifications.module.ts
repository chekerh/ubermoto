import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { NotificationsController } from './notifications.controller';
import { NotificationsService } from './notifications.service';
import {
  NotificationPreference,
  NotificationPreferenceSchema,
} from './schemas/notification-preference.schema';
import { Notification, NotificationSchema } from './schemas/notification.schema';
import { NotificationInboxService } from './notification-inbox.service';
import { NotificationInboxController } from './notification-inbox.controller';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: NotificationPreference.name, schema: NotificationPreferenceSchema },
      { name: Notification.name, schema: NotificationSchema },
    ]),
  ],
  controllers: [NotificationsController, NotificationInboxController],
  providers: [NotificationsService, NotificationInboxService],
  exports: [NotificationsService, NotificationInboxService],
})
export class NotificationsModule {}
