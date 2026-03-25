import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export enum TicketStatus {
  OPEN = 'open',
  IN_PROGRESS = 'in_progress',
  RESOLVED = 'resolved',
  CLOSED = 'closed',
}

export enum TicketPriority {
  LOW = 'low',
  MEDIUM = 'medium',
  HIGH = 'high',
  URGENT = 'urgent',
}

export type SupportTicketDocument = SupportTicket & Document;

@Schema({ timestamps: true })
export class SupportTicket {
  @Prop({ type: Types.ObjectId, ref: 'User', required: true, index: true })
  userId!: Types.ObjectId;

  @Prop({ required: true })
  subject!: string;

  @Prop({ required: true })
  description!: string;

  @Prop({
    type: String,
    enum: TicketStatus,
    default: TicketStatus.OPEN,
  })
  status!: TicketStatus;

  @Prop({
    type: String,
    enum: TicketPriority,
    default: TicketPriority.MEDIUM,
  })
  priority!: TicketPriority;

  @Prop({ type: Types.ObjectId, ref: 'User' })
  assignedTo?: Types.ObjectId; // Admin who is handling it

  @Prop()
  resolution?: string;

  @Prop({ type: Types.ObjectId })
  referenceId?: Types.ObjectId; // e.g. deliveryId, orderId

  @Prop()
  referenceType?: string;
}

export const SupportTicketSchema = SchemaFactory.createForClass(SupportTicket);
