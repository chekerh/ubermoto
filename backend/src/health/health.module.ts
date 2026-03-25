import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { HealthController } from './health.controller';
import { SystemController } from './system.controller';

@Module({
  imports: [MongooseModule],
  controllers: [HealthController, SystemController],
})
export class HealthModule {}
