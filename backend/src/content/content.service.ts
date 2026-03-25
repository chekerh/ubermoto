import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { DynamicContent, DynamicContentDocument } from './schemas/dynamic-content.schema';

@Injectable()
export class ContentService {
  constructor(
    @InjectModel(DynamicContent.name)
    private readonly dynamicContentModel: Model<DynamicContentDocument>,
  ) {}

  private assertValidContent(key: string, data: Record<string, any>) {
    if (key === 'pricing_table') {
      if (!Array.isArray(data.plans)) {
        throw new BadRequestException('pricing_table requires plans[]');
      }
      for (const p of data.plans) {
        if (!p || typeof p !== 'object' || typeof p.key !== 'string' || typeof p.title !== 'string') {
          throw new BadRequestException('Invalid pricing_table plan entry');
        }
      }
      return;
    }

    if (key === 'home_announcement_banner') {
      if (typeof data.message !== 'string' || data.message.trim().length < 3) {
        throw new BadRequestException('home_announcement_banner requires message');
      }
      if ('enabled' in data && typeof data.enabled !== 'boolean') {
        throw new BadRequestException('home_announcement_banner.enabled must be boolean');
      }
      return;
    }

    if (key === 'feature_flags') {
      const flags = data.flags;
      if (!flags || typeof flags !== 'object' || Array.isArray(flags)) {
        throw new BadRequestException('feature_flags requires flags object');
      }
      for (const v of Object.values(flags)) {
        if (typeof v !== 'boolean') {
          throw new BadRequestException('feature_flags values must be boolean');
        }
      }
      return;
    }
  }

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
    this.assertValidContent(key, data);

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

