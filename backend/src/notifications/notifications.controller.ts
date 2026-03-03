import { Body, Controller, Get, Post, UseGuards, Request } from '@nestjs/common';
import { NotificationsService } from './notifications.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Request as ExpressRequest } from 'express';

interface AuthenticatedRequest extends ExpressRequest {
  user: { sub: string };
}

@Controller('notification-preferences')
@UseGuards(JwtAuthGuard, RolesGuard)
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @Get()
  getMine(@Request() req: AuthenticatedRequest) {
    return this.notificationsService.getPreferences(req.user.sub);
  }

  @Post()
  updateMine(@Body('categories') categories: string[], @Request() req: AuthenticatedRequest) {
    return this.notificationsService.updatePreferences(req.user.sub, categories || []);
  }
}
