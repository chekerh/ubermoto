import { Controller, Post, Headers, Req, BadRequestException, HttpCode, HttpStatus } from '@nestjs/common';
import { Request } from 'express';
import Stripe from 'stripe';
import { BillingService } from './billing.service';
import { Public } from '../common/decorators/public.decorator';

interface RawBodyRequest extends Request {
  rawBody?: Buffer;
}

@Controller('billing')
export class BillingController {
  constructor(private readonly billingService: BillingService) {}

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

