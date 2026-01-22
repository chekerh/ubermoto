import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export enum UserRole {
  CUSTOMER = 'CUSTOMER',
  DRIVER = 'DRIVER',
  ADMIN = 'ADMIN',
}

export type UserDocument = User & Document;

@Schema({ timestamps: true })
export class User {
  @Prop({ required: true, unique: true })
  email!: string;

  @Prop({ required: true })
  password!: string;

  @Prop({ required: true })
  name!: string;

  @Prop({ required: true, enum: UserRole, default: UserRole.CUSTOMER })
  role!: UserRole;

  @Prop({ default: false })
  isVerified!: boolean;

  @Prop()
  phoneNumber?: string;

  @Prop()
  avatarUrl?: string;

  @Prop({
    type: {
      notifications: {
        email: { type: Boolean, default: true },
        push: { type: Boolean, default: true },
        sms: { type: Boolean, default: false },
        deliveryUpdates: { type: Boolean, default: true },
        promotions: { type: Boolean, default: true },
      },
      language: { type: String, default: 'en' },
      theme: { type: String, enum: ['light', 'dark', 'system'], default: 'system' },
      currency: { type: String, default: 'TND' },
    },
    default: {
      notifications: {
        email: true,
        push: true,
        sms: false,
        deliveryUpdates: true,
        promotions: true,
      },
      language: 'en',
      theme: 'system',
      currency: 'TND',
    },
  })
  preferences?: {
    notifications: {
      email: boolean;
      push: boolean;
      sms: boolean;
      deliveryUpdates: boolean;
      promotions: boolean;
    };
    language: string;
    theme: 'light' | 'dark' | 'system';
    currency: string;
  };
}

export const UserSchema = SchemaFactory.createForClass(User);
