import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export enum NotificationType {
  DELIVERY_ASSIGNED = 'delivery_assigned',
  DELIVERY_PICKED_UP = 'delivery_picked_up',
  DELIVERY_COMPLETED = 'delivery_completed',
  DELIVERY_CANCELLED = 'delivery_cancelled',
  DRIVER_VERIFIED = 'driver_verified',
  DRIVER_REJECTED = 'driver_rejected',
  PROMO_CODE = 'promo_code',
  SYSTEM = 'system',
}

export type NotificationDocument = Notification & Document;

@Schema({ timestamps: true })
export class Notification {
  @Prop({ type: Types.ObjectId, ref: 'User', required: true, index: true })
  userId!: Types.ObjectId;

  @Prop({ required: true })
  title!: string;

  @Prop({ required: true })
  body!: string;

  @Prop({
    type: String,
    enum: NotificationType,
    default: NotificationType.SYSTEM,
  })
  type!: NotificationType;

  @Prop({ default: false })
  isRead!: boolean;

  @Prop({ type: Types.ObjectId })
  referenceId?: Types.ObjectId; // e.g. deliveryId, orderId

  @Prop()
  referenceType?: string; // 'delivery' | 'order' | 'driver'
}

export const NotificationSchema = SchemaFactory.createForClass(Notification);
