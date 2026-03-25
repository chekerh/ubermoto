import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Query,
  UseGuards,
  HttpCode,
  HttpStatus,
  Request,
  ForbiddenException,
  NotFoundException,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { DriversService, CreateDriverDto } from './drivers.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { UserRole } from '../users/schemas/user.schema';
import { UploadDocumentsDto, UpdateDriverDocumentsDto } from './dto/upload-documents.dto';
import { UpdateAvailabilityDto } from './dto/update-availability.dto';
import { UpdateMotorcycleDto } from './dto/update-motorcycle.dto';
import { UpdateDriverRatingDto } from './dto/update-driver-rating.dto';
import { UpdateDriverVerificationDto } from './dto/update-driver-verification.dto';
import { UpdateDriverLocationDto } from './dto/update-driver-location.dto';
import { RequestPayoutDto } from './dto/request-payout.dto';
import { UpdateDriverScheduleDto } from './dto/update-driver-schedule.dto';

@ApiTags('drivers')
@Controller('drivers')
@UseGuards(JwtAuthGuard, RolesGuard)
export class DriversController {
  constructor(private readonly driversService: DriversService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @Roles(UserRole.DRIVER, UserRole.ADMIN)
  @ApiOperation({ summary: 'Create a driver profile' })
  @ApiResponse({
    status: 201,
    description: 'Driver profile created successfully',
  })
  @ApiResponse({ status: 404, description: 'User not found' })
  @ApiResponse({ status: 409, description: 'Driver profile already exists' })
  create(
    @Body() createDriverDto: CreateDriverDto,
    @Request() req: { user: { sub: string; role: UserRole } },
  ) {
    if (req.user.role !== UserRole.ADMIN && createDriverDto.userId !== req.user.sub) {
      throw new ForbiddenException(
        'You can only create a driver profile for your own user account',
      );
    }
    return this.driversService.create(createDriverDto);
  }

  @Get()
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get all drivers (Admin only)' })
  @ApiResponse({
    status: 200,
    description: 'List of all drivers',
  })
  findAll() {
    return this.driversService.findAll();
  }

  // Static routes must be registered before :id
  @Get('leaderboard')
  @ApiOperation({ summary: 'Get top earning drivers leaderboard' })
  @ApiResponse({
    status: 200,
    description: 'Leaderboard of top drivers by earnings',
  })
  getLeaderboard(
    @Query('period') period: 'daily' | 'weekly' | 'monthly' = 'monthly',
    @Query('limit') limit?: number,
  ) {
    return this.driversService.getLeaderboard(
      period,
      limit ? parseInt(limit.toString(), 10) : undefined,
    );
  }

  @Get('user/:userId')
  @Roles(UserRole.DRIVER, UserRole.ADMIN)
  @ApiOperation({ summary: 'Get driver profile by user ID' })
  @ApiResponse({
    status: 200,
    description: 'Driver profile',
  })
  async findByUserId(
    @Param('userId') userId: string,
    @Request() req: { user: { sub: string; role: UserRole } },
  ) {
    await this.driversService.assertAdminOrMatchingUser(userId, req.user.sub, req.user.role);
    const driver = await this.driversService.findByUserId(userId);
    if (!driver) {
      throw new NotFoundException('Driver profile not found');
    }
    return driver;
  }

  @Get(':id')
  @Roles(UserRole.DRIVER, UserRole.ADMIN)
  @ApiOperation({ summary: 'Get driver by ID' })
  @ApiResponse({
    status: 200,
    description: 'Driver details',
  })
  @ApiResponse({ status: 404, description: 'Driver not found' })
  async findOne(
    @Param('id') id: string,
    @Request() req: { user: { sub: string; role: UserRole } },
  ) {
    await this.driversService.assertAdminOrSelfDriverRecord(id, req.user.sub, req.user.role);
    return this.driversService.findOne(id);
  }

  @Patch(':id/availability')
  @Roles(UserRole.DRIVER, UserRole.ADMIN)
  @ApiOperation({ summary: 'Update driver availability' })
  @ApiResponse({
    status: 200,
    description: 'Driver availability updated',
  })
  @ApiResponse({ status: 404, description: 'Driver not found' })
  async updateAvailability(
    @Param('id') id: string,
    @Body() body: UpdateAvailabilityDto,
    @Request() req: { user: { sub: string; role: UserRole } },
  ) {
    await this.driversService.assertAdminOrSelfDriverRecord(id, req.user.sub, req.user.role);
    return this.driversService.updateAvailability(id, body.isAvailable);
  }

  @Patch(':id/motorcycle')
  @Roles(UserRole.DRIVER, UserRole.ADMIN)
  @ApiOperation({ summary: 'Update driver motorcycle' })
  @ApiResponse({
    status: 200,
    description: 'Driver motorcycle updated',
  })
  @ApiResponse({ status: 404, description: 'Driver not found' })
  async updateMotorcycle(
    @Param('id') id: string,
    @Body() body: UpdateMotorcycleDto,
    @Request() req: { user: { sub: string; role: UserRole } },
  ) {
    await this.driversService.assertAdminOrSelfDriverRecord(id, req.user.sub, req.user.role);
    return this.driversService.updateMotorcycle(id, body.motorcycleId);
  }

  @Patch(':id/rating')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Update driver rating (admin)' })
  @ApiResponse({
    status: 200,
    description: 'Driver rating updated',
  })
  @ApiResponse({ status: 404, description: 'Driver not found' })
  updateRating(@Param('id') id: string, @Body() body: UpdateDriverRatingDto) {
    return this.driversService.updateRating(id, body.rating);
  }

  @Post(':id/deliveries/complete')
  @Roles(UserRole.ADMIN)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Increment driver delivery count (admin / system)' })
  @ApiResponse({
    status: 200,
    description: 'Delivery count incremented',
  })
  @ApiResponse({ status: 404, description: 'Driver not found' })
  incrementDeliveryCount(@Param('id') id: string) {
    return this.driversService.incrementDeliveryCount(id);
  }

  @Post(':id/documents')
  @HttpCode(HttpStatus.OK)
  @Roles(UserRole.DRIVER, UserRole.ADMIN)
  @ApiOperation({ summary: 'Upload driver documents' })
  @ApiResponse({
    status: 200,
    description: 'Documents uploaded successfully',
  })
  @ApiResponse({ status: 404, description: 'Driver not found' })
  async uploadDocuments(
    @Param('id') id: string,
    @Body() uploadDocumentsDto: UploadDocumentsDto,
    @Request() req: { user: { sub: string; role: UserRole } },
  ) {
    await this.driversService.assertAdminOrSelfDriverRecord(id, req.user.sub, req.user.role);
    return this.driversService.uploadDocuments(id, uploadDocumentsDto);
  }

  @Patch(':id/documents')
  @HttpCode(HttpStatus.OK)
  @Roles(UserRole.DRIVER, UserRole.ADMIN)
  @ApiOperation({ summary: 'Update driver documents' })
  @ApiResponse({
    status: 200,
    description: 'Documents updated successfully',
  })
  @ApiResponse({ status: 404, description: 'Driver not found' })
  async updateDocuments(
    @Param('id') id: string,
    @Body() updateDocumentsDto: UpdateDriverDocumentsDto,
    @Request() req: { user: { sub: string; role: UserRole } },
  ) {
    await this.driversService.assertAdminOrSelfDriverRecord(id, req.user.sub, req.user.role);
    return this.driversService.updateDocuments(id, updateDocumentsDto);
  }

  @Patch(':id/verification')
  @Roles(UserRole.ADMIN)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Update driver verification status (Admin only)' })
  @ApiResponse({
    status: 200,
    description: 'Verification status updated',
  })
  @ApiResponse({ status: 404, description: 'Driver not found' })
  updateVerificationStatus(@Param('id') id: string, @Body() body: UpdateDriverVerificationDto) {
    return this.driversService.updateVerificationStatus(id, body.isVerified);
  }

  // ── Earnings & Performance ──────────────────────────────────────────────

  @Get(':id/earnings')
  @Roles(UserRole.DRIVER, UserRole.ADMIN)
  @ApiOperation({ summary: 'Get driver earnings breakdown' })
  @ApiResponse({
    status: 200,
    description: 'Earnings breakdown by period',
  })
  async getEarnings(
    @Param('id') id: string,
    @Query('period') period: 'daily' | 'weekly' | 'monthly' = 'monthly',
    @Request() req: { user: { sub: string; role: UserRole } },
  ) {
    await this.driversService.assertAdminOrSelfDriverRecord(id, req.user.sub, req.user.role);
    return this.driversService.getEarnings(id, period);
  }

  @Get(':id/performance')
  @Roles(UserRole.DRIVER, UserRole.ADMIN)
  @ApiOperation({ summary: 'Get driver performance metrics' })
  @ApiResponse({
    status: 200,
    description: 'Performance metrics including completion rate and rating',
  })
  async getPerformance(
    @Param('id') id: string,
    @Request() req: { user: { sub: string; role: UserRole } },
  ) {
    await this.driversService.assertAdminOrSelfDriverRecord(id, req.user.sub, req.user.role);
    return this.driversService.getPerformance(id);
  }

  @Get(':id/deliveries/history')
  @Roles(UserRole.DRIVER, UserRole.ADMIN)
  @ApiOperation({ summary: 'Get driver delivery history with pagination' })
  @ApiResponse({
    status: 200,
    description: 'Paginated delivery history',
  })
  async getDeliveryHistory(
    @Param('id') id: string,
    @Request() req: { user: { sub: string; role: UserRole } },
    @Query('skip') skip?: number,
    @Query('limit') limit?: number,
    @Query('status') status?: string,
  ) {
    await this.driversService.assertAdminOrSelfDriverRecord(id, req.user.sub, req.user.role);
    return this.driversService.getDeliveryHistory(id, {
      skip: skip ? parseInt(skip.toString(), 10) : undefined,
      limit: limit ? parseInt(limit.toString(), 10) : undefined,
      status: status as any,
    });
  }

  @Patch(':id/location')
  @Roles(UserRole.DRIVER)
  @ApiOperation({ summary: 'Update driver current location' })
  @ApiResponse({
    status: 200,
    description: 'Location updated successfully',
  })
  async updateLocation(
    @Param('id') id: string,
    @Body() body: UpdateDriverLocationDto,
    @Request() req: { user: { sub: string; role: UserRole } },
  ) {
    await this.driversService.assertAdminOrSelfDriverRecord(id, req.user.sub, req.user.role);
    return this.driversService.updateLocation(id, body.latitude, body.longitude);
  }

  @Post(':id/earnings/withdraw')
  @Roles(UserRole.DRIVER)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Request payout withdrawal' })
  @ApiResponse({
    status: 200,
    description: 'Payout request submitted successfully',
  })
  @ApiResponse({
    status: 400,
    description: 'Invalid amount or insufficient balance',
  })
  async requestPayout(
    @Param('id') id: string,
    @Body() body: RequestPayoutDto,
    @Request() req: { user: { sub: string; role: UserRole } },
  ) {
    await this.driversService.assertAdminOrSelfDriverRecord(id, req.user.sub, req.user.role);
    return this.driversService.requestPayout(id, body.amount, body.paymentMethod);
  }

  @Get(':id/earnings/history')
  @Roles(UserRole.DRIVER, UserRole.ADMIN)
  @ApiOperation({ summary: 'Get driver payout history' })
  @ApiResponse({
    status: 200,
    description: 'Paginated payout history',
  })
  async getPayoutHistory(
    @Param('id') id: string,
    @Request() req: { user: { sub: string; role: UserRole } },
    @Query('skip') skip?: number,
    @Query('limit') limit?: number,
  ) {
    await this.driversService.assertAdminOrSelfDriverRecord(id, req.user.sub, req.user.role);
    return this.driversService.getPayoutHistory(id, {
      skip: skip ? parseInt(skip.toString(), 10) : undefined,
      limit: limit ? parseInt(limit.toString(), 10) : undefined,
    });
  }

  @Get(':id/schedule')
  @Roles(UserRole.DRIVER, UserRole.ADMIN)
  @ApiOperation({ summary: 'Get driver availability schedule' })
  @ApiResponse({
    status: 200,
    description: 'Driver schedule with working hours',
  })
  async getSchedule(
    @Param('id') id: string,
    @Request() req: { user: { sub: string; role: UserRole } },
  ) {
    await this.driversService.assertAdminOrSelfDriverRecord(id, req.user.sub, req.user.role);
    return this.driversService.getSchedule(id);
  }

  @Patch(':id/schedule')
  @Roles(UserRole.DRIVER)
  @ApiOperation({ summary: 'Update driver availability schedule' })
  @ApiResponse({
    status: 200,
    description: 'Schedule updated successfully',
  })
  async updateSchedule(
    @Param('id') id: string,
    @Body() schedule: UpdateDriverScheduleDto,
    @Request() req: { user: { sub: string; role: UserRole } },
  ) {
    await this.driversService.assertAdminOrSelfDriverRecord(id, req.user.sub, req.user.role);
    return this.driversService.updateSchedule(id, schedule);
  }
}
