import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { SurgeController } from './surge.controller';
import { SurgeService } from './surge.service';
import { SurgeRule, SurgeRuleSchema } from './schemas/surge-rule.schema';
import { AdminModule } from '../admin/admin.module';

@Module({
  imports: [
    MongooseModule.forFeature([{ name: SurgeRule.name, schema: SurgeRuleSchema }]),
    AdminModule,
  ],
  controllers: [SurgeController],
  providers: [SurgeService],
  exports: [SurgeService],
})
export class SurgeModule {}
