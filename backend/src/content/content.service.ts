import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { DynamicContent, DynamicContentDocument } from './schemas/dynamic-content.schema';

@Injectable()
export class ContentService {
  constructor(
    @InjectModel(DynamicContent.name)
    private readonly dynamicContentModel: Model<DynamicContentDocument>,
  ) {}

  async getPublished(key: string) {
    const doc = await this.dynamicContentModel.findOne({ key, status: 'published' }).lean().exec();
    if (!doc) {
      throw new NotFoundException('Content not found');
    }
    return { key: doc.key, schemaVersion: doc.schemaVersion, data: doc.data, publishedAt: doc.publishedAt };
  }

  async getAdminView(key: string) {
    const doc = await this.dynamicContentModel.findOne({ key }).lean().exec();
    if (!doc) {
      throw new NotFoundException('Content not found');
    }
    return doc;
  }

  async upsert(
    key: string,
    schemaVersion: number,
    data: Record<string, any>,
    publish: boolean,
    updatedByAdminId: string,
  ) {
    const update: Partial<DynamicContent> = {
      key,
      schemaVersion,
      data,
      updatedByAdminId,
      status: publish ? 'published' : 'draft',
      publishedAt: publish ? new Date() : undefined,
    };

    const doc = await this.dynamicContentModel
      .findOneAndUpdate({ key }, { $set: update }, { upsert: true, new: true })
      .lean()
      .exec();

    return doc;
  }
}

