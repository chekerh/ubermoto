import {
  Body,
  Controller,
  Get,
  Headers,
  HttpCode,
  HttpStatus,
  BadRequestException,
  Post,
  Query,
  Req,
  Request,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { Request as ExpressRequest } from 'express';
import Stripe from 'stripe';
import { BillingService } from './billing.service';
import { Public } from '../common/decorators/public.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { UserRole } from '../users/schemas/user.schema';
import { CreateCheckoutSessionDto } from './dto/create-checkout-session.dto';
import { CreatePortalSessionDto } from './dto/create-portal-session.dto';
import { UpsertPlanDto } from './dto/upsert-plan.dto';
import { CreateSelfCheckoutSessionDto } from './dto/create-self-checkout-session.dto';
import { CreateSelfPortalSessionDto } from './dto/create-self-portal-session.dto';

interface RawBodyRequest extends ExpressRequest {
  rawBody?: Buffer;
}

interface AuthenticatedRequest extends ExpressRequest {
  user: { sub: string; role: string };
}

@ApiTags('billing')
@Controller('billing')
export class BillingController {
  constructor(private readonly billingService: BillingService) {}

  @Get('plans')
  @ApiOperation({ summary: 'List active pricing plans' })
  listPlans() {
    return this.billingService.listPlans();
  }

  @Post('merchant/checkout-session')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.MERCHANT)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create Stripe Checkout session for merchant subscription' })
  createCheckoutSession(
    @Body() dto: CreateCheckoutSessionDto,
    @Request() req: AuthenticatedRequest,
  ) {
    return this.billingService.createCheckoutSession(
      dto.merchantId,
      dto.planKey,
      dto.successUrl,
      dto.cancelUrl,
      req.user.sub,
      req.user.role,
    );
  }

  @Post('merchant/portal-session')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.MERCHANT)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create Stripe billing portal session for merchant' })
  createPortalSession(@Body() dto: CreatePortalSessionDto, @Request() req: AuthenticatedRequest) {
    return this.billingService.createPortalSession(
      dto.merchantId,
      dto.returnUrl,
      req.user.sub,
      req.user.role,
    );
  }

  @Post('merchant/me/checkout-session')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.MERCHANT, UserRole.ADMIN)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create Stripe Checkout session using current user merchant membership' })
  createCheckoutSessionForMe(
    @Body() dto: CreateSelfCheckoutSessionDto,
    @Request() req: AuthenticatedRequest,
  ) {
    return this.billingService.createCheckoutSessionForUser(
      dto.planKey,
      dto.successUrl,
      dto.cancelUrl,
      req.user.sub,
      req.user.role,
      dto.merchantId,
    );
  }

  @Post('merchant/me/portal-session')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.MERCHANT, UserRole.ADMIN)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create Stripe billing portal session from current user merchant membership' })
  createPortalSessionForMe(
    @Body() dto: CreateSelfPortalSessionDto,
    @Request() req: AuthenticatedRequest,
  ) {
    return this.billingService.createPortalSessionForUser(
      dto.returnUrl,
      req.user.sub,
      req.user.role,
      dto.merchantId,
    );
  }

  @Get('me/entitlements')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get effective entitlements for current user and merchant membership' })
  getMyEntitlements(@Request() req: AuthenticatedRequest, @Query('merchantId') merchantId?: string) {
    return this.billingService.getEntitlementsForUser(req.user.sub, req.user.role, merchantId);
  }

  @Get('me/memberships')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'List current user active merchant memberships' })
  getMyMemberships(@Request() req: AuthenticatedRequest) {
    return this.billingService.listMembershipsForUser(req.user.sub);
  }

  @Get('merchant/me/summary')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.MERCHANT, UserRole.ADMIN)
  @ApiBearerAuth()
  @ApiOperation({
    summary: 'Get merchant billing summary for current user (merchant profile, subscription, entitlements)',
  })
  getMyMerchantSummary(@Request() req: AuthenticatedRequest, @Query('merchantId') merchantId?: string) {
    return this.billingService.getMerchantSummaryForUser(req.user.sub, req.user.role, merchantId);
  }

  @Get('merchant/me/usage')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.MERCHANT, UserRole.ADMIN)
  @ApiBearerAuth()
  @ApiOperation({
    summary: 'Product count vs plan limit for current merchant context (upgrade UX)',
  })
  getMyMerchantUsage(@Request() req: AuthenticatedRequest, @Query('merchantId') merchantId?: string) {
    return this.billingService.getMerchantUsageForUser(req.user.sub, req.user.role, merchantId);
  }

  @Post('admin/plans/upsert')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Admin: upsert a plan definition' })
  upsertPlan(@Body() dto: UpsertPlanDto) {
    return this.billingService.upsertPlan(dto);
  }

  @Post('admin/merchant-membership')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Admin: assign user to merchant for entitlement context' })
  addMembership(
    @Body() body: { merchantId: string; userId: string; role?: 'owner' | 'manager' | 'analyst' },
  ) {
    return this.billingService.addOrUpdateMerchantMembership(
      body.merchantId,
      body.userId,
      body.role || 'manager',
    );
  }

  /**
   * Stripe requires signature verification against the **raw** request body.
   * `main.ts` must install a raw-body capture middleware for this route.
   */
  @Public()
  @Post('webhooks/stripe')
  @HttpCode(HttpStatus.OK)
  async stripeWebhook(@Req() req: RawBodyRequest, @Headers('stripe-signature') sig?: string) {
    const secret = process.env.STRIPE_WEBHOOK_SECRET?.trim();
    if (!secret) {
      throw new BadRequestException('STRIPE_WEBHOOK_SECRET is not configured');
    }
    if (!sig) {
      throw new BadRequestException('Missing stripe-signature header');
    }
    const raw = req.rawBody;
    if (!raw) {
      throw new BadRequestException('Missing raw request body for signature verification');
    }

    const stripe = this.billingService.getStripe();
    let event: Stripe.Event;
    try {
      event = stripe.webhooks.constructEvent(raw, sig, secret);
    } catch (err) {
      throw new BadRequestException(
        `Invalid Stripe signature: ${err instanceof Error ? err.message : 'unknown error'}`,
      );
    }

    const payloadHash = this.billingService.hashPayload(raw);
    const created = await this.billingService.storeStripeEventIfNew(event, payloadHash);
    if (!created) {
      // Idempotent: already received; return 200 so Stripe doesn't retry.
      return { received: true, duplicate: true };
    }

    try {
      await this.billingService.handleStripeWebhookEvent(event);
    } catch (e) {
      await this.billingService.markStripeEventFailed(
        event.id,
        e instanceof Error ? e.message : 'unknown error',
      );
      throw e;
    }

    return { received: true };
  }
}

