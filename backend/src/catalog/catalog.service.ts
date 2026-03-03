import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Product, ProductDocument } from './schemas/product.schema';
import { Category, CategoryDocument } from './schemas/category.schema';
import { QueryProductsDto } from './dto/query-products.dto';

@Injectable()
export class CatalogService {
  constructor(
    @InjectModel(Product.name) private productModel: Model<ProductDocument>,
    @InjectModel(Category.name) private categoryModel: Model<CategoryDocument>,
  ) {}

  async listCategories(): Promise<CategoryDocument[]> {
    return this.categoryModel.find({ isActive: true }).sort({ name: 1 }).exec();
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
      return this.productModel.find({ _id: { $in: product.relatedProductIds }, isActive: true }).limit(limit).exec();
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
}
