import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { MongooseModule } from '@nestjs/mongoose';
import { DeliveryGateway } from './delivery.gateway';
import { Delivery, DeliverySchema } from '../deliveries/schemas/delivery.schema';
import { Driver, DriverSchema } from '../drivers/schemas/driver.schema';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: Delivery.name, schema: DeliverySchema },
      { name: Driver.name, schema: DriverSchema },
    ]),
    JwtModule.registerAsync({
      imports: [ConfigModule],
      useFactory: async (configService: ConfigService) => ({
        secret: configService.get<string>('JWT_SECRET') || 'default-secret',
      }),
      inject: [ConfigService],
    }),
  ],
  providers: [DeliveryGateway],
  exports: [DeliveryGateway],
})
export class WebSocketModule {}
