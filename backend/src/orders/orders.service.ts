import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import {
  Order,
  OrderDocument,
  OrderStatus,
  OrderType,
  PaymentMethod,
} from './schemas/order.schema';
import { CreateOrderDto } from './dto/create-order.dto';
import { Product, ProductDocument } from '../catalog/schemas/product.schema';
import { User, UserDocument } from '../users/schemas/user.schema';
import { DeliveriesService } from '../deliveries/deliveries.service';

@Injectable()
export class OrdersService {
  constructor(
    @InjectModel(Order.name) private orderModel: Model<OrderDocument>,
    @InjectModel(Product.name) private productModel: Model<ProductDocument>,
    @InjectModel(User.name) private userModel: Model<UserDocument>,
    private readonly deliveriesService: DeliveriesService,
  ) {}

  async create(userId: string, dto: CreateOrderDto): Promise<OrderDocument> {
    if (dto.paymentMethod && dto.paymentMethod !== PaymentMethod.COD) {
      throw new BadRequestException('Only COD is supported currently');
    }

    const productIds = dto.items.map((i) => i.productId);
    const products = await this.productModel
      .find({ _id: { $in: productIds }, isActive: true })
      .exec();
    if (products.length !== dto.items.length) {
      throw new BadRequestException('Some products are unavailable');
    }

    let subtotal = 0;
    const items = dto.items.map((item) => {
      const prod = products.find((p) => p._id.equals(item.productId))!;
      subtotal += prod.price * item.quantity;
      return {
        productId: prod._id,
        name: prod.name,
        price: prod.price,
        quantity: item.quantity,
      };
    });

    const deliveryFee = dto.type === OrderType.RIDE ? 0 : Math.max(subtotal * 0.1, 3); // 10% of subtotal, minimum 3 TND
    const total = subtotal + deliveryFee;

    const order = new this.orderModel({
      userId,
      items,
      subtotal,
      deliveryFee,
      total,
      paymentMethod: dto.paymentMethod || PaymentMethod.COD,
      type: dto.type || OrderType.MARKET,
      address: dto.address,
      region: dto.region,
      status: OrderStatus.CONFIRMED,
    });

    const saved = await order.save();
    await this.userModel.findByIdAndUpdate(userId, {
      $inc: { totalOrders: 1, lifetimeValue: total },
    });

    // Auto-create delivery for non-ride orders
    if (dto.type !== OrderType.RIDE && dto.address) {
      try {
        await this.deliveriesService.create(
          {
            pickupLocation: 'Store',
            deliveryAddress: dto.address,
            deliveryType: dto.type || OrderType.MARKET,
            region: dto.region,
          },
          userId,
        );
      } catch (error) {
        // Delivery creation failure shouldn't block order — log and continue
        console.warn('Auto-delivery creation failed for order:', saved._id, error);
      }
    }

    return saved;
  }

  async findAllForUser(userId: string): Promise<OrderDocument[]> {
    return this.orderModel
      .find({ userId })
      .sort({ createdAt: -1 })
      .populate('items.productId', 'name images price')
      .exec();
  }

  async findOneForUser(userId: string, id: string): Promise<OrderDocument> {
    const order = await this.orderModel.findOne({ _id: id, userId }).exec();
    if (!order) throw new NotFoundException('Order not found');
    return order;
  }

  async updateStatus(id: string, status: OrderStatus): Promise<OrderDocument> {
    const order = await this.orderModel.findByIdAndUpdate(id, { status }, { new: true }).exec();
    if (!order) throw new NotFoundException('Order not found');
    return order;
  }

  async reorder(userId: string, orderId: string): Promise<OrderDocument> {
    const previous = await this.orderModel.findOne({ _id: orderId, userId }).exec();
    if (!previous) {
      throw new NotFoundException('Order not found');
    }

    const productIds = previous.items.map((i) => i.productId.toString());
    const products = await this.productModel
      .find({ _id: { $in: productIds }, isActive: true })
      .exec();

    if (!products.length) {
      throw new BadRequestException('No products from the previous order are currently available');
    }

    const productById = new Map(products.map((p) => [p._id.toString(), p]));

    let subtotal = 0;
    const items = previous.items
      .filter((item) => productById.has(item.productId.toString()))
      .map((item) => {
        const prod = productById.get(item.productId.toString())!;
        subtotal += prod.price * item.quantity;
        return {
          productId: prod._id,
          name: prod.name,
          price: prod.price,
          quantity: item.quantity,
        };
      });

    const deliveryFee = previous.type === OrderType.RIDE ? 0 : Math.max(subtotal * 0.1, 3);
    const total = subtotal + deliveryFee;

    const reordered = new this.orderModel({
      userId,
      items,
      subtotal,
      deliveryFee,
      total,
      paymentMethod: PaymentMethod.COD,
      type: previous.type,
      address: previous.address,
      region: previous.region,
      status: OrderStatus.CONFIRMED,
      surgeMultiplier: previous.surgeMultiplier || 1,
    });

    const saved = await reordered.save();

    await this.userModel.findByIdAndUpdate(userId, {
      $inc: { totalOrders: 1, lifetimeValue: total },
    });

    if (previous.type !== OrderType.RIDE && previous.address) {
      try {
        await this.deliveriesService.create(
          {
            pickupLocation: 'Store',
            deliveryAddress: previous.address,
            deliveryType: previous.type,
            region: previous.region,
          },
          userId,
        );
      } catch (error) {
        console.warn('Auto-delivery creation failed for reordered order:', saved._id, error);
      }
    }

    return saved;
  }
}
