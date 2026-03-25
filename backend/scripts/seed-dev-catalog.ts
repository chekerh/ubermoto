/**
 * Inserts demo merchant, categories, and products for local / QA databases.
 * Idempotent: skips categories with existing slugs; adds products only when none exist for demo merchant.
 *
 * Usage (from `backend/`):
 *   MONGODB_URI=mongodb://127.0.0.1:27017/nassib npx ts-node -r tsconfig-paths/register scripts/seed-dev-catalog.ts
 * Or: npm run seed:catalog
 */
import mongoose from 'mongoose';
import { Merchant, MerchantSchema } from '../src/catalog/schemas/merchant.schema';
import { Category, CategorySchema } from '../src/catalog/schemas/category.schema';
import { Product, ProductSchema } from '../src/catalog/schemas/product.schema';

async function main(): Promise<void> {
  const uri = process.env.MONGODB_URI?.trim();
  if (!uri) {
    // eslint-disable-next-line no-console
    console.error('MONGODB_URI is required');
    process.exit(1);
  }

  await mongoose.connect(uri);

  const MerchantModel = mongoose.model(Merchant.name, MerchantSchema);
  const CategoryModel = mongoose.model(Category.name, CategorySchema);
  const ProductModel = mongoose.model(Product.name, ProductSchema);

  let merchant = await MerchantModel.findOne({ name: 'Demo Merchant (QA)' }).exec();
  if (!merchant) {
    merchant = await MerchantModel.create({
      name: 'Demo Merchant (QA)',
      region: 'TND',
      isActive: true,
    });
    // eslint-disable-next-line no-console
    console.log('Created merchant', merchant._id.toString());
  } else {
    // eslint-disable-next-line no-console
    console.log('Using existing merchant', merchant._id.toString());
  }

  const categorySpecs = [
    { name: 'Food', slug: 'food' },
    { name: 'Groceries', slug: 'groceries' },
    { name: 'Pharmacy', slug: 'pharmacy' },
  ];

  const categoryIds: mongoose.Types.ObjectId[] = [];
  for (const spec of categorySpecs) {
    let cat = await CategoryModel.findOne({ slug: spec.slug }).exec();
    if (!cat) {
      cat = await CategoryModel.create({ ...spec, isActive: true });
      // eslint-disable-next-line no-console
      console.log('Created category', spec.slug);
    }
    categoryIds.push(cat._id);
  }

  const existingProducts = await ProductModel.countDocuments({ merchantId: merchant._id }).exec();
  if (existingProducts > 0) {
    // eslint-disable-next-line no-console
    console.log(`Skip product insert: ${existingProducts} products already for demo merchant`);
    await mongoose.disconnect();
    return;
  }

  const products = [
    {
      name: 'Harissa Paste',
      description: 'Demo catalog item for QA',
      price: 4.5,
      stock: 100,
      tags: ['spicy', 'condiment'],
      images: [],
      regions: ['TND'],
      isActive: true,
    },
    {
      name: 'Baguette',
      description: 'Fresh bread',
      price: 1.2,
      stock: 50,
      tags: ['bakery'],
      images: [],
      regions: ['TND'],
      isActive: true,
    },
    {
      name: 'Bottled Water 1.5L',
      description: 'Still water',
      price: 0.8,
      stock: 200,
      tags: ['drinks'],
      images: [],
      regions: ['TND'],
      isActive: true,
    },
  ];

  for (let i = 0; i < products.length; i++) {
    const p = products[i];
    await ProductModel.create({
      ...p,
      merchantId: merchant._id,
      categoryIds: [categoryIds[i % categoryIds.length]],
      relatedProductIds: [],
    });
    // eslint-disable-next-line no-console
    console.log('Created product', p.name);
  }

  await mongoose.disconnect();
  // eslint-disable-next-line no-console
  console.log('Seed complete.');
}

main().catch((e) => {
  // eslint-disable-next-line no-console
  console.error(e);
  process.exit(1);
});
