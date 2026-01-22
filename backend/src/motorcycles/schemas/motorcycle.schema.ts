import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type MotorcycleDocument = Motorcycle & Document;

@Schema({ timestamps: true })
export class Motorcycle {
  @Prop({ required: true })
  model!: string;

  @Prop({ required: true })
  brand!: string;

  @Prop({ required: true })
  fuelConsumption!: number; // Liters per 100 km

  @Prop()
  mileage?: number; // Current mileage of the motorcycle

  @Prop()
  engineType?: string;

  @Prop()
  capacity?: number; // Engine capacity in cc

  @Prop()
  year?: number;
}

export const MotorcycleSchema = SchemaFactory.createForClass(Motorcycle);
