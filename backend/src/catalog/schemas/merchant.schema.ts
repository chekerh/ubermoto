import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type MerchantDocument = Merchant & Document;

@Schema({ timestamps: true })
export class Merchant {
  @Prop({ required: true })
  name!: string;

  @Prop()
  logoUrl?: string;

  @Prop({ required: true })
  region!: string;

  @Prop({ default: true })
  isActive!: boolean;
}

export const MerchantSchema = SchemaFactory.createForClass(Merchant);
