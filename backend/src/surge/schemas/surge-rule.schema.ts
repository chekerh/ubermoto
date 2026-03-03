import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type SurgeRuleDocument = SurgeRule & Document;

@Schema({ timestamps: true })
export class SurgeRule {
  @Prop({ required: true })
  label!: string;

  @Prop({ required: true })
  region!: string; // e.g., city code

  @Prop({ type: [[Number]], default: undefined })
  polygon?: number[][]; // optional Geo polygon [[lng, lat]...]

  @Prop({ type: [Number], default: [0, 1, 2, 3, 4, 5, 6] })
  weekdays!: number[]; // 0-6 Sun-Sat

  @Prop({ required: true })
  startTime!: string; // HH:mm

  @Prop({ required: true })
  endTime!: string; // HH:mm

  @Prop({ required: true, min: 1 })
  multiplier!: number;

  @Prop({ default: true })
  active!: boolean;

  @Prop({ type: Types.ObjectId, ref: 'User' })
  createdBy?: Types.ObjectId;

  @Prop({ type: Types.ObjectId, ref: 'User' })
  updatedBy?: Types.ObjectId;
}

export const SurgeRuleSchema = SchemaFactory.createForClass(SurgeRule);
