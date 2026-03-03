import { Body, Controller, Get, Param, Patch, Post, Delete, UseGuards, Request } from '@nestjs/common';
import { SurgeService } from './surge.service';
import { CreateSurgeRuleDto } from './dto/create-surge-rule.dto';
import { UpdateSurgeRuleDto } from './dto/update-surge-rule.dto';
import { PreviewSurgeDto } from './dto/preview-surge.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { UserRole } from '../users/schemas/user.schema';
import { Request as ExpressRequest } from 'express';

interface AuthenticatedRequest extends ExpressRequest {
  user: { sub: string };
}

@Controller('surge-rules')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.ADMIN)
export class SurgeController {
  constructor(private readonly surgeService: SurgeService) {}

  @Post()
  create(@Body() dto: CreateSurgeRuleDto, @Request() req: AuthenticatedRequest) {
    return this.surgeService.create(dto, req.user.sub);
  }

  @Get()
  findAll() {
    return this.surgeService.findAll();
  }

  @Patch(':id')
  update(
    @Param('id') id: string,
    @Body() dto: UpdateSurgeRuleDto,
    @Request() req: AuthenticatedRequest,
  ) {
    return this.surgeService.update(id, dto, req.user.sub);
  }

  @Post(':id/toggle')
  toggle(
    @Param('id') id: string,
    @Body('active') active: boolean,
    @Request() req: AuthenticatedRequest,
  ) {
    return this.surgeService.toggle(id, active, req.user.sub);
  }

  @Delete(':id')
  remove(@Param('id') id: string, @Request() req: AuthenticatedRequest) {
    return this.surgeService.remove(id, req.user.sub);
  }

  @Post('preview')
  preview(@Body() dto: PreviewSurgeDto) {
    const timestamp = dto.timestamp ? new Date(dto.timestamp) : new Date();
    const point =
      dto.latitude !== undefined && dto.longitude !== undefined
        ? { lat: dto.latitude, lng: dto.longitude }
        : undefined;
    return this.surgeService.preview(dto.region, timestamp, point);
  }
}
