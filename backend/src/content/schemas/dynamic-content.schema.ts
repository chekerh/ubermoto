import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type DynamicContentDocument = DynamicContent & Document;

export type DynamicContentStatus = 'draft' | 'published';

@Schema({ timestamps: true })
export class DynamicContent {
  @Prop({ required: true, unique: true, index: true })
  key!: string;

  @Prop({ required: true, default: 1 })
  schemaVersion!: number;

  @Prop({ required: true, enum: ['draft', 'published'], default: 'draft' })
  status!: DynamicContentStatus;

  @Prop({ type: Object, required: true, default: {} })
  data!: Record<string, any>;

  @Prop()
  publishedAt?: Date;

  @Prop()
  updatedByAdminId?: string;
}

export const DynamicContentSchema = SchemaFactory.createForClass(DynamicContent);

