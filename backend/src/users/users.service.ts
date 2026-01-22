import { Injectable, NotFoundException, BadRequestException, UnauthorizedException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import * as bcrypt from 'bcryptjs';
import { User, UserDocument, UserRole } from './schemas/user.schema';
import { UpdateProfileDto, ChangePasswordDto } from './dto/update-profile.dto';

@Injectable()
export class UsersService {
  constructor(@InjectModel(User.name) private userModel: Model<UserDocument>) {}

  async findByEmail(email: string): Promise<UserDocument | null> {
    return this.userModel.findOne({ email }).exec();
  }

  async findById(id: string): Promise<UserDocument | null> {
    console.log('Finding user by ID:', id);
    const user = await this.userModel.findById(id).exec();
    console.log('User found by ID:', user ? { id: user._id.toString(), email: user.email } : 'null');
    return user;
  }

  async findAll(): Promise<UserDocument[]> {
    return this.userModel.find().exec();
  }

  async create(
    email: string,
    password: string,
    name: string,
    role: UserRole = UserRole.CUSTOMER,
    phoneNumber?: string,
  ): Promise<UserDocument> {
    console.log('Creating user:', { email, name, role, phoneNumber });

    const user = new this.userModel({
      email,
      password,
      name,
      role,
      phoneNumber,
    });

    const savedUser = await user.save();
    console.log('User saved:', { id: savedUser._id.toString(), email: savedUser.email, role: savedUser.role });

    return savedUser;
  }

  async updateVerificationStatus(id: string, isVerified: boolean): Promise<UserDocument | null> {
    return this.userModel.findByIdAndUpdate(id, { isVerified }, { new: true }).exec();
  }

  async updateProfile(userId: string, updateData: UpdateProfileDto): Promise<UserDocument> {
    const user = await this.userModel.findById(userId).exec();
    if (!user) {
      throw new NotFoundException('User not found');
    }

    // Check if email is being changed and if it's already taken
    if (updateData.email && updateData.email !== user.email) {
      const existingUser = await this.userModel.findOne({ email: updateData.email }).exec();
      if (existingUser) {
        throw new BadRequestException('Email already in use');
      }
    }

    const updatedUser = await this.userModel
      .findByIdAndUpdate(userId, updateData, { new: true })
      .exec();

    if (!updatedUser) {
      throw new NotFoundException('User not found');
    }

    return updatedUser;
  }

  async changePassword(userId: string, changePasswordDto: ChangePasswordDto): Promise<void> {
    const user = await this.userModel.findById(userId).exec();
    if (!user) {
      throw new NotFoundException('User not found');
    }

    const isCurrentPasswordValid = await bcrypt.compare(
      changePasswordDto.currentPassword,
      user.password,
    );

    if (!isCurrentPasswordValid) {
      throw new UnauthorizedException('Current password is incorrect');
    }

    const hashedNewPassword = await bcrypt.hash(changePasswordDto.newPassword, 10);

    await this.userModel.findByIdAndUpdate(userId, { password: hashedNewPassword }).exec();
  }

  async updatePreferences(
    userId: string,
    preferences: Partial<User['preferences']>,
  ): Promise<UserDocument> {
    const user = await this.userModel.findById(userId).exec();
    if (!user) {
      throw new NotFoundException('User not found');
    }

    const currentPreferences = user.preferences || {
      notifications: {
        email: true,
        push: true,
        sms: false,
        deliveryUpdates: true,
        promotions: true,
      },
      language: 'en',
      theme: 'system',
      currency: 'TND',
    };

    const updatedPreferences: User['preferences'] = {
      ...currentPreferences,
      ...preferences,
      notifications: preferences?.notifications
        ? {
            ...currentPreferences.notifications,
            ...preferences.notifications,
          }
        : currentPreferences.notifications,
    };

    const updatedUser = await this.userModel
      .findByIdAndUpdate(userId, { preferences: updatedPreferences }, { new: true })
      .exec();

    if (!updatedUser) {
      throw new NotFoundException('User not found');
    }

    return updatedUser;
  }

  async deleteAccount(userId: string): Promise<void> {
    const user = await this.userModel.findById(userId).exec();
    if (!user) {
      throw new NotFoundException('User not found');
    }

    // Soft delete: mark as deleted instead of actually deleting
    await this.userModel.findByIdAndUpdate(userId, { email: `deleted_${Date.now()}_${user.email}` }).exec();
  }
}
