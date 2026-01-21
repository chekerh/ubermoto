import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Patch,
  UseGuards,
  Request,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { DeliveriesService } from './deliveries.service';
import { CreateDeliveryDto } from './dto/create-delivery.dto';
import { DeliveryStatus } from './schemas/delivery.schema';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { UserRole } from '../users/schemas/user.schema';

interface AuthenticatedRequest extends Request {
  user: {
    sub: string;
    email: string;
    role: UserRole;
  };
}

@ApiTags('deliveries')
@Controller('deliveries')
@UseGuards(JwtAuthGuard, RolesGuard)
export class DeliveriesController {
  constructor(private readonly deliveriesService: DeliveriesService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @Roles(UserRole.CUSTOMER)
  create(
    @Body() createDeliveryDto: CreateDeliveryDto,
    @Request() req: AuthenticatedRequest,
  ): Promise<unknown> {
    const userId = req.user.sub;
    return this.deliveriesService.create(createDeliveryDto, userId);
  }

  @Get()
  findAll(@Request() req: AuthenticatedRequest): Promise<unknown> {
    const userId = req.user.sub;
    return this.deliveriesService.findAll(userId);
  }

  @Get(':id')
  findOne(@Param('id') id: string): Promise<unknown> {
    return this.deliveriesService.findOne(id);
  }

  @Patch(':id/status')
  @Roles(UserRole.DRIVER)
  updateStatus(
    @Param('id') id: string,
    @Body() body: { status: DeliveryStatus },
  ): Promise<unknown> {
    return this.deliveriesService.updateStatus(id, body.status);
  }

  @Post(':id/calculate-cost')
  calculateCost(
    @Param('id') id: string,
    @Body() body: { distance: number; motorcycleId: string },
  ): Promise<number> {
    return this.deliveriesService.calculateCost(id, body.distance, body.motorcycleId);
  }

  @Post(':id/accept')
  @Roles(UserRole.DRIVER)
  acceptDelivery(
    @Param('id') id: string,
    @Request() req: AuthenticatedRequest,
  ): Promise<unknown> {
    return this.deliveriesService.acceptDelivery(id, req.user.sub);
  }

  @Post(':id/start')
  @Roles(UserRole.DRIVER)
  startDelivery(
    @Param('id') id: string,
    @Request() req: AuthenticatedRequest,
  ): Promise<unknown> {
    return this.deliveriesService.startDelivery(id, req.user.sub);
  }

  @Post(':id/complete')
  @Roles(UserRole.DRIVER)
  completeDelivery(
    @Param('id') id: string,
    @Body() body: { actualCost?: number },
    @Request() req: AuthenticatedRequest,
  ): Promise<unknown> {
    return this.deliveriesService.completeDelivery(id, req.user.sub, body.actualCost);
  }

  @Get('driver/available')
  @Roles(UserRole.DRIVER)
  getAvailableDeliveries(): Promise<unknown> {
    return this.deliveriesService.getAvailableDeliveries();
  }

  @Get('driver/active')
  @Roles(UserRole.DRIVER)
  getDriverDeliveries(@Request() req: AuthenticatedRequest): Promise<unknown> {
    return this.deliveriesService.getDriverDeliveries(req.user.sub);
  }
}
