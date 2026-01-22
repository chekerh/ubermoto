import {
  Controller,
  Get,
  Patch,
  Delete,
  Body,
  UseGuards,
  Request,
  HttpCode,
  HttpStatus,
  NotFoundException,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { UsersService } from './users.service';
import { UpdateProfileDto, ChangePasswordDto } from './dto/update-profile.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

interface AuthenticatedRequest extends Request {
  user: {
    sub: string;
    email: string;
    role: string;
  };
}

@ApiTags('users')
@Controller('users')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get('me')
  @ApiOperation({ summary: 'Get current user profile' })
  @ApiResponse({
    status: 200,
    description: 'User profile retrieved successfully',
  })
  async getProfile(@Request() req: AuthenticatedRequest) {
    const user = await this.usersService.findById(req.user.sub);
    if (!user) {
      throw new NotFoundException('User not found');
    }

    // Remove password from response
    const userObj = user.toObject();
    delete userObj.password;
    return userObj;
  }

  @Patch('me')
  @ApiOperation({ summary: 'Update current user profile' })
  @ApiResponse({
    status: 200,
    description: 'Profile updated successfully',
  })
  async updateProfile(
    @Request() req: AuthenticatedRequest,
    @Body() updateProfileDto: UpdateProfileDto,
  ) {
    const updatedUser = await this.usersService.updateProfile(req.user.sub, updateProfileDto);
    const userObj = updatedUser.toObject();
    delete userObj.password;
    return userObj;
  }

  @Patch('me/password')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Change user password' })
  @ApiResponse({
    status: 204,
    description: 'Password changed successfully',
  })
  @ApiResponse({
    status: 401,
    description: 'Current password is incorrect',
  })
  async changePassword(
    @Request() req: AuthenticatedRequest,
    @Body() changePasswordDto: ChangePasswordDto,
  ) {
    await this.usersService.changePassword(req.user.sub, changePasswordDto);
  }

  @Patch('me/preferences')
  @ApiOperation({ summary: 'Update user preferences' })
  @ApiResponse({
    status: 200,
    description: 'Preferences updated successfully',
  })
  async updatePreferences(
    @Request() req: AuthenticatedRequest,
    @Body() preferences: any,
  ) {
    const updatedUser = await this.usersService.updatePreferences(req.user.sub, preferences);
    return updatedUser.preferences;
  }

  @Get('me/preferences')
  @ApiOperation({ summary: 'Get user preferences' })
  @ApiResponse({
    status: 200,
    description: 'Preferences retrieved successfully',
  })
  async getPreferences(@Request() req: AuthenticatedRequest) {
    const user = await this.usersService.findById(req.user.sub);
    if (!user) {
      throw new NotFoundException('User not found');
    }
    return user.preferences || {
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
  }

  @Delete('me')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete current user account' })
  @ApiResponse({
    status: 204,
    description: 'Account deleted successfully',
  })
  async deleteAccount(@Request() req: AuthenticatedRequest) {
    await this.usersService.deleteAccount(req.user.sub);
  }

  @Get('debug')
  @ApiOperation({ summary: 'Debug endpoint to check users' })
  async debug() {
    const allUsers = await this.usersService.findAll();
    return {
      count: allUsers.length,
      users: allUsers.map(u => ({
        id: u._id.toString(),
        email: u.email,
        role: u.role,
        isVerified: u.isVerified
      }))
    };
  }
}
