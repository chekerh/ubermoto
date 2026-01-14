import { Test, TestingModule } from '@nestjs/testing';
import { ConfigService } from '@nestjs/config';
import { CostCalculatorService } from './cost-calculator.service';

describe('CostCalculatorService', () => {
  let service: CostCalculatorService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        CostCalculatorService,
        {
          provide: ConfigService,
          useValue: {
            get: jest.fn((key: string) => {
              if (key === 'FUEL_PRICE_PER_LITER') return 2.5;
              if (key === 'BASE_DELIVERY_FEE') return 5.0;
              return undefined;
            }),
          },
        },
      ],
    }).compile();

    service = module.get<CostCalculatorService>(CostCalculatorService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('calculateDeliveryCost', () => {
    it('should calculate cost correctly with default values', () => {
      const cost = service.calculateDeliveryCost({
        distance: 10,
        fuelConsumption: 3.5,
      });

      // Base fee (5.0) + (10/100 * 3.5 * 2.5) = 5.0 + 0.875 = 5.875
      expect(cost).toBe(5.88);
    });

    it('should calculate cost with custom fuel price', () => {
      const cost = service.calculateDeliveryCost({
        distance: 20,
        fuelConsumption: 4.0,
        fuelPrice: 3.0,
      });

      // Base fee (5.0) + (20/100 * 4.0 * 3.0) = 5.0 + 2.4 = 7.4
      expect(cost).toBe(7.4);
    });

    it('should calculate cost with custom base fee', () => {
      const cost = service.calculateDeliveryCost({
        distance: 15,
        fuelConsumption: 3.0,
        baseFee: 10.0,
      });

      // Base fee (10.0) + (15/100 * 3.0 * 2.5) = 10.0 + 1.125 = 11.125
      expect(cost).toBe(11.13);
    });

    it('should round to 2 decimal places', () => {
      const cost = service.calculateDeliveryCost({
        distance: 7,
        fuelConsumption: 3.333,
      });

      expect(cost.toString().split('.')[1]?.length).toBeLessThanOrEqual(2);
    });
  });

  describe('calculateFuelCost', () => {
    it('should calculate fuel cost correctly', () => {
      const cost = service.calculateFuelCost(10, 3.5);

      // (10/100 * 3.5 * 2.5) = 0.875
      expect(cost).toBe(0.88);
    });

    it('should use custom fuel price when provided', () => {
      const cost = service.calculateFuelCost(20, 4.0, 3.0);

      // (20/100 * 4.0 * 3.0) = 2.4
      expect(cost).toBe(2.4);
    });
  });
});
