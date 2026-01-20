import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Motorcycle, MotorcycleDocument } from './schemas/motorcycle.schema';
import { CreateMotorcycleDto } from './dto/create-motorcycle.dto';
import { UpdateMotorcycleDto } from './dto/update-motorcycle.dto';

@Injectable()
export class MotorcyclesService {
  constructor(
    @InjectModel(Motorcycle.name)
    private motorcycleModel: Model<MotorcycleDocument>,
  ) {}

  async create(createMotorcycleDto: CreateMotorcycleDto): Promise<MotorcycleDocument> {
    const motorcycle = new this.motorcycleModel(createMotorcycleDto);
    return motorcycle.save();
  }

  async findAll(): Promise<MotorcycleDocument[]> {
    return this.motorcycleModel.find().exec();
  }

  async findOne(id: string): Promise<MotorcycleDocument> {
    const motorcycle = await this.motorcycleModel.findById(id).exec();
    if (!motorcycle) {
      throw new NotFoundException(`Motorcycle with ID ${id} not found`);
    }
    return motorcycle;
  }

  async update(id: string, updateMotorcycleDto: UpdateMotorcycleDto): Promise<MotorcycleDocument> {
    const motorcycle = await this.motorcycleModel
      .findByIdAndUpdate(id, updateMotorcycleDto, { new: true })
      .exec();
    if (!motorcycle) {
      throw new NotFoundException(`Motorcycle with ID ${id} not found`);
    }
    return motorcycle;
  }

  async remove(id: string): Promise<void> {
    const result = await this.motorcycleModel.findByIdAndDelete(id).exec();
    if (!result) {
      throw new NotFoundException(`Motorcycle with ID ${id} not found`);
    }
  }

  async findByModel(model: string): Promise<MotorcycleDocument | null> {
    return this.motorcycleModel.findOne({ model }).exec();
  }
}
