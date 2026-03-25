import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type FeedbackDocument = Feedback & Document;

export enum FeedbackType {
  APP = 'app',
  DRIVER = 'driver',
  DELIVERY = 'delivery',
  PLATFORM = 'platform',
}

@Schema({ timestamps: true })
export class Feedback {
  @Prop({ type: Types.ObjectId, ref: 'User', required: true })
  userId!: Types.ObjectId;

  @Prop({ required: true })
  message!: string;

  @Prop({
    type: String,
    enum: FeedbackType,
    default: FeedbackType.APP,
  })
  type!: FeedbackType;

  @Prop({ min: 1, max: 5 })
  rating?: number;

  @Prop({ type: Types.ObjectId })
  referenceId?: Types.ObjectId;

  @Prop()
  referenceType?: string;
}

export const FeedbackSchema = SchemaFactory.createForClass(Feedback);
