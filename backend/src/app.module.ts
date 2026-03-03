import { Module, NestModule } from '@nestjs/common';
import { MiddlewareConsumer } from '@nestjs/common';
import { MonitoringMiddleware } from './monitoring.middleware';
import { ConfigModule } from '@nestjs/config';
import { MongooseModule } from '@nestjs/mongoose';
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
    DriversModule,
    DocumentsModule,
    AdminModule,
    WebSocketModule,
    FirebaseModule,
    SurgeModule,
    CatalogModule,
    OrdersModule,
    RecommendationsModule,
    NotificationsModule,
  ],
  providers: [DatabaseConfigService],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer.apply(MonitoringMiddleware).forRoutes('*');
  }
}
