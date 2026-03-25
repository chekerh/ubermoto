import 'dotenv/config';
import mongoose from 'mongoose';
import { PlanSchema, Plan } from '../src/billing/schemas/plan.schema';

async function main() {
  const uri = process.env.MONGODB_URI;
  if (!uri) {
    throw new Error('MONGODB_URI is required');
  }
  await mongoose.connect(uri);
  const PlanModel = mongoose.model(Plan.name, PlanSchema);

  const plans = [
    {
      key: 'merchant_basic',
      name: 'Merchant Basic',
      description: 'Core catalog and operational tooling for small merchants.',
      stripePriceId: process.env.STRIPE_PRICE_MERCHANT_BASIC || 'price_basic_placeholder',
      features: {
        'merchant.catalog.write': true,
        'merchant.analytics.basic': true,
        'merchant.promos.write': false,
        'merchant.analytics.advanced': false,
      },
      limits: {
        'merchant.products.max': 200,
        'merchant.promos.per_month': 0,
      },
      isActive: true,
    },
    {
      key: 'merchant_pro',
      name: 'Merchant Pro',
      description: 'Growth plan with campaigns and advanced analytics.',
      stripePriceId: process.env.STRIPE_PRICE_MERCHANT_PRO || 'price_pro_placeholder',
      features: {
        'merchant.catalog.write': true,
        'merchant.analytics.basic': true,
        'merchant.promos.write': true,
        'merchant.analytics.advanced': true,
      },
      limits: {
        'merchant.products.max': 2000,
        'merchant.promos.per_month': 20,
      },
      isActive: true,
    },
  ];

  for (const p of plans) {
    await PlanModel.updateOne({ key: p.key }, { $set: p }, { upsert: true }).exec();
  }

  console.log(`Seeded ${plans.length} plans`);
  await mongoose.disconnect();
}

main().catch(async (err) => {
  console.error(err);
  await mongoose.disconnect();
  process.exit(1);
});

