import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { BillingController } from './billing.controller';
import { BillingService } from './billing.service';
import { StripeWebhookEvent, StripeWebhookEventSchema } from './schemas/stripe-webhook-event.schema';

@Module({
  imports: [
    MongooseModule.forFeature([{ name: StripeWebhookEvent.name, schema: StripeWebhookEventSchema }]),
  ],
  controllers: [BillingController],
  providers: [BillingService],
  exports: [BillingService],
})
export class BillingModule {}

