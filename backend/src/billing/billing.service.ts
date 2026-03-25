import { Injectable, Logger } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import crypto from 'crypto';
import Stripe from 'stripe';
import { StripeWebhookEvent, StripeWebhookEventDocument } from './schemas/stripe-webhook-event.schema';

@Injectable()
export class BillingService {
  private readonly logger = new Logger(BillingService.name);
  private readonly stripe: Stripe;

  constructor(
    @InjectModel(StripeWebhookEvent.name)
    private readonly stripeWebhookEventModel: Model<StripeWebhookEventDocument>,
  ) {
    const stripeKey = process.env.STRIPE_SECRET_KEY?.trim();
    this.stripe = new Stripe(stripeKey || 'sk_test_missing', {
      apiVersion: '2024-06-20',
      typescript: true,
    });
  }

  getStripe() {
    return this.stripe;
  }

  hashPayload(raw: Buffer): string {
    return crypto.createHash('sha256').update(raw).digest('hex');
  }

  async storeStripeEventIfNew(event: Stripe.Event, payloadHash: string) {
    try {
      return await this.stripeWebhookEventModel.create({
        eventId: event.id,
        type: event.type,
        livemode: !!event.livemode,
        payloadHash,
        status: 'received',
      });
    } catch (e: any) {
      // Duplicate key means we already processed/received this event (idempotency).
      if (e?.code === 11000) {
        return null;
      }
      throw e;
    }
  }

  async markStripeEventProcessed(eventId: string) {
    await this.stripeWebhookEventModel
      .updateOne({ eventId }, { $set: { status: 'processed', error: undefined } })
      .exec();
  }

  async markStripeEventFailed(eventId: string, error: string) {
    await this.stripeWebhookEventModel
      .updateOne({ eventId }, { $set: { status: 'failed', error } })
      .exec();
  }

  /**
   * v1: webhook foundation only.
   * Later: update Subscription + Entitlement models based on event types.
   */
  async handleStripeWebhookEvent(event: Stripe.Event): Promise<void> {
    // Placeholder: only mark processed. Real handling is added in the next iteration.
    this.logger.log(`Stripe event received: ${event.type} (${event.id})`);
    await this.markStripeEventProcessed(event.id);
  }
}

