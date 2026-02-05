import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Patch,
  UseGuards,
  HttpCode,
  HttpStatus,
  Request,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { AdminService } from './admin.service';
import { DocumentStatus } from '../documents/schemas/document.schema';
import { RolesGuard } from '../auth/guards/roles.guard';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { UserRole } from '../users/schemas/user.schema';

interface AuthenticatedRequest extends Request {
  user: {
    sub: string;
    email: string;
    role: UserRole;
  };
}

@ApiTags('admin')
@Controller('admin')
@UseGuards(RolesGuard)
@Roles(UserRole.ADMIN)
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  @Get('dashboard')
  @ApiOperation({ summary: 'Get admin dashboard statistics' })
  @ApiResponse({
    status: 200,
    description: 'Admin dashboard data',
  })
  getDashboard() {
    return this.adminService.getDashboardStats();
  }

  @Get('drivers/pending')
  @ApiOperation({ summary: 'Get drivers pending verification' })
  @ApiResponse({
    status: 200,
    description: 'List of drivers pending verification',
  })
  getPendingDrivers() {
    return this.adminService.getPendingDrivers();
  }

  @Get('documents/pending')
  @ApiOperation({ summary: 'Get all pending documents for review' })
  @ApiResponse({
    status: 200,
    description: 'List of pending documents',
  })
  getPendingDocuments() {
    return this.adminService.getPendingDocuments();
  }

  @Post('drivers/:driverId/verify')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Verify a driver account' })
  @ApiResponse({
    status: 200,
    description: 'Driver verified successfully',
  })
  @ApiResponse({ status: 404, description: 'Driver not found' })
  verifyDriver(@Param('driverId') driverId: string, @Request() req: AuthenticatedRequest) {
    return this.adminService.verifyDriver(driverId, req.user.sub);
  }

  @Post('drivers/:driverId/reject')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Reject a driver account' })
  @ApiResponse({
    status: 200,
    description: 'Driver rejected successfully',
  })
  @ApiResponse({ status: 404, description: 'Driver not found' })
  rejectDriver(
    @Param('driverId') driverId: string,
    @Body() body: { reason: string },
    @Request() req: AuthenticatedRequest,
  ) {
    return this.adminService.rejectDriver(driverId, body.reason, req.user.sub);
  }

  @Patch('documents/:documentId/status')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Update document status' })
  @ApiResponse({
    status: 200,
    description: 'Document status updated',
  })
  @ApiResponse({ status: 404, description: 'Document not found' })
  updateDocumentStatus(
    @Param('documentId') documentId: string,
    @Body() body: { status: DocumentStatus; rejectionReason?: string },
    @Request() req: AuthenticatedRequest,
  ) {
    return this.adminService.updateDocumentStatus(
      documentId,
      body.status,
      req.user.sub,
      body.rejectionReason,
    );
  }

  @Get('deliveries/stats')
  @ApiOperation({ summary: 'Get delivery statistics' })
  @ApiResponse({
    status: 200,
    description: 'Delivery statistics',
  })
  getDeliveryStats() {
    return this.adminService.getDeliveryStats();
  }

  @Get('users/stats')
  @ApiOperation({ summary: 'Get user statistics' })
  @ApiResponse({
    status: 200,
    description: 'User statistics',
  })
  getUserStats() {
    return this.adminService.getUserStats();
  }
}
