import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type DriverDocument = Driver & Document;

@Schema({ timestamps: true })
export class Driver {
  @Prop({ required: true, unique: true, ref: 'User' })
  userId!: Types.ObjectId;

  @Prop({ required: true })
  licenseNumber!: string;

  @Prop({ required: true })
  phoneNumber!: string;

  @Prop({ type: Types.ObjectId, ref: 'Motorcycle' })
  motorcycleId?: Types.ObjectId;

  @Prop({ default: false })
  isAvailable!: boolean;

  @Prop({ default: 0 })
  totalDeliveries!: number;

  @Prop({ default: 0 })
  rating!: number;

  @Prop()
  licenseDocument?: string; // File path or URL to license document

  @Prop()
  idDocument?: string; // File path or URL to ID document

  @Prop()
  motorcycleDocument?: string; // File path or URL to motorcycle registration

  @Prop({ default: false })
  isVerified!: boolean;
}

export const DriverSchema = SchemaFactory.createForClass(Driver);
