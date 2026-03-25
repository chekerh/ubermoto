import 'dotenv/config';
import mongoose from 'mongoose';
import { DynamicContent, DynamicContentSchema } from '../src/content/schemas/dynamic-content.schema';

async function main() {
  const uri = process.env.MONGODB_URI;
  if (!uri) throw new Error('MONGODB_URI is required');
  await mongoose.connect(uri);

  const ContentModel = mongoose.model(DynamicContent.name, DynamicContentSchema);

  const now = new Date();
  const docs = [
    {
      key: 'home_announcement_banner',
      schemaVersion: 1,
      status: 'published',
      data: {
        message: 'New: Merchant Pro now includes campaign analytics.',
        enabled: true,
      },
      publishedAt: now,
      updatedByAdminId: 'seed-script',
    },
    {
      key: 'pricing_table',
      schemaVersion: 1,
      status: 'published',
      data: {
        plans: [
          {
            key: 'merchant_basic',
            title: 'Merchant Basic',
            priceDisplay: '59 TND / month',
            bullets: ['Catalog management', 'Basic analytics', 'Standard support'],
          },
          {
            key: 'merchant_pro',
            title: 'Merchant Pro',
            priceDisplay: '129 TND / month',
            bullets: ['Campaign tools', 'Advanced analytics', 'Priority support'],
          },
        ],
      },
      publishedAt: now,
      updatedByAdminId: 'seed-script',
    },
    {
      key: 'feature_flags',
      schemaVersion: 1,
      status: 'published',
      data: {
        flags: {
          merchantBillingSummary: true,
          dynamicAnnouncementBanner: true,
          advancedPromoBuilder: false,
        },
      },
      publishedAt: now,
      updatedByAdminId: 'seed-script',
    },
  ];

  for (const d of docs) {
    await ContentModel.updateOne({ key: d.key }, { $set: d }, { upsert: true }).exec();
  }

  console.log(`Seeded ${docs.length} dynamic content docs`);
  await mongoose.disconnect();
}

main().catch(async (err) => {
  console.error(err);
  await mongoose.disconnect();
  process.exit(1);
});

