import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { MongooseModule } from '@nestjs/mongoose';
import { HealthModule } from './health/health.module';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { MotorcyclesModule } from './motorcycles/motorcycles.module';
import { DeliveriesModule } from './deliveries/deliveries.module';
import { CoreModule } from './core/core.module';
import { DatabaseConfigService } from './config/database-config.service';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: ['.env.local', '.env'],
    }),
    MongooseModule.forRootAsync({
      useClass: DatabaseConfigService,
      inject: [DatabaseConfigService],
    }),
    CoreModule,
    HealthModule,
    UsersModule,
    AuthModule,
    MotorcyclesModule,
    DeliveriesModule,
  ],
  providers: [DatabaseConfigService],
})
export class AppModule {}
