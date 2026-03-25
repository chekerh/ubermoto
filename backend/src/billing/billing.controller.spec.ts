import { Test, TestingModule } from '@nestjs/testing';
import { getModelToken } from '@nestjs/mongoose';
import { BadRequestException } from '@nestjs/common';
import Stripe from 'stripe';
import { BillingController } from './billing.controller';
import { BillingService } from './billing.service';
import { StripeWebhookEvent } from './schemas/stripe-webhook-event.schema';
import { Plan } from './schemas/plan.schema';
import { Subscription } from './schemas/subscription.schema';
import { Entitlement } from './schemas/entitlement.schema';
import { MerchantMember } from './schemas/merchant-member.schema';
import { Merchant } from '../catalog/schemas/merchant.schema';
import { Product } from '../catalog/schemas/product.schema';

describe('BillingController (Stripe webhook)', () => {
  let controller: BillingController;
  let service: BillingService;

  const mockModel = {
    create: jest.fn(),
    updateOne: jest.fn().mockReturnValue({ exec: jest.fn() }),
    countDocuments: jest.fn().mockReturnValue({ exec: jest.fn().mockResolvedValue(0) }),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [BillingController],
      providers: [
        BillingService,
        { provide: getModelToken(StripeWebhookEvent.name), useValue: mockModel },
        { provide: getModelToken(Plan.name), useValue: mockModel },
        { provide: getModelToken(Subscription.name), useValue: mockModel },
        { provide: getModelToken(Entitlement.name), useValue: mockModel },
        { provide: getModelToken(MerchantMember.name), useValue: mockModel },
        { provide: getModelToken(Merchant.name), useValue: mockModel },
        { provide: getModelToken(Product.name), useValue: mockModel },
      ],
    }).compile();

    controller = module.get(BillingController);
    service = module.get(BillingService);
    jest.spyOn(service, 'getStripe').mockReturnValue({
      webhooks: {
        constructEvent: jest.fn(),
      },
    } as unknown as Stripe);
    jest.spyOn(service, 'hashPayload').mockReturnValue('hash');
    jest.spyOn(service, 'storeStripeEventIfNew').mockResolvedValue({} as any);
    jest.spyOn(service, 'handleStripeWebhookEvent').mockResolvedValue();
  });

  it('rejects when webhook secret missing', async () => {
    const prev = process.env.STRIPE_WEBHOOK_SECRET;
    delete process.env.STRIPE_WEBHOOK_SECRET;

    await expect(
      controller.stripeWebhook({ rawBody: Buffer.from('{}') } as any, 'sig'),
    ).rejects.toBeInstanceOf(BadRequestException);

    process.env.STRIPE_WEBHOOK_SECRET = prev;
  });

  it('returns duplicate when event already stored', async () => {
    process.env.STRIPE_WEBHOOK_SECRET = 'whsec_test';
    (service.getStripe() as any).webhooks.constructEvent.mockReturnValue({
      id: 'evt_1',
      type: 'test',
      livemode: false,
    });
    (service.storeStripeEventIfNew as jest.Mock).mockResolvedValueOnce(null);

    const res = await controller.stripeWebhook({ rawBody: Buffer.from('{}') } as any, 'sig');
    expect(res).toEqual({ received: true, duplicate: true });
  });
});
