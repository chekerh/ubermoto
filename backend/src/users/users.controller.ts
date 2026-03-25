import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
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
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { UserRole } from './schemas/user.schema';
import { BillingService } from '../billing/billing.service';

interface AuthenticatedRequest extends Request {
  user: {
    sub: string;
    email: string;
    role: string;
  };
}

@ApiTags('users')
@Controller('users')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth()
export class UsersController {
  constructor(
    private readonly usersService: UsersService,
    private readonly billingService: BillingService,
  ) {}

  @Get('me')
  @ApiOperation({ summary: 'Get current user profile' })
  @ApiResponse({
    status: 200,
    description: 'User profile retrieved successfully',
  })
  async getProfile(@Request() req: AuthenticatedRequest): Promise<any> {
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
  ): Promise<Record<string, any>> {
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
  ): Promise<void> {
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
    @Body() preferences: Record<string, boolean>,
  ): Promise<Record<string, any>> {
    const updatedUser = await this.usersService.updatePreferences(req.user.sub, preferences);
    return updatedUser?.preferences || {};
  }

  @Get('me/preferences')
  @ApiOperation({ summary: 'Get user preferences' })
  @ApiResponse({
    status: 200,
    description: 'Preferences retrieved successfully',
  })
  async getPreferences(
    @Request() req: AuthenticatedRequest,
  ): Promise<Record<string, any> | undefined> {
    const user = await this.usersService.findById(req.user.sub);
    if (!user) {
      throw new NotFoundException('User not found');
    }
    return (
      user.preferences || {
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
      }
    );
  }

  @Get('favorites')
  @ApiOperation({ summary: 'Get user favorite products' })
  @ApiResponse({
    status: 200,
    description: 'Favorite products retrieved successfully',
  })
  async getFavorites(@Request() req: AuthenticatedRequest): Promise<unknown[]> {
    return this.usersService.getFavorites(req.user.sub);
  }

  @Post('favorites/:productId')
  @ApiOperation({ summary: 'Add a product to favorites' })
  @ApiResponse({
    status: 200,
    description: 'Product added to favorites',
  })
  async addFavorite(
    @Request() req: AuthenticatedRequest,
    @Param('productId') productId: string,
  ): Promise<{ success: boolean; message: string }> {
    return this.usersService.addFavorite(req.user.sub, productId);
  }

  @Delete('favorites/:productId')
  @ApiOperation({ summary: 'Remove a product from favorites' })
  @ApiResponse({
    status: 200,
    description: 'Product removed from favorites',
  })
  async removeFavorite(
    @Request() req: AuthenticatedRequest,
    @Param('productId') productId: string,
  ): Promise<{ success: boolean; message: string }> {
    return this.usersService.removeFavorite(req.user.sub, productId);
  }

  @Delete('me')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete current user account' })
  @ApiResponse({
    status: 204,
    description: 'Account deleted successfully',
  })
  async deleteAccount(@Request() req: AuthenticatedRequest): Promise<{ message: string }> {
    await this.usersService.deleteAccount(req.user.sub);
    return { message: 'Account deleted successfully' };
  }

  @Get('debug')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Debug endpoint to check users (Admin only)' })
  async debug(): Promise<{ count: number; users: unknown[] }> {
    const allUsers = await this.usersService.findAll();
    return {
      count: allUsers.length,
      users: allUsers.map((u) => ({
        id: u._id.toString(),
        email: u.email,
        role: u.role,
        isVerified: u.isVerified,
      })),
    };
  }

  @Get('me/entitlements')
  @ApiOperation({ summary: 'Get current user entitlements (v1: role-based baseline)' })
  @ApiResponse({ status: 200, description: 'Entitlements payload' })
  getEntitlements(@Request() req: AuthenticatedRequest) {
    return this.billingService.getEntitlementsForUser(req.user.sub, req.user.role);
  }
}
