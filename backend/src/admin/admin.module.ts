import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { AdminService } from './admin.service';
import { AdminController } from './admin.controller';
import { User, UserSchema } from '../users/schemas/user.schema';
import { Driver, DriverSchema } from '../drivers/schemas/driver.schema';
import { Delivery, DeliverySchema } from '../deliveries/schemas/delivery.schema';
import { DocumentEntity, DocumentSchema } from '../documents/schemas/document.schema';
import { UsersModule } from '../users/users.module';
import { DriversModule } from '../drivers/drivers.module';
import { DocumentsModule } from '../documents/documents.module';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: User.name, schema: UserSchema },
      { name: Driver.name, schema: DriverSchema },
      { name: Delivery.name, schema: DeliverySchema },
      { name: DocumentEntity.name, schema: DocumentSchema },
    ]),
    UsersModule,
    DriversModule,
    DocumentsModule,
  ],
  controllers: [AdminController],
  providers: [AdminService],
  exports: [AdminService],
})
export class AdminModule {}
