import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type PlanDocument = Plan & Document;

@Schema({ timestamps: true })
export class Plan {
  @Prop({ required: true, unique: true, index: true })
  key!: string;

  @Prop({ required: true })
  name!: string;

  @Prop({ required: true })
  description!: string;

  @Prop({ required: true })
  stripePriceId!: string;

  @Prop({ type: Object, default: {} })
  features!: Record<string, boolean>;

  @Prop({ type: Object, default: {} })
  limits!: Record<string, number>;

  @Prop({ default: true })
  isActive!: boolean;
}

export const PlanSchema = SchemaFactory.createForClass(Plan);

