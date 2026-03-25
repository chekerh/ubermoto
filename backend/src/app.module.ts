import { Module, NestModule } from '@nestjs/common';
import { MiddlewareConsumer } from '@nestjs/common';
import { MonitoringMiddleware } from './monitoring.middleware';
import { ConfigModule } from '@nestjs/config';
import { APP_GUARD } from '@nestjs/core';
import { MongooseModule } from '@nestjs/mongoose';
import { ThrottlerGuard, ThrottlerModule } from '@nestjs/throttler';
import { HealthModule } from './health/health.module';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { MotorcyclesModule } from './motorcycles/motorcycles.module';
import { DeliveriesModule } from './deliveries/deliveries.module';
import { DriversModule } from './drivers/drivers.module';
import { DocumentsModule } from './documents/documents.module';
import { AdminModule } from './admin/admin.module';
import { WebSocketModule } from './websocket/websocket.module';
import { CoreModule } from './core/core.module';
import { FirebaseModule } from './firebase/firebase.module';
import { SurgeModule } from './surge/surge.module';
import { CatalogModule } from './catalog/catalog.module';
import { OrdersModule } from './orders/orders.module';
import { RecommendationsModule } from './recommendations/recommendations.module';
import { NotificationsModule } from './notifications/notifications.module';
import { PromoCodesModule } from './promo-codes/promo-codes.module';
import { SupportModule } from './support/support.module';
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
    ThrottlerModule.forRoot([
      {
        name: 'default',
        ttl: Number(process.env.THROTTLE_TTL_MS ?? 60000),
        limit: Number(process.env.THROTTLE_LIMIT ?? 120),
      },
    ]),
    CoreModule,
    HealthModule,
    UsersModule,
    AuthModule,
    MotorcyclesModule,
    DeliveriesModule,
    DriversModule,
    DocumentsModule,
    AdminModule,
    WebSocketModule,
    FirebaseModule,
    SurgeModule,
    CatalogModule,
    OrdersModule,
    PromoCodesModule,
    RecommendationsModule,
    NotificationsModule,
    SupportModule,
  ],
  providers: [
    DatabaseConfigService,
    {
      provide: APP_GUARD,
      useClass: ThrottlerGuard,
    },
  ],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer.apply(MonitoringMiddleware).forRoutes('*');
  }
}
