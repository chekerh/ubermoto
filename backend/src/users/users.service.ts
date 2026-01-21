import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { User, UserDocument, UserRole } from './schemas/user.schema';

@Injectable()
export class UsersService {
  constructor(@InjectModel(User.name) private userModel: Model<UserDocument>) {}

  async findByEmail(email: string): Promise<UserDocument | null> {
    return this.userModel.findOne({ email }).exec();
  }

  async findById(id: string): Promise<UserDocument | null> {
    return this.userModel.findById(id).exec();
  }

  async create(
    email: string,
    password: string,
    name: string,
    role: UserRole = UserRole.CUSTOMER,
    phoneNumber?: string,
  ): Promise<UserDocument> {
    const user = new this.userModel({
      email,
      password,
      name,
      role,
      phoneNumber,
    });
    return user.save();
  }

  async updateVerificationStatus(id: string, isVerified: boolean): Promise<UserDocument | null> {
    return this.userModel.findByIdAndUpdate(id, { isVerified }, { new: true }).exec();
  }
}
