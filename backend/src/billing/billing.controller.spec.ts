import { Test, TestingModule } from '@nestjs/testing';
import { getModelToken } from '@nestjs/mongoose';
import { BadRequestException } from '@nestjs/common';
import Stripe from 'stripe';
import { BillingController } from './billing.controller';
import { BillingService } from './billing.service';
import { StripeWebhookEvent } from './schemas/stripe-webhook-event.schema';

describe('BillingController (Stripe webhook)', () => {
  let controller: BillingController;
  let service: BillingService;

  const mockModel = {
    create: jest.fn(),
    updateOne: jest.fn().mockReturnValue({ exec: jest.fn() }),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [BillingController],
      providers: [
        BillingService,
        { provide: getModelToken(StripeWebhookEvent.name), useValue: mockModel },
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

