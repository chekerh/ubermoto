import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { DeliveriesService } from './deliveries.service';
import { DeliveriesController } from './deliveries.controller';
import { Delivery, DeliverySchema } from './schemas/delivery.schema';
import { MotorcyclesModule } from '../motorcycles/motorcycles.module';
import { CoreModule } from '../core/core.module';

@Module({
  imports: [
    MongooseModule.forFeature([{ name: Delivery.name, schema: DeliverySchema }]),
    MotorcyclesModule,
    CoreModule,
  ],
  controllers: [DeliveriesController],
  providers: [DeliveriesService],
  exports: [DeliveriesService],
})
export class DeliveriesModule {}
