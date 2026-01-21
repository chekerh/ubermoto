import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { DeliveriesService } from './deliveries.service';
import { DeliveriesController } from './deliveries.controller';
import { DeliveryMatchingService } from './delivery-matching.service';
import { Delivery, DeliverySchema } from './schemas/delivery.schema';
import { Driver, DriverSchema } from '../drivers/schemas/driver.schema';
import { User, UserSchema } from '../users/schemas/user.schema';
import { MotorcyclesModule } from '../motorcycles/motorcycles.module';
import { CoreModule } from '../core/core.module';
import { WebSocketModule } from '../websocket/websocket.module';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: Delivery.name, schema: DeliverySchema },
      { name: Driver.name, schema: DriverSchema },
      { name: User.name, schema: UserSchema },
    ]),
    MotorcyclesModule,
    CoreModule,
    WebSocketModule,
  ],
  controllers: [DeliveriesController],
  providers: [DeliveriesService, DeliveryMatchingService],
  exports: [DeliveriesService, DeliveryMatchingService],
})
export class DeliveriesModule {}
