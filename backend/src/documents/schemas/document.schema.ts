import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export enum DocumentType {
  DRIVER_LICENSE = 'DRIVER_LICENSE',
  ID_CARD = 'ID_CARD',
  INSURANCE = 'INSURANCE',
  VEHICLE_REGISTRATION = 'VEHICLE_REGISTRATION',
}

export enum DocumentStatus {
  PENDING = 'PENDING',
  APPROVED = 'APPROVED',
  REJECTED = 'REJECTED',
}

export type DocumentDocument = DocumentEntity & Document;

@Schema({ timestamps: true })
export class DocumentEntity {
  @Prop({ required: true, ref: 'User' })
  userId!: Types.ObjectId;

  @Prop({ required: true, enum: DocumentType })
  documentType!: DocumentType;

  @Prop({ required: true })
  fileName!: string;

  @Prop({ required: true })
  filePath!: string;

  @Prop({ required: true })
  mimeType!: string;

  @Prop({ required: true })
  fileSize!: number;

  @Prop({ required: true, enum: DocumentStatus, default: DocumentStatus.PENDING })
  status!: DocumentStatus;

  @Prop()
  rejectionReason?: string;

  @Prop({ ref: 'User' })
  reviewedBy?: Types.ObjectId;

  @Prop()
  reviewedAt?: Date;
}

export const DocumentSchema = SchemaFactory.createForClass(DocumentEntity);
