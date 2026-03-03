import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type OrderDocument = Order & Document;

export enum OrderStatus {
  PENDING_PAYMENT = 'pending_payment',
  CONFIRMED = 'confirmed',
  ASSIGNED = 'assigned',
  IN_TRANSIT = 'in_transit',
  COMPLETED = 'completed',
  CANCELLED = 'cancelled',
}

export enum OrderType {
  MARKET = 'MARKET',
  DELIVERY = 'DELIVERY',
  RIDE = 'RIDE',
  PARTS = 'PARTS',
}

export enum PaymentMethod {
  COD = 'COD',
  CARD = 'CARD',
  PAYPAL = 'PAYPAL',
  WALLET = 'WALLET',
}

export class OrderItem {
  @Prop({ type: Types.ObjectId, ref: 'Product', required: true })
  productId!: Types.ObjectId;

  @Prop({ required: true })
  name!: string;

  @Prop({ required: true })
  price!: number;

  @Prop({ required: true })
  quantity!: number;
}

@Schema({ timestamps: true })
export class Order {
  @Prop({ type: Types.ObjectId, ref: 'User', required: true })
  userId!: Types.ObjectId;

  @Prop({ type: [OrderItem], required: true })
  items!: OrderItem[];

  @Prop({ required: true })
  subtotal!: number;

  @Prop({ default: 0 })
  deliveryFee!: number;

  @Prop({ required: true })
  total!: number;

  @Prop({ type: String, enum: PaymentMethod, default: PaymentMethod.COD })
  paymentMethod!: PaymentMethod;

  @Prop()
  paymentIntentId?: string;

  @Prop()
  paymentProvider?: string;

  @Prop({ type: String, enum: OrderStatus, default: OrderStatus.CONFIRMED })
  status!: OrderStatus;

  @Prop({ type: String, enum: OrderType, default: OrderType.MARKET })
  type!: OrderType;

  @Prop()
  address?: string;

  @Prop()
  region?: string;

  @Prop({ default: 1 })
  surgeMultiplier?: number;

  @Prop({ type: Types.ObjectId, ref: 'Driver' })
  driverId?: Types.ObjectId;
}

export const OrderSchema = SchemaFactory.createForClass(Order);
