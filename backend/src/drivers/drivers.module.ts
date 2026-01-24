import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { DriversService } from './drivers.service';
import { DriversController } from './drivers.controller';
import { Driver, DriverSchema } from './schemas/driver.schema';
import { UsersModule } from '../users/users.module';
import { WebSocketModule } from '../websocket/websocket.module';

@Module({
  imports: [
    MongooseModule.forFeature([{ name: Driver.name, schema: DriverSchema }]),
    UsersModule,
    WebSocketModule,
  ],
  controllers: [DriversController],
  providers: [DriversService],
  exports: [DriversService],
})
export class DriversModule {}
