import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type SubscriptionDocument = Subscription & Document;

export type SubscriptionStatus =
  | 'trialing'
  | 'active'
  | 'past_due'
  | 'canceled'
  | 'incomplete'
  | 'unpaid';

@Schema({ timestamps: true })
export class Subscription {
  @Prop({ required: true, index: true })
  merchantId!: string;

  @Prop({ required: true, unique: true, index: true })
  stripeSubscriptionId!: string;

  @Prop({ required: true, index: true })
  stripeCustomerId!: string;

  @Prop({ required: true })
  planKey!: string;

  @Prop({ required: true, enum: ['trialing', 'active', 'past_due', 'canceled', 'incomplete', 'unpaid'] })
  status!: SubscriptionStatus;

  @Prop()
  currentPeriodStart?: Date;

  @Prop()
  currentPeriodEnd?: Date;

  @Prop({ default: false })
  cancelAtPeriodEnd!: boolean;
}

export const SubscriptionSchema = SchemaFactory.createForClass(Subscription);

