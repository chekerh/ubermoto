import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { DeliveryGateway } from './delivery.gateway';

@Module({
  imports: [
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
