import {
  Controller,
  Get,
  Post,
  Delete,
  Param,
  Query,
  Request,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiQuery } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { NotificationInboxService } from './notification-inbox.service';
import { Request as ExpressRequest } from 'express';

interface AuthenticatedRequest extends ExpressRequest {
  user: { sub: string };
}

@ApiTags('notifications')
@Controller('notifications')
@UseGuards(JwtAuthGuard, RolesGuard)
export class NotificationInboxController {
  constructor(private readonly notificationInboxService: NotificationInboxService) {}

  @Get()
  @ApiOperation({ summary: "Get authenticated user's notification inbox" })
  @ApiResponse({ status: 200, description: 'Paginated list of notifications with unread count' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  getMyNotifications(
    @Request() req: AuthenticatedRequest,
    @Query('page') page = '1',
    @Query('limit') limit = '20',
  ) {
    return this.notificationInboxService.findAllForUser(req.user.sub, Number(page), Number(limit));
  }

  @Post(':id/read')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Mark a notification as read' })
  @ApiResponse({ status: 200, description: 'Notification marked as read' })
  @ApiResponse({ status: 404, description: 'Notification not found' })
  markAsRead(@Param('id') id: string, @Request() req: AuthenticatedRequest) {
    return this.notificationInboxService.markAsRead(id, req.user.sub);
  }

  @Post('read-all')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Mark all notifications as read' })
  @ApiResponse({ status: 200, description: 'All notifications marked as read' })
  markAllAsRead(@Request() req: AuthenticatedRequest) {
    return this.notificationInboxService.markAllAsRead(req.user.sub);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Delete a notification' })
  @ApiResponse({ status: 200, description: 'Notification deleted' })
  @ApiResponse({ status: 404, description: 'Notification not found' })
  deleteNotification(@Param('id') id: string, @Request() req: AuthenticatedRequest) {
    return this.notificationInboxService.delete(id, req.user.sub);
  }
}
