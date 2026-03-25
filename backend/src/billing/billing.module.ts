import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { BillingController } from './billing.controller';
import { BillingService } from './billing.service';
import { StripeWebhookEvent, StripeWebhookEventSchema } from './schemas/stripe-webhook-event.schema';
import { Plan, PlanSchema } from './schemas/plan.schema';
import { Subscription, SubscriptionSchema } from './schemas/subscription.schema';
import { Entitlement, EntitlementSchema } from './schemas/entitlement.schema';
import { MerchantMember, MerchantMemberSchema } from './schemas/merchant-member.schema';
import { Merchant, MerchantSchema } from '../catalog/schemas/merchant.schema';
import { FeatureGuard } from './guards/feature.guard';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: StripeWebhookEvent.name, schema: StripeWebhookEventSchema },
      { name: Plan.name, schema: PlanSchema },
      { name: Subscription.name, schema: SubscriptionSchema },
      { name: Entitlement.name, schema: EntitlementSchema },
      { name: MerchantMember.name, schema: MerchantMemberSchema },
      { name: Merchant.name, schema: MerchantSchema },
    ]),
  ],
  controllers: [BillingController],
  providers: [BillingService, FeatureGuard],
  exports: [BillingService, FeatureGuard],
})
export class BillingModule {}

