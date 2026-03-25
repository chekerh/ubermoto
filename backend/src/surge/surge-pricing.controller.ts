import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { UserRole } from '../users/schemas/user.schema';
import { SurgeService } from './surge.service';

@ApiTags('surge-pricing')
@Controller('surge-pricing')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.CUSTOMER, UserRole.DRIVER, UserRole.ADMIN)
export class SurgePricingController {
  constructor(private readonly surgeService: SurgeService) {}

  @Get('current')
  @ApiOperation({ summary: 'Get current surge multiplier for a region' })
  @ApiResponse({ status: 200, description: 'Current surge multiplier' })
  async getCurrent(
    @Query('region') region: string,
    @Query('latitude') latitude?: number,
    @Query('longitude') longitude?: number,
  ) {
    const now = new Date();
    const point =
      latitude !== undefined && longitude !== undefined
        ? { lat: Number(latitude), lng: Number(longitude) }
        : undefined;

    const multiplier = await this.surgeService.getMultiplierFor(region, now, point);
    return {
      region,
      multiplier,
      timestamp: now,
    };
  }
}
