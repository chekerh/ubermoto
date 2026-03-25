import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { DriversService } from './drivers.service';
import { DriversController } from './drivers.controller';
import { Driver, DriverSchema } from './schemas/driver.schema';
import { Payout, PayoutSchema } from './schemas/payout.schema';
import { Delivery, DeliverySchema } from '../deliveries/schemas/delivery.schema';
import { UsersModule } from '../users/users.module';
import { WebSocketModule } from '../websocket/websocket.module';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: Driver.name, schema: DriverSchema },
      { name: Delivery.name, schema: DeliverySchema },
      { name: Payout.name, schema: PayoutSchema },
    ]),
    UsersModule,
    WebSocketModule,
  ],
  controllers: [DriversController],
  providers: [DriversService],
  exports: [DriversService],
})
export class DriversModule {}
