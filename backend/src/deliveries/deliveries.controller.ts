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
import { UpdateDeliveryStatusDto } from './dto/update-delivery-status.dto';
import { CalculateDeliveryCostDto } from './dto/calculate-delivery-cost.dto';
import { CompleteDeliveryDto } from './dto/complete-delivery.dto';
import { AddTipDto } from './dto/add-tip.dto';
import { RateDeliveryDto } from './dto/rate-delivery.dto';
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
  @Roles(UserRole.CUSTOMER, UserRole.ADMIN)
  findAll(@Request() req: AuthenticatedRequest): Promise<unknown> {
    if (req.user.role === UserRole.ADMIN) {
      return this.deliveriesService.findAll();
    }
    return this.deliveriesService.findAll(req.user.sub);
  }

  // Static routes MUST come before :id param routes
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

  @Get(':id')
  findOne(@Param('id') id: string, @Request() req: AuthenticatedRequest): Promise<unknown> {
    return this.deliveriesService.findOneVisibleToRequester(id, req.user.sub, req.user.role);
  }

  @Patch(':id/status')
  @Roles(UserRole.DRIVER)
  updateStatus(
    @Param('id') id: string,
    @Body() body: UpdateDeliveryStatusDto,
    @Request() req: AuthenticatedRequest,
  ): Promise<unknown> {
    return this.deliveriesService.updateStatus(id, body.status, req.user.sub);
  }

  @Post(':id/calculate-cost')
  @Roles(UserRole.CUSTOMER, UserRole.DRIVER, UserRole.ADMIN)
  calculateCost(
    @Param('id') id: string,
    @Body() body: CalculateDeliveryCostDto,
    @Request() req: AuthenticatedRequest,
  ): Promise<number> {
    return this.deliveriesService.calculateCost(
      id,
      body.distance,
      body.motorcycleId,
      body.region,
      req.user.sub,
      req.user.role,
    );
  }

  @Post(':id/accept')
  @Roles(UserRole.DRIVER)
  acceptDelivery(@Param('id') id: string, @Request() req: AuthenticatedRequest): Promise<unknown> {
    return this.deliveriesService.acceptDelivery(id, req.user.sub);
  }

  @Post(':id/start')
  @Roles(UserRole.DRIVER)
  startDelivery(@Param('id') id: string, @Request() req: AuthenticatedRequest): Promise<unknown> {
    return this.deliveriesService.startDelivery(id, req.user.sub);
  }

  @Post(':id/complete')
  @Roles(UserRole.DRIVER)
  completeDelivery(
    @Param('id') id: string,
    @Body() body: CompleteDeliveryDto,
    @Request() req: AuthenticatedRequest,
  ): Promise<unknown> {
    return this.deliveriesService.completeDelivery(id, req.user.sub, body.actualCost);
  }

  @Post(':id/cancel')
  @Roles(UserRole.CUSTOMER, UserRole.DRIVER, UserRole.ADMIN)
  cancelDelivery(@Param('id') id: string, @Request() req: AuthenticatedRequest): Promise<unknown> {
    return this.deliveriesService.cancelDelivery(id, req.user.sub, req.user.role);
  }

  @Post(':id/tip')
  @Roles(UserRole.CUSTOMER)
  addTip(
    @Param('id') id: string,
    @Body() body: AddTipDto,
    @Request() req: AuthenticatedRequest,
  ): Promise<unknown> {
    return this.deliveriesService.addTip(id, req.user.sub, body.tipAmount);
  }

  @Post(':id/rate')
  @Roles(UserRole.CUSTOMER)
  rateDelivery(
    @Param('id') id: string,
    @Body() body: RateDeliveryDto,
    @Request() req: AuthenticatedRequest,
  ): Promise<unknown> {
    return this.deliveriesService.rateDelivery(id, req.user.sub, body.rating, body.feedback);
  }
}
