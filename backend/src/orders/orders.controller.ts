import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  UseGuards,
  Request,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { OrdersService } from './orders.service';
import { CreateOrderDto } from './dto/create-order.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { UpdateOrderStatusDto } from './dto/update-order-status.dto';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { UserRole } from '../users/schemas/user.schema';
import { Request as ExpressRequest } from 'express';

interface AuthenticatedRequest extends ExpressRequest {
  user: { sub: string };
}

@Controller('orders')
@UseGuards(JwtAuthGuard, RolesGuard)
export class OrdersController {
  constructor(private readonly ordersService: OrdersService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @Roles(UserRole.CUSTOMER)
  create(@Body() dto: CreateOrderDto, @Request() req: AuthenticatedRequest) {
    return this.ordersService.create(req.user.sub, dto);
  }

  @Get()
  @Roles(UserRole.CUSTOMER)
  findMine(@Request() req: AuthenticatedRequest) {
    return this.ordersService.findAllForUser(req.user.sub);
  }

  @Get('history')
  @Roles(UserRole.CUSTOMER)
  findHistory(@Request() req: AuthenticatedRequest) {
    return this.ordersService.findAllForUser(req.user.sub);
  }

  @Get(':id')
  @Roles(UserRole.CUSTOMER)
  findOne(@Param('id') id: string, @Request() req: AuthenticatedRequest) {
    return this.ordersService.findOneForUser(req.user.sub, id);
  }

  @Patch(':id/status')
  @Roles(UserRole.ADMIN)
  updateStatus(@Param('id') id: string, @Body() body: UpdateOrderStatusDto) {
    return this.ordersService.updateStatus(id, body.status);
  }

  @Post(':id/reorder')
  @HttpCode(HttpStatus.CREATED)
  @Roles(UserRole.CUSTOMER)
  reorder(@Param('id') id: string, @Request() req: AuthenticatedRequest) {
    return this.ordersService.reorder(req.user.sub, id);
  }
}
