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

interface AuthenticatedRequest extends Request {
  user: {
    sub: string;
    email: string;
  };
}

@ApiTags('deliveries')
@Controller('deliveries')
@UseGuards(JwtAuthGuard)
export class DeliveriesController {
  constructor(private readonly deliveriesService: DeliveriesService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
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
}
