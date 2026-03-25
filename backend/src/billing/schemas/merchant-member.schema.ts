import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type MerchantMemberDocument = MerchantMember & Document;

export type MerchantMemberRole = 'owner' | 'manager' | 'analyst';

@Schema({ timestamps: true })
export class MerchantMember {
  @Prop({ required: true, index: true })
  merchantId!: string;

  @Prop({ required: true, index: true })
  userId!: string;

  @Prop({ required: true, enum: ['owner', 'manager', 'analyst'], default: 'manager' })
  role!: MerchantMemberRole;

  @Prop({ default: true })
  isActive!: boolean;
}

export const MerchantMemberSchema = SchemaFactory.createForClass(MerchantMember);
MerchantMemberSchema.index({ merchantId: 1, userId: 1 }, { unique: true });
