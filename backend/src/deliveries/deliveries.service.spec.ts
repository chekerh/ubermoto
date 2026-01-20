import { Test, TestingModule } from '@nestjs/testing';
import { getModelToken } from '@nestjs/mongoose';
import { Types } from 'mongoose';
import { DeliveriesService } from './deliveries.service';
import { Delivery, DeliveryStatus } from './schemas/delivery.schema';
import { CreateDeliveryDto } from './dto/create-delivery.dto';
import { MotorcyclesService } from '../motorcycles/motorcycles.service';
import { CostCalculatorService } from '../core/utils/cost-calculator.service';

describe('DeliveriesService', () => {
  let service: DeliveriesService;
  let motorcyclesService: MotorcyclesService;
  let costCalculatorService: CostCalculatorService;

  const mockDelivery = {
    _id: '507f1f77bcf86cd799439011',
    pickupLocation: 'Location A',
    deliveryAddress: 'Location B',
    deliveryType: 'Food',
    status: DeliveryStatus.PENDING,
    distance: 10,
    estimatedCost: 5.88,
    save: jest.fn().mockResolvedValue(true),
  };

  const mockMotorcycle = {
    _id: '507f1f77bcf86cd799439012',
    fuelConsumption: 3.5,
  };

  const mockDeliveryModel = {
    find: jest.fn().mockReturnValue({
      exec: jest.fn().mockResolvedValue([mockDelivery]),
      populate: jest.fn().mockReturnThis(),
    }),
    findById: jest.fn().mockReturnValue({
      exec: jest.fn().mockResolvedValue(mockDelivery),
      populate: jest.fn().mockReturnThis(),
    }),
    findByIdAndUpdate: jest.fn().mockReturnValue({
      exec: jest.fn().mockResolvedValue(mockDelivery),
      populate: jest.fn().mockReturnThis(),
    }),
  };

  class MockDelivery {
    pickupLocation = 'Location A';
    deliveryAddress = 'Location B';
    deliveryType = 'Food';
    status = DeliveryStatus.PENDING;
    distance = 10;
    estimatedCost = 5.88;
    userId = new Types.ObjectId();
    save = jest.fn().mockResolvedValue(mockDelivery);
  }

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        DeliveriesService,
        {
          provide: getModelToken(Delivery.name),
          useValue: {
            ...mockDeliveryModel,
            constructor: jest.fn().mockImplementation(() => new MockDelivery()),
          },
        },
        {
          provide: MotorcyclesService,
          useValue: {
            findOne: jest.fn().mockResolvedValue(mockMotorcycle),
          },
        },
        {
          provide: CostCalculatorService,
          useValue: {
            calculateDeliveryCost: jest.fn().mockReturnValue(5.88),
          },
        },
      ],
    }).compile();

    service = module.get<DeliveriesService>(DeliveriesService);
    motorcyclesService = module.get<MotorcyclesService>(MotorcyclesService);
    costCalculatorService = module.get<CostCalculatorService>(CostCalculatorService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('create', () => {
    it('should create a delivery without cost calculation if no motorcycle', async () => {
      const createDto: CreateDeliveryDto = {
        pickupLocation: 'Location A',
        deliveryAddress: 'Location B',
        deliveryType: 'Food',
      };

      const result = await service.create(createDto, 'user-id');

      expect(result).toBeDefined();
    });

    it('should calculate cost when motorcycle and distance provided', async () => {
      const createDto: CreateDeliveryDto = {
        pickupLocation: 'Location A',
        deliveryAddress: 'Location B',
        deliveryType: 'Food',
        distance: 10,
        motorcycleId: 'motorcycle-id',
      };

      const result = await service.create(createDto, 'user-id');

      expect(result).toBeDefined();
      expect(motorcyclesService.findOne).toHaveBeenCalledWith('motorcycle-id');
      expect(costCalculatorService.calculateDeliveryCost).toHaveBeenCalled();
    });
  });

  describe('calculateCost', () => {
    it('should calculate and update delivery cost', async () => {
      const cost = await service.calculateCost('delivery-id', 10, 'motorcycle-id');

      expect(cost).toBe(5.88);
      expect(motorcyclesService.findOne).toHaveBeenCalledWith('motorcycle-id');
      expect(costCalculatorService.calculateDeliveryCost).toHaveBeenCalled();
    });
  });
});
