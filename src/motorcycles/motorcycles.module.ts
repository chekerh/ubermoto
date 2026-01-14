import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { MotorcyclesService } from './motorcycles.service';
import { MotorcyclesController } from './motorcycles.controller';
import { Motorcycle, MotorcycleSchema } from './schemas/motorcycle.schema';

@Module({
  imports: [MongooseModule.forFeature([{ name: Motorcycle.name, schema: MotorcycleSchema }])],
  controllers: [MotorcyclesController],
  providers: [MotorcyclesService],
  exports: [MotorcyclesService],
})
export class MotorcyclesModule {}
