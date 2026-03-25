import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type EntitlementDocument = Entitlement & Document;

@Schema({ timestamps: true })
export class Entitlement {
  @Prop({ required: true, unique: true, index: true })
  merchantId!: string;

  @Prop({ required: true })
  planKey!: string;

  @Prop({ type: Object, default: {} })
  features!: Record<string, boolean>;

  @Prop({ type: Object, default: {} })
  limits!: Record<string, number>;

  @Prop({ required: true })
  computedAt!: Date;
}

export const EntitlementSchema = SchemaFactory.createForClass(Entitlement);
