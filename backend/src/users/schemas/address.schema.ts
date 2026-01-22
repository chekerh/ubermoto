import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type AddressDocument = Address & Document;

@Schema({ timestamps: true })
export class Address {
  @Prop({ required: true, ref: 'User' })
  userId!: Types.ObjectId;

  @Prop({ required: true })
  label!: string; // "Home", "Work", "Other"

  @Prop({ required: true })
  address!: string;

  @Prop({ required: true })
  city!: string;

  @Prop()
  postalCode?: string;

  @Prop({
    type: {
      lat: { type: Number },
      lng: { type: Number },
    },
  })
  coordinates?: {
    lat: number;
    lng: number;
  };

  @Prop({ default: false })
  isDefault!: boolean;
}

export const AddressSchema = SchemaFactory.createForClass(Address);
