import { Injectable, NotFoundException, ConflictException, ForbiddenException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Product, ProductDocument } from './schemas/product.schema';
import { Category, CategoryDocument } from './schemas/category.schema';
import { Merchant, MerchantDocument } from './schemas/merchant.schema';
import { QueryProductsDto } from './dto/query-products.dto';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { CreateCategoryDto } from './dto/create-category.dto';
import { UpdateCategoryDto } from './dto/update-category.dto';
import { BillingService } from '../billing/billing.service';

interface CatalogRequester {
  userId: string;
  role: string;
}

@Injectable()
export class CatalogService {
  constructor(
    @InjectModel(Product.name) private productModel: Model<ProductDocument>,
    @InjectModel(Category.name) private categoryModel: Model<CategoryDocument>,
    @InjectModel(Merchant.name) private merchantModel: Model<MerchantDocument>,
    private readonly billingService: BillingService,
  ) {}

  async createMerchant(dto: { name: string; region: string; logoUrl?: string }) {
    const merchant = new this.merchantModel({
      name: dto.name,
      region: dto.region,
      logoUrl: dto.logoUrl,
      isActive: true,
    });
    return merchant.save();
  }

  async listCategories(): Promise<CategoryDocument[]> {
    return this.categoryModel.find({ isActive: true }).sort({ name: 1 }).exec();
  }

  /** Active merchants for admin catalog (e.g. product create). */
  async listActiveMerchants(): Promise<Array<{ id: string; name: string; region: string }>> {
    const docs = await this.merchantModel
      .find({ isActive: true })
      .select('_id name region')
      .sort({ name: 1 })
      .lean()
      .exec();
    return docs.map((m) => ({
      id: String(m._id),
      name: m.name as string,
      region: (m.region as string) ?? 'TND',
    }));
  }

  async listProducts(query: QueryProductsDto): Promise<ProductDocument[]> {
    const filter: any = { isActive: true };
    if (query.categoryId) filter.categoryIds = new Types.ObjectId(query.categoryId);
    if (query.region) filter.$or = [{ regions: query.region }, { regions: { $size: 0 } }];
    if (query.search) filter.name = { $regex: query.search, $options: 'i' };
    const limit = query.limit || 20;
    const skip = query.skip || 0;
    return this.productModel
      .find(filter)
      .skip(skip)
      .limit(limit)
      .populate('merchantId', 'name logoUrl')
      .populate('categoryIds', 'name')
      .exec();
  }

  async getProduct(id: string): Promise<ProductDocument | null> {
    return this.productModel
      .findById(id)
      .populate('merchantId', 'name logoUrl')
      .populate('categoryIds', 'name')
      .exec();
  }

  async getRelated(productId: string, limit = 5): Promise<ProductDocument[]> {
    const product = await this.productModel.findById(productId).exec();
    if (!product) return [];
    if (product.relatedProductIds?.length) {
      return this.productModel
        .find({ _id: { $in: product.relatedProductIds }, isActive: true })
        .limit(limit)
        .exec();
    }
    // fallback: same category
    return this.productModel
      .find({
        _id: { $ne: productId },
        isActive: true,
        categoryIds: { $in: product.categoryIds },
      })
      .limit(limit)
      .exec();
  }

  // ── Product CRUD ──────────────────────────────────────────────────────

  async createProduct(dto: CreateProductDto, requester?: CatalogRequester): Promise<ProductDocument> {
    if (requester?.role === 'MERCHANT') {
      await this.billingService.assertMerchantAccessOrThrow(dto.merchantId, requester.userId, requester.role);
      const entitlements = await this.billingService.getEntitlementsForUser(
        requester.userId,
        requester.role,
        dto.merchantId,
      );
      const maxProductsRaw = entitlements?.merchant?.limits?.['merchant.products.max'];
      const maxProducts =
        typeof maxProductsRaw === 'number'
          ? maxProductsRaw
          : (typeof maxProductsRaw === 'string' ? Number(maxProductsRaw) : NaN);
      if (Number.isFinite(maxProducts) && maxProducts > 0) {
        const currentCount = await this.productModel.countDocuments({
          merchantId: new Types.ObjectId(dto.merchantId),
        });
        if (currentCount >= maxProducts) {
          throw new ForbiddenException(
            `Plan limit reached: merchant.products.max=${maxProducts}. Upgrade to add more products.`,
          );
        }
      }
    }
    const productData: any = {
      ...dto,
      merchantId: new Types.ObjectId(dto.merchantId),
    };

    if (dto.categoryIds?.length) {
      productData.categoryIds = dto.categoryIds.map((id) => new Types.ObjectId(id));
    }

    if (dto.relatedProductIds?.length) {
      productData.relatedProductIds = dto.relatedProductIds.map((id) => new Types.ObjectId(id));
    }

    const product = new this.productModel(productData);
    return product.save();
  }

  async updateProduct(id: string, dto: UpdateProductDto, requester?: CatalogRequester): Promise<ProductDocument> {
    const existing = await this.productModel.findById(id).exec();
    if (!existing) {
      throw new NotFoundException(`Product with ID ${id} not found`);
    }
    if (requester?.role === 'MERCHANT') {
      await this.billingService.assertMerchantAccessOrThrow(
        existing.merchantId.toString(),
        requester.userId,
        requester.role,
      );
      if (dto.merchantId && dto.merchantId !== existing.merchantId.toString()) {
        throw new ForbiddenException('Merchant users cannot transfer product ownership');
      }
    }

    const updateData: any = { ...dto };

    if (dto.merchantId) {
      updateData.merchantId = new Types.ObjectId(dto.merchantId);
    }

    if (dto.categoryIds?.length) {
      updateData.categoryIds = dto.categoryIds.map((cid) => new Types.ObjectId(cid));
    }

    if (dto.relatedProductIds?.length) {
      updateData.relatedProductIds = dto.relatedProductIds.map((pid) => new Types.ObjectId(pid));
    }

    const product = await this.productModel.findByIdAndUpdate(id, updateData, { new: true }).exec();
    if (!product) {
      throw new NotFoundException(`Product with ID ${id} not found`);
    }
    return product;
  }

  async deleteProduct(id: string, requester?: CatalogRequester): Promise<void> {
    const existing = await this.productModel.findById(id).exec();
    if (!existing) {
      throw new NotFoundException(`Product with ID ${id} not found`);
    }
    if (requester?.role === 'MERCHANT') {
      await this.billingService.assertMerchantAccessOrThrow(
        existing.merchantId.toString(),
        requester.userId,
        requester.role,
      );
    }
    await this.productModel.findByIdAndDelete(id).exec();
  }

  // ── Category CRUD ─────────────────────────────────────────────────────

  async createCategory(dto: CreateCategoryDto): Promise<CategoryDocument> {
    const existing = await this.categoryModel.findOne({ slug: dto.slug }).exec();
    if (existing) {
      throw new ConflictException(`Category with slug '${dto.slug}' already exists`);
    }

    const categoryData: any = { ...dto };
    if (dto.parentId) {
      categoryData.parentId = new Types.ObjectId(dto.parentId);
    }

    const category = new this.categoryModel(categoryData);
    return category.save();
  }

  async updateCategory(id: string, dto: UpdateCategoryDto): Promise<CategoryDocument> {
    if (dto.slug) {
      const existing = await this.categoryModel
        .findOne({ slug: dto.slug, _id: { $ne: id } })
        .exec();
      if (existing) {
        throw new ConflictException(`Category with slug '${dto.slug}' already exists`);
      }
    }

    const updateData: any = { ...dto };
    if (dto.parentId) {
      updateData.parentId = new Types.ObjectId(dto.parentId);
    }

    const category = await this.categoryModel
      .findByIdAndUpdate(id, updateData, { new: true })
      .exec();
    if (!category) {
      throw new NotFoundException(`Category with ID ${id} not found`);
    }
    return category;
  }

  async deleteCategory(id: string): Promise<void> {
    const result = await this.categoryModel.findByIdAndDelete(id).exec();
    if (!result) {
      throw new NotFoundException(`Category with ID ${id} not found`);
    }
  }
}
