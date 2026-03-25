import { Body, Controller, Get, Post, Query, UseGuards } from '@nestjs/common';
import { ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { UserRole } from '../users/schemas/user.schema';
import { PromoCodesService } from './promo-codes.service';
import { ValidatePromoCodeDto } from './dto/validate-promo-code.dto';
import { ApplyPromoCodeDto } from './dto/apply-promo-code.dto';

@ApiTags('promo-codes')
@Controller('promo-codes')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.CUSTOMER, UserRole.ADMIN)
export class PromoCodesController {
  constructor(private readonly promoCodesService: PromoCodesService) {}

  @Get('validate')
  @ApiOperation({ summary: 'Validate a promo code' })
  @ApiResponse({ status: 200, description: 'Promo code validation result' })
  validate(@Query() query: ValidatePromoCodeDto) {
    return this.promoCodesService.validate(query.code, query.subtotal || 0);
  }

  @Post('apply')
  @ApiOperation({ summary: 'Apply a promo code to an order total' })
  @ApiResponse({ status: 200, description: 'Promo code application result' })
  apply(@Body() dto: ApplyPromoCodeDto) {
    return this.promoCodesService.apply(dto.code, dto.orderTotal);
  }
}
