import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type PayoutDocument = Payout & Document;

export enum PayoutStatus {
  PENDING = 'pending',
  PROCESSING = 'processing',
  COMPLETED = 'completed',
  FAILED = 'failed',
  CANCELLED = 'cancelled',
}

@Schema({ timestamps: true })
export class Payout {
  @Prop({ type: Types.ObjectId, ref: 'Driver', required: true })
  driverId!: Types.ObjectId;

  @Prop({ required: true })
  amount!: number;

  @Prop({
    type: String,
    enum: PayoutStatus,
    default: PayoutStatus.PENDING,
  })
  status!: PayoutStatus;

  @Prop()
  requestedAt!: Date;

  @Prop()
  processedAt?: Date;

  @Prop()
  completedAt?: Date;

  @Prop()
  failureReason?: string;

  @Prop()
  transactionId?: string;

  @Prop({ default: 'bank_transfer' })
  paymentMethod!: string;

  @Prop()
  bankAccountLast4?: string;
}

export const PayoutSchema = SchemaFactory.createForClass(Payout);
