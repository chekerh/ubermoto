import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';
import { UserRole } from '../../users/schemas/user.schema';

export enum AdminAuditAction {
  DRIVER_VERIFY = 'DRIVER_VERIFY',
  DRIVER_REJECT = 'DRIVER_REJECT',
  DOCUMENT_APPROVE = 'DOCUMENT_APPROVE',
  DOCUMENT_REJECT = 'DOCUMENT_REJECT',
  SURGE_CREATE = 'SURGE_CREATE',
  SURGE_UPDATE = 'SURGE_UPDATE',
  SURGE_DELETE = 'SURGE_DELETE',
  SURGE_TOGGLE = 'SURGE_TOGGLE',
  PRODUCT_BULK_UPDATE = 'PRODUCT_BULK_UPDATE',
  ALERT_SEND = 'ALERT_SEND',
}

export type AdminAuditLogDocument = AdminAuditLog & Document;

@Schema({ timestamps: true })
export class AdminAuditLog {
  @Prop({ required: true, ref: 'User' })
  adminId!: Types.ObjectId;

  @Prop({ required: true, enum: UserRole })
  adminRole!: UserRole;

  @Prop({ required: true, enum: AdminAuditAction })
  action!: AdminAuditAction;

  @Prop({ required: true })
  targetId!: string; // e.g., driverId or documentId

  @Prop()
  targetRole?: UserRole; // optional: role of the target user

  @Prop()
  reason?: string; // optional: rejection reason or notes

  @Prop({ type: Types.ObjectId, ref: 'User' })
  targetUserId?: Types.ObjectId; // optional: if action targets a user
}

export const AdminAuditLogSchema = SchemaFactory.createForClass(AdminAuditLog);
