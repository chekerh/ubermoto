import { BadRequestException, ForbiddenException, Injectable, Logger, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import crypto from 'crypto';
import Stripe from 'stripe';
import { StripeWebhookEvent, StripeWebhookEventDocument } from './schemas/stripe-webhook-event.schema';
import { Plan, PlanDocument } from './schemas/plan.schema';
import { Subscription, SubscriptionDocument } from './schemas/subscription.schema';
import { Entitlement, EntitlementDocument } from './schemas/entitlement.schema';
import { MerchantMember, MerchantMemberDocument } from './schemas/merchant-member.schema';
import { Merchant, MerchantDocument } from '../catalog/schemas/merchant.schema';

@Injectable()
export class BillingService {
  private readonly logger = new Logger(BillingService.name);
  private readonly stripe: Stripe;

  constructor(
    @InjectModel(StripeWebhookEvent.name)
    private readonly stripeWebhookEventModel: Model<StripeWebhookEventDocument>,
    @InjectModel(Plan.name)
    private readonly planModel: Model<PlanDocument>,
    @InjectModel(Subscription.name)
    private readonly subscriptionModel: Model<SubscriptionDocument>,
    @InjectModel(Entitlement.name)
    private readonly entitlementModel: Model<EntitlementDocument>,
    @InjectModel(MerchantMember.name)
    private readonly merchantMemberModel: Model<MerchantMemberDocument>,
    @InjectModel(Merchant.name)
    private readonly merchantModel: Model<MerchantDocument>,
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

  private isBillableStatus(status: string): boolean {
    return ['trialing', 'active', 'past_due'].includes(status);
  }

  async upsertPlan(dto: {
    key: string;
    name: string;
    description: string;
    stripePriceId: string;
    features: Record<string, boolean>;
    limits: Record<string, number>;
    isActive?: boolean;
  }) {
    return this.planModel
      .findOneAndUpdate(
        { key: dto.key },
        {
          $set: {
            ...dto,
            isActive: dto.isActive ?? true,
          },
        },
        { upsert: true, new: true },
      )
      .lean()
      .exec();
  }

  async listPlans() {
    return this.planModel.find().sort({ key: 1 }).lean().exec();
  }

  async getActivePlanByKey(planKey: string): Promise<PlanDocument> {
    const plan = await this.planModel.findOne({ key: planKey, isActive: true }).exec();
    if (!plan) {
      throw new NotFoundException(`Active plan '${planKey}' not found`);
    }
    return plan;
  }

  async addOrUpdateMerchantMembership(
    merchantId: string,
    userId: string,
    role: 'owner' | 'manager' | 'analyst' = 'manager',
  ) {
    await this.merchantMemberModel
      .updateOne(
        { merchantId, userId },
        { $set: { merchantId, userId, role, isActive: true } },
        { upsert: true },
      )
      .exec();
  }

  async listMembershipsForUser(userId: string) {
    const memberships = await this.merchantMemberModel
      .find({ userId, isActive: true })
      .sort({ createdAt: 1 })
      .lean()
      .exec();
    if (!memberships.length) {
      return [];
    }
    const merchantIds = memberships.map((m) => m.merchantId);
    const merchants = await this.merchantModel.find({ _id: { $in: merchantIds } }).lean().exec();
    const merchantMap = new Map(merchants.map((m: any) => [String(m._id), m]));
    return memberships.map((m) => {
      const merchant = merchantMap.get(m.merchantId);
      return {
        merchantId: m.merchantId,
        membershipRole: m.role,
        merchant: merchant
          ? {
              id: String((merchant as any)._id),
              name: merchant.name,
              region: merchant.region,
              isActive: merchant.isActive,
            }
          : null,
      };
    });
  }

  private async resolveMerchantIdForUser(userId: string): Promise<string> {
    const member = await this.merchantMemberModel
      .findOne({ userId, isActive: true })
      .sort({ createdAt: 1 })
      .lean()
      .exec();
    if (!member?.merchantId) {
      throw new NotFoundException('No active merchant membership found for this user');
    }
    return member.merchantId;
  }

  async assertMerchantAccessOrThrow(merchantId: string, userId: string, userRole: string) {
    if (userRole === 'ADMIN') {
      return;
    }
    const member = await this.merchantMemberModel.findOne({ merchantId, userId, isActive: true }).exec();
    if (!member) {
      throw new ForbiddenException('You do not have access to this merchant');
    }
  }

  async createCheckoutSession(
    merchantId: string,
    planKey: string,
    successUrl: string,
    cancelUrl: string,
    requesterUserId: string,
    requesterRole: string,
  ) {
    await this.assertMerchantAccessOrThrow(merchantId, requesterUserId, requesterRole);
    const merchant = await this.merchantModel.findById(merchantId).lean().exec();
    if (!merchant) {
      throw new NotFoundException('Merchant not found');
    }
    const plan = await this.getActivePlanByKey(planKey);
    const existingSub = await this.subscriptionModel.findOne({ merchantId }).lean().exec();

    const session = await this.stripe.checkout.sessions.create({
      mode: 'subscription',
      customer: existingSub?.stripeCustomerId,
      customer_email: existingSub?.stripeCustomerId ? undefined : `${merchant.name.replace(/\s+/g, '.').toLowerCase()}@merchant.local`,
      line_items: [{ price: plan.stripePriceId, quantity: 1 }],
      success_url: successUrl,
      cancel_url: cancelUrl,
      metadata: {
        merchantId,
        planKey: plan.key,
      },
      subscription_data: {
        metadata: { merchantId, planKey: plan.key },
      },
    });

    if (!session.url) {
      throw new BadRequestException('Failed to create Stripe checkout session URL');
    }
    return { url: session.url, sessionId: session.id };
  }

  async createCheckoutSessionForUser(
    planKey: string,
    successUrl: string,
    cancelUrl: string,
    requesterUserId: string,
    requesterRole: string,
  ) {
    const merchantId = await this.resolveMerchantIdForUser(requesterUserId);
    return this.createCheckoutSession(
      merchantId,
      planKey,
      successUrl,
      cancelUrl,
      requesterUserId,
      requesterRole,
    );
  }

  async createPortalSession(
    merchantId: string,
    returnUrl: string,
    requesterUserId: string,
    requesterRole: string,
  ) {
    await this.assertMerchantAccessOrThrow(merchantId, requesterUserId, requesterRole);
    const sub = await this.subscriptionModel.findOne({ merchantId }).lean().exec();
    if (!sub?.stripeCustomerId) {
      throw new NotFoundException('No Stripe customer found for merchant');
    }
    const portal = await this.stripe.billingPortal.sessions.create({
      customer: sub.stripeCustomerId,
      return_url: returnUrl,
    });
    return { url: portal.url };
  }

  async createPortalSessionForUser(returnUrl: string, requesterUserId: string, requesterRole: string) {
    const merchantId = await this.resolveMerchantIdForUser(requesterUserId);
    return this.createPortalSession(merchantId, returnUrl, requesterUserId, requesterRole);
  }

  async getMerchantSummaryForUser(
    requesterUserId: string,
    requesterRole: string,
    merchantIdOverride?: string,
  ) {
    const merchantId = merchantIdOverride || (await this.resolveMerchantIdForUser(requesterUserId));
    await this.assertMerchantAccessOrThrow(merchantId, requesterUserId, requesterRole);
    const merchant = await this.merchantModel.findById(merchantId).lean().exec();
    const sub = await this.subscriptionModel.findOne({ merchantId }).lean().exec();
    const ent = await this.entitlementModel.findOne({ merchantId }).lean().exec();
    const member = await this.merchantMemberModel
      .findOne({ merchantId, userId: requesterUserId, isActive: true })
      .lean()
      .exec();

    return {
      merchant: merchant
        ? {
            id: String((merchant as any)._id),
            name: merchant.name,
            region: merchant.region,
            isActive: merchant.isActive,
          }
        : null,
      membership: member
        ? {
            role: member.role,
            isActive: member.isActive,
          }
        : null,
      subscription: sub
        ? {
            status: sub.status,
            planKey: sub.planKey,
            currentPeriodStart: sub.currentPeriodStart,
            currentPeriodEnd: sub.currentPeriodEnd,
            cancelAtPeriodEnd: sub.cancelAtPeriodEnd,
          }
        : null,
      entitlements: ent
        ? {
            planKey: ent.planKey,
            features: ent.features,
            limits: ent.limits,
            computedAt: ent.computedAt,
          }
        : null,
    };
  }

  async upsertSubscriptionFromStripe(
    stripeSubscriptionId: string,
    stripeCustomerId: string,
    status: string,
    planKey: string,
    merchantId: string,
    periodStart?: number,
    periodEnd?: number,
    cancelAtPeriodEnd?: boolean,
  ) {
    const sub = await this.subscriptionModel
      .findOneAndUpdate(
        { stripeSubscriptionId },
        {
          $set: {
            stripeSubscriptionId,
            stripeCustomerId,
            status,
            planKey,
            merchantId,
            currentPeriodStart: periodStart ? new Date(periodStart * 1000) : undefined,
            currentPeriodEnd: periodEnd ? new Date(periodEnd * 1000) : undefined,
            cancelAtPeriodEnd: !!cancelAtPeriodEnd,
          },
        },
        { upsert: true, new: true },
      )
      .exec();
    await this.recomputeEntitlementsForMerchant(merchantId, status, planKey);
    return sub;
  }

  async recomputeEntitlementsForMerchant(merchantId: string, status: string, planKey: string) {
    const plan = await this.planModel.findOne({ key: planKey }).lean().exec();
    if (!plan) {
      this.logger.warn(`Cannot recompute entitlements: plan ${planKey} not found`);
      return;
    }
    const enabled = this.isBillableStatus(status);
    const features = enabled ? plan.features : {};
    const limits = enabled ? plan.limits : {};
    await this.entitlementModel
      .updateOne(
        { merchantId },
        {
          $set: {
            merchantId,
            planKey: plan.key,
            features,
            limits,
            computedAt: new Date(),
          },
        },
        { upsert: true },
      )
      .exec();
  }

  async getEntitlementsForUser(userId: string, userRole: string, merchantId?: string) {
    let memberMerchantId = merchantId;
    if (!memberMerchantId) {
      const member = await this.merchantMemberModel.findOne({ userId, isActive: true }).lean().exec();
      memberMerchantId = member?.merchantId;
    }
    if (!memberMerchantId) {
      return {
        user: { role: userRole, features: {}, limits: {} },
        merchant: null,
      };
    }
    await this.assertMerchantAccessOrThrow(memberMerchantId, userId, userRole);
    const sub = await this.subscriptionModel.findOne({ merchantId: memberMerchantId }).lean().exec();
    const ent = await this.entitlementModel.findOne({ merchantId: memberMerchantId }).lean().exec();
    return {
      user: { role: userRole, features: {}, limits: {} },
      merchant: {
        merchantId: memberMerchantId,
        subscriptionStatus: sub?.status ?? 'none',
        planKey: sub?.planKey ?? ent?.planKey ?? 'none',
        features: ent?.features ?? {},
        limits: ent?.limits ?? {},
      },
    };
  }

  async handleStripeWebhookEvent(event: Stripe.Event): Promise<void> {
    this.logger.log(`Stripe event received: ${event.type} (${event.id})`);
    if (
      event.type === 'customer.subscription.created' ||
      event.type === 'customer.subscription.updated' ||
      event.type === 'customer.subscription.deleted'
    ) {
      const sub = event.data.object as Stripe.Subscription;
      const metadata = sub.metadata || {};
      const merchantId = metadata.merchantId;
      const planKey = metadata.planKey;
      if (merchantId && planKey) {
        await this.upsertSubscriptionFromStripe(
          sub.id,
          String(sub.customer),
          sub.status,
          planKey,
          merchantId,
          sub.current_period_start,
          sub.current_period_end,
          sub.cancel_at_period_end,
        );
      } else {
        this.logger.warn(`Subscription event ${sub.id} missing merchantId/planKey metadata`);
      }
    }
    await this.markStripeEventProcessed(event.id);
  }
}

