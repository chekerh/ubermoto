import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { AdminModule } from '../admin/admin.module';
import { ContentController } from './content.controller';
import { ContentService } from './content.service';
import { DynamicContent, DynamicContentSchema } from './schemas/dynamic-content.schema';

@Module({
  imports: [MongooseModule.forFeature([{ name: DynamicContent.name, schema: DynamicContentSchema }]), AdminModule],
  controllers: [ContentController],
  providers: [ContentService],
  exports: [ContentService],
})
export class ContentModule {}

