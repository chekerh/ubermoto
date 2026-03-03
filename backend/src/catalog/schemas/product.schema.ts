import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type ProductDocument = Product & Document;

@Schema({ timestamps: true })
export class Product {
  @Prop({ required: true })
  name!: string;

  @Prop()
  description?: string;

  @Prop({ required: true })
  price!: number;

  @Prop({ required: true })
  stock!: number;

  @Prop({ type: Types.ObjectId, ref: 'Merchant', required: true })
  merchantId!: Types.ObjectId;

  @Prop({ type: [Types.ObjectId], ref: 'Category', default: [] })
  categoryIds!: Types.ObjectId[];

  @Prop({ type: [String], default: [] })
  tags!: string[];

  @Prop({ type: [String], default: [] })
  images!: string[];

  @Prop({ type: [Types.ObjectId], ref: 'Product', default: [] })
  relatedProductIds!: Types.ObjectId[];

  @Prop({ type: [String], default: [] })
  regions!: string[];

  @Prop({ default: true })
  isActive!: boolean;
}

export const ProductSchema = SchemaFactory.createForClass(Product);
