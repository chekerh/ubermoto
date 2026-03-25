import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type StripeWebhookEventDocument = StripeWebhookEvent & Document;

@Schema({ timestamps: true })
export class StripeWebhookEvent {
  @Prop({ required: true, unique: true, index: true })
  eventId!: string;

  @Prop({ required: true })
  type!: string;

  @Prop({ required: true })
  livemode!: boolean;

  @Prop({ required: true })
  payloadHash!: string;

  @Prop({ required: true, enum: ['received', 'processed', 'failed'], default: 'received' })
  status!: 'received' | 'processed' | 'failed';

  @Prop()
  error?: string;
}

export const StripeWebhookEventSchema = SchemaFactory.createForClass(StripeWebhookEvent);

