import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Address, AddressDocument } from './schemas/address.schema';
import { CreateAddressDto, UpdateAddressDto } from './dto/create-address.dto';

@Injectable()
export class AddressesService {
  constructor(@InjectModel(Address.name) private addressModel: Model<AddressDocument>) {}

  async findAllByUserId(userId: string): Promise<AddressDocument[]> {
    return this.addressModel.find({ userId }).sort({ isDefault: -1, createdAt: -1 }).exec();
  }

  async findOne(id: string, userId: string): Promise<AddressDocument> {
    const address = await this.addressModel.findOne({ _id: id, userId }).exec();
    if (!address) {
      throw new NotFoundException('Address not found');
    }
    return address;
  }

  async create(userId: string, createAddressDto: CreateAddressDto): Promise<AddressDocument> {
    // If setting as default, unset other default addresses
    if (createAddressDto.isDefault) {
      await this.addressModel.updateMany({ userId, isDefault: true }, { isDefault: false }).exec();
    }

    const address = new this.addressModel({
      ...createAddressDto,
      userId,
    });

    return address.save();
  }

  async update(
    id: string,
    userId: string,
    updateAddressDto: UpdateAddressDto,
  ): Promise<AddressDocument> {
    // Verify address exists and belongs to user
    await this.findOne(id, userId);

    // If setting as default, unset other default addresses
    if (updateAddressDto.isDefault === true) {
      await this.addressModel
        .updateMany({ userId, _id: { $ne: id }, isDefault: true }, { isDefault: false })
        .exec();
    }

    const updatedAddress = await this.addressModel
      .findByIdAndUpdate(id, updateAddressDto, { new: true })
      .exec();

    if (!updatedAddress) {
      throw new NotFoundException('Address not found');
    }

    return updatedAddress;
  }

  async delete(id: string, userId: string): Promise<void> {
    // Verify address exists and belongs to user
    await this.findOne(id, userId);
    await this.addressModel.findByIdAndDelete(id).exec();
  }

  async setDefault(id: string, userId: string): Promise<AddressDocument> {
    // Verify address exists and belongs to user
    await this.findOne(id, userId);

    // Unset other default addresses
    await this.addressModel
      .updateMany({ userId, _id: { $ne: id }, isDefault: true }, { isDefault: false })
      .exec();

    // Set this address as default
    const updatedAddress = await this.addressModel
      .findByIdAndUpdate(id, { isDefault: true }, { new: true })
      .exec();

    if (!updatedAddress) {
      throw new NotFoundException('Address not found');
    }

    return updatedAddress;
  }
}
