import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { DriversService, CreateDriverDto } from './drivers.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { UserRole } from '../users/schemas/user.schema';
import { UploadDocumentsDto, UpdateDriverDocumentsDto } from './dto/upload-documents.dto';

@ApiTags('drivers')
@Controller('drivers')
@UseGuards(JwtAuthGuard, RolesGuard)
export class DriversController {
  constructor(private readonly driversService: DriversService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Create a driver profile' })
  @ApiResponse({
    status: 201,
    description: 'Driver profile created successfully',
  })
  @ApiResponse({ status: 404, description: 'User not found' })
  @ApiResponse({ status: 409, description: 'Driver profile already exists' })
  create(@Body() createDriverDto: CreateDriverDto) {
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

  @Get(':id')
  @ApiOperation({ summary: 'Get driver by ID' })
  @ApiResponse({
    status: 200,
    description: 'Driver details',
  })
  @ApiResponse({ status: 404, description: 'Driver not found' })
  findOne(@Param('id') id: string) {
    return this.driversService.findOne(id);
  }

  @Get('user/:userId')
  @ApiOperation({ summary: 'Get driver profile by user ID' })
  @ApiResponse({
    status: 200,
    description: 'Driver profile',
  })
  findByUserId(@Param('userId') userId: string) {
    return this.driversService.findByUserId(userId);
  }

  @Patch(':id/availability')
  @ApiOperation({ summary: 'Update driver availability' })
  @ApiResponse({
    status: 200,
    description: 'Driver availability updated',
  })
  @ApiResponse({ status: 404, description: 'Driver not found' })
  updateAvailability(
    @Param('id') id: string,
    @Body() body: { isAvailable: boolean },
  ) {
    return this.driversService.updateAvailability(id, body.isAvailable);
  }

  @Patch(':id/motorcycle')
  @ApiOperation({ summary: 'Update driver motorcycle' })
  @ApiResponse({
    status: 200,
    description: 'Driver motorcycle updated',
  })
  @ApiResponse({ status: 404, description: 'Driver not found' })
  updateMotorcycle(
    @Param('id') id: string,
    @Body() body: { motorcycleId: string },
  ) {
    return this.driversService.updateMotorcycle(id, body.motorcycleId);
  }

  @Patch(':id/rating')
  @ApiOperation({ summary: 'Update driver rating' })
  @ApiResponse({
    status: 200,
    description: 'Driver rating updated',
  })
  @ApiResponse({ status: 404, description: 'Driver not found' })
  updateRating(
    @Param('id') id: string,
    @Body() body: { rating: number },
  ) {
    return this.driversService.updateRating(id, body.rating);
  }

  @Post(':id/deliveries/complete')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Increment driver delivery count' })
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
  @ApiOperation({ summary: 'Upload driver documents' })
  @ApiResponse({
    status: 200,
    description: 'Documents uploaded successfully',
  })
  @ApiResponse({ status: 404, description: 'Driver not found' })
  uploadDocuments(
    @Param('id') id: string,
    @Body() uploadDocumentsDto: UploadDocumentsDto,
  ) {
    return this.driversService.uploadDocuments(id, uploadDocumentsDto);
  }

  @Patch(':id/documents')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Update driver documents' })
  @ApiResponse({
    status: 200,
    description: 'Documents updated successfully',
  })
  @ApiResponse({ status: 404, description: 'Driver not found' })
  updateDocuments(
    @Param('id') id: string,
    @Body() updateDocumentsDto: UpdateDriverDocumentsDto,
  ) {
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
  updateVerificationStatus(
    @Param('id') id: string,
    @Body() body: { isVerified: boolean },
  ) {
    return this.driversService.updateVerificationStatus(id, body.isVerified);
  }
}