import { Controller, Get, Param, UseGuards, Request } from '@nestjs/common';
import { RecommendationsService } from './recommendations.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { UserRole } from '../users/schemas/user.schema';
import { Request as ExpressRequest } from 'express';

interface AuthenticatedRequest extends ExpressRequest {
  user: { sub: string };
}

@Controller()
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.CUSTOMER, UserRole.DRIVER, UserRole.ADMIN)
export class RecommendationsController {
  constructor(private readonly recommendationsService: RecommendationsService) {}

  @Get('recommendations')
  getMine(@Request() req: AuthenticatedRequest) {
    return this.recommendationsService.getUserRecommendations(req.user.sub);
  }

  @Get('products/:id/fbt')
  getFbt(@Param('id') id: string) {
    return this.recommendationsService.getFrequentlyBoughtTogether(id);
  }
}
