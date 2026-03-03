import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Order, OrderDocument } from '../orders/schemas/order.schema';
import { Product, ProductDocument } from '../catalog/schemas/product.schema';

@Injectable()
export class RecommendationsService {
  constructor(
    @InjectModel(Order.name) private orderModel: Model<OrderDocument>,
    @InjectModel(Product.name) private productModel: Model<ProductDocument>,
  ) {}

  async getUserRecommendations(userId: string, limit = 8) {
    // simple heuristic: most frequent products in recent orders
    const orders = await this.orderModel
      .find({ userId })
      .sort({ createdAt: -1 })
      .limit(20)
      .exec();

    const freq = new Map<string, number>();
    orders.forEach((o) =>
      o.items.forEach((i) => freq.set(i.productId.toString(), (freq.get(i.productId.toString()) || 0) + i.quantity)),
    );

    const sorted = Array.from(freq.entries())
      .sort((a, b) => b[1] - a[1])
      .slice(0, limit)
      .map((x) => x[0]);

    return this.productModel.find({ _id: { $in: sorted }, isActive: true }).exec();
  }

  async getFrequentlyBoughtTogether(productId: string, limit = 5) {
    const orders = await this.orderModel
      .find({ 'items.productId': new Types.ObjectId(productId) })
      .sort({ createdAt: -1 })
      .limit(50)
      .exec();

    const freq = new Map<string, number>();
    orders.forEach((o) => {
      const productIds = o.items.map((i) => i.productId.toString());
      productIds.forEach((pid) => {
        if (pid !== productId) freq.set(pid, (freq.get(pid) || 0) + 1);
      });
    });

    const sorted = Array.from(freq.entries())
      .sort((a, b) => b[1] - a[1])
      .slice(0, limit)
      .map((x) => x[0]);

    return this.productModel.find({ _id: { $in: sorted }, isActive: true }).exec();
  }
}
