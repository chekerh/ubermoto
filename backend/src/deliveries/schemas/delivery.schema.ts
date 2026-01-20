import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type DeliveryDocument = Delivery & Document;

export enum DeliveryStatus {
  PENDING = 'pending',
  IN_PROGRESS = 'in_progress',
  COMPLETED = 'completed',
  CANCELLED = 'cancelled',
}

@Schema({ timestamps: true })
export class Delivery {
  @Prop({ required: true })
  pickupLocation!: string;

  @Prop({ required: true })
  deliveryAddress!: string;

  @Prop({ required: true })
  deliveryType!: string;

  @Prop({
    type: String,
    enum: DeliveryStatus,
    default: DeliveryStatus.PENDING,
  })
  status!: DeliveryStatus;

  @Prop({ type: Types.ObjectId, ref: 'User' })
  userId?: Types.ObjectId;

  @Prop({ type: Types.ObjectId, ref: 'Driver' })
  driverId?: Types.ObjectId;

  @Prop({ type: Types.ObjectId, ref: 'Motorcycle' })
  motorcycleId?: Types.ObjectId;

  @Prop()
  distance?: number; // Distance in kilometers

  @Prop()
  estimatedCost?: number; // Calculated cost based on motorcycle fuel consumption

  @Prop()
  actualCost?: number; // Final cost after delivery completion

  @Prop()
  estimatedTime?: number; // Estimated time in minutes
}

export const DeliverySchema = SchemaFactory.createForClass(Delivery);
