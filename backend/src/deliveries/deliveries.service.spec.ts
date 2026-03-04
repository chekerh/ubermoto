import { Test, TestingModule } from '@nestjs/testing';
import { getModelToken } from '@nestjs/mongoose';
import { NotFoundException, BadRequestException } from '@nestjs/common';
import { DeliveriesService } from './deliveries.service';
import { Delivery, DeliveryStatus } from './schemas/delivery.schema';
import { MotorcyclesService } from '../motorcycles/motorcycles.service';
import { CostCalculatorService } from '../core/utils/cost-calculator.service';
import { DeliveryMatchingService } from './delivery-matching.service';
import { DeliveryGateway } from '../websocket/delivery.gateway';
import { SurgeService } from '../surge/surge.service';
import { DriversService } from '../drivers/drivers.service';

describe('DeliveriesService', () => {
  let service: DeliveriesService;
  let deliveryModel: any;
  let motorcyclesService: any;
  let costCalculatorService: any;
  let deliveryMatchingService: any;
  let deliveryGateway: any;
  let surgeService: any;
  let driversService: any;

  // Helper to create a mock Mongoose document
  const mockDelivery = (overrides: any = {}) => ({
    _id: { toString: () => 'delivery-id-1' },
    pickupLocation: 'Downtown',
    deliveryAddress: 'Suburbs',
    deliveryType: 'Food',
    status: DeliveryStatus.PENDING,
    userId: { toString: () => 'user-id-1' },
    driverId: null,
    distance: 10,
    estimatedCost: 6.25,
    surgeMultiplier: 1,
    save: jest.fn().mockReturnThis(),
    ...overrides,
  });

  beforeEach(async () => {
    // Create a mock Mongoose model (constructor + static methods)
    const MockModel = jest.fn().mockImplementation((data) => ({
      ...data,
      _id: { toString: () => 'delivery-id-new' },
      save: jest.fn().mockResolvedValue({
        ...data,
        _id: { toString: () => 'delivery-id-new' },
      }),
    }));
    (MockModel as any).find = jest.fn().mockReturnValue({
      populate: jest.fn().mockReturnValue({
        exec: jest.fn().mockResolvedValue([]),
      }),
    });
    (MockModel as any).findById = jest.fn().mockReturnValue({
      populate: jest.fn().mockReturnValue({
        exec: jest.fn(),
      }),
      exec: jest.fn(),
    });
    (MockModel as any).findByIdAndUpdate = jest.fn().mockReturnValue({
      populate: jest.fn().mockReturnValue({
        exec: jest.fn(),
      }),
    });
    (MockModel as any).findOneAndUpdate = jest.fn().mockReturnValue({
      populate: jest.fn().mockReturnValue({
        populate: jest.fn().mockReturnValue({
          exec: jest.fn(),
        }),
      }),
    });

    deliveryModel = MockModel;

    motorcyclesService = { findOne: jest.fn() };
    costCalculatorService = { calculateDeliveryCost: jest.fn() };
    deliveryMatchingService = {
      notifyDriversOfNewDelivery: jest.fn(),
      assignDeliveryToDriver: jest.fn(),
      getDriverDeliveries: jest.fn().mockResolvedValue([]),
      getAvailableDeliveries: jest.fn().mockResolvedValue([]),
      makeDriverAvailableAfterDelivery: jest.fn(),
    };
    deliveryGateway = { emitDeliveryStatusUpdate: jest.fn() };
    surgeService = { getMultiplierFor: jest.fn() };
    driversService = { findByUserId: jest.fn() };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        DeliveriesService,
        { provide: getModelToken(Delivery.name), useValue: deliveryModel },
        { provide: MotorcyclesService, useValue: motorcyclesService },
        { provide: CostCalculatorService, useValue: costCalculatorService },
        { provide: DeliveryMatchingService, useValue: deliveryMatchingService },
        { provide: DeliveryGateway, useValue: deliveryGateway },
        { provide: SurgeService, useValue: surgeService },
        { provide: DriversService, useValue: driversService },
      ],
    }).compile();

    service = module.get<DeliveriesService>(DeliveriesService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  // ── State Machine Transitions ────────────────────────────────────────

  describe('status transitions (state machine)', () => {
    const validTransitions: [DeliveryStatus, DeliveryStatus][] = [
      [DeliveryStatus.PENDING, DeliveryStatus.ACCEPTED],
      [DeliveryStatus.PENDING, DeliveryStatus.CANCELLED],
      [DeliveryStatus.ACCEPTED, DeliveryStatus.PICKED_UP],
      [DeliveryStatus.ACCEPTED, DeliveryStatus.CANCELLED],
      [DeliveryStatus.PICKED_UP, DeliveryStatus.IN_PROGRESS],
      [DeliveryStatus.PICKED_UP, DeliveryStatus.COMPLETED],
      [DeliveryStatus.IN_PROGRESS, DeliveryStatus.COMPLETED],
      [DeliveryStatus.IN_PROGRESS, DeliveryStatus.CANCELLED],
    ];

    const invalidTransitions: [DeliveryStatus, DeliveryStatus][] = [
      [DeliveryStatus.PENDING, DeliveryStatus.COMPLETED],
      [DeliveryStatus.PENDING, DeliveryStatus.PICKED_UP],
      [DeliveryStatus.PENDING, DeliveryStatus.IN_PROGRESS],
      [DeliveryStatus.ACCEPTED, DeliveryStatus.COMPLETED],
      [DeliveryStatus.COMPLETED, DeliveryStatus.PENDING],
      [DeliveryStatus.COMPLETED, DeliveryStatus.CANCELLED],
      [DeliveryStatus.CANCELLED, DeliveryStatus.PENDING],
      [DeliveryStatus.CANCELLED, DeliveryStatus.ACCEPTED],
    ];

    it.each(validTransitions)(
      'should allow %s → %s',
      async (from, to) => {
        const existing = mockDelivery({ status: from });
        deliveryModel.findById.mockReturnValue({
          exec: jest.fn().mockResolvedValue(existing),
          populate: jest.fn().mockReturnValue({
            exec: jest.fn().mockResolvedValue(existing),
          }),
        });
        const updated = mockDelivery({ status: to });
        deliveryModel.findByIdAndUpdate.mockReturnValue({
          populate: jest.fn().mockReturnValue({
            exec: jest.fn().mockResolvedValue(updated),
          }),
        });

        const result = await service.updateStatus('delivery-id-1', to);
        expect(result.status).toBe(to);
      },
    );

    it.each(invalidTransitions)(
      'should reject %s → %s',
      async (from, to) => {
        const existing = mockDelivery({ status: from });
        deliveryModel.findById.mockReturnValue({
          exec: jest.fn().mockResolvedValue(existing),
          populate: jest.fn().mockReturnValue({
            exec: jest.fn().mockResolvedValue(existing),
          }),
        });

        await expect(
          service.updateStatus('delivery-id-1', to),
        ).rejects.toThrow(BadRequestException);
      },
    );
  });

  // ── updateStatus ─────────────────────────────────────────────────────

  describe('updateStatus', () => {
    it('should throw NotFoundException for unknown delivery', async () => {
      deliveryModel.findById.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });

      await expect(
        service.updateStatus('nonexistent', DeliveryStatus.ACCEPTED),
      ).rejects.toThrow(NotFoundException);
    });

    it('should emit WebSocket update after status change', async () => {
      const existing = mockDelivery({ status: DeliveryStatus.PENDING });
      const updated = mockDelivery({ status: DeliveryStatus.ACCEPTED });

      deliveryModel.findById.mockReturnValue({
        exec: jest.fn().mockResolvedValue(existing),
      });
      deliveryModel.findByIdAndUpdate.mockReturnValue({
        populate: jest.fn().mockReturnValue({
          exec: jest.fn().mockResolvedValue(updated),
        }),
      });

      await service.updateStatus('delivery-id-1', DeliveryStatus.ACCEPTED);
      expect(deliveryGateway.emitDeliveryStatusUpdate).toHaveBeenCalledWith(
        'delivery-id-1',
        updated,
      );
    });
  });

  // ── findOne ──────────────────────────────────────────────────────────

  describe('findOne', () => {
    it('should return delivery when found', async () => {
      const delivery = mockDelivery();
      deliveryModel.findById.mockReturnValue({
        populate: jest.fn().mockReturnValue({
          exec: jest.fn().mockResolvedValue(delivery),
        }),
      });

      const result = await service.findOne('delivery-id-1');
      expect(result).toBe(delivery);
    });

    it('should throw NotFoundException when not found', async () => {
      deliveryModel.findById.mockReturnValue({
        populate: jest.fn().mockReturnValue({
          exec: jest.fn().mockResolvedValue(null),
        }),
      });

      await expect(service.findOne('nonexistent')).rejects.toThrow(
        NotFoundException,
      );
    });
  });

  // ── cancelDelivery authorization ─────────────────────────────────────

  describe('cancelDelivery', () => {
    it('should throw NotFoundException for unknown delivery', async () => {
      deliveryModel.findById.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });

      await expect(
        service.cancelDelivery('nonexistent', 'user-1'),
      ).rejects.toThrow(NotFoundException);
    });

    it('should throw BadRequestException if user is not owner or driver', async () => {
      const delivery = mockDelivery({
        status: DeliveryStatus.PENDING,
        userId: { toString: () => 'user-owner' },
        driverId: null,
      });
      deliveryModel.findById.mockReturnValue({
        exec: jest.fn().mockResolvedValue(delivery),
      });

      await expect(
        service.cancelDelivery('delivery-id-1', 'random-user'),
      ).rejects.toThrow(BadRequestException);
    });

    it('should reject cancellation of COMPLETED delivery', async () => {
      const delivery = mockDelivery({
        status: DeliveryStatus.COMPLETED,
        userId: { toString: () => 'user-1' },
      });
      deliveryModel.findById.mockReturnValue({
        exec: jest.fn().mockResolvedValue(delivery),
      });

      await expect(
        service.cancelDelivery('delivery-id-1', 'user-1'),
      ).rejects.toThrow(BadRequestException);
    });
  });

  // ── acceptDelivery ───────────────────────────────────────────────────

  describe('acceptDelivery', () => {
    it('should resolve userId to driverId then delegate to matching service', async () => {
      driversService.findByUserId.mockResolvedValue({
        _id: { toString: () => 'driver-doc-id' },
      });
      const accepted = mockDelivery({ status: DeliveryStatus.ACCEPTED });
      deliveryMatchingService.assignDeliveryToDriver.mockResolvedValue(accepted);

      const result = await service.acceptDelivery('delivery-id-1', 'user-id-1');

      expect(driversService.findByUserId).toHaveBeenCalledWith('user-id-1');
      expect(deliveryMatchingService.assignDeliveryToDriver).toHaveBeenCalledWith(
        'delivery-id-1',
        'driver-doc-id',
      );
      expect(result.status).toBe(DeliveryStatus.ACCEPTED);
    });

    it('should throw NotFoundException if user has no driver profile', async () => {
      driversService.findByUserId.mockResolvedValue(null);

      await expect(
        service.acceptDelivery('delivery-id-1', 'non-driver-user'),
      ).rejects.toThrow(NotFoundException);
    });
  });
});
