import { Test, TestingModule } from '@nestjs/testing';
import { ConfigService } from '@nestjs/config';
import { CostCalculatorService } from './cost-calculator.service';

describe('CostCalculatorService', () => {
  let service: CostCalculatorService;
  let configService: jest.Mocked<Partial<ConfigService>>;

  beforeEach(async () => {
    configService = {
      get: jest.fn().mockImplementation((key: string) => {
        const defaults: Record<string, number> = {
          FUEL_PRICE_PER_LITER: 2.5,
          BASE_DELIVERY_FEE: 5.0,
        };
        return defaults[key];
      }),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        CostCalculatorService,
        { provide: ConfigService, useValue: configService },
      ],
    }).compile();

    service = module.get<CostCalculatorService>(CostCalculatorService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  // ── calculateDeliveryCost ────────────────────────────────────────────

  describe('calculateDeliveryCost', () => {
    it('should compute base fee + fuel cost for simple delivery', () => {
      // 10 km, 5 L/100km, default fuel price 2.5, default base 5.0
      // fuel = (10/100) * 5 * 2.5 = 1.25
      // total = 5.0 + 1.25 * 1.0 = 6.25
      const cost = service.calculateDeliveryCost({
        distance: 10,
        fuelConsumption: 5,
      });
      expect(cost).toBe(6.25);
    });

    it('should apply surge multiplier to fuel cost only', () => {
      // 10 km, 5 L/100km, default price & base, multiplier 2.0
      // fuel = 1.25, total = 5.0 + 1.25 * 2.0 = 7.50
      const cost = service.calculateDeliveryCost({
        distance: 10,
        fuelConsumption: 5,
        timeMultiplier: 2.0,
      });
      expect(cost).toBe(7.5);
    });

    it('should use custom fuel price and base fee', () => {
      // 20 km, 3 L/100km, price 3.0, base 2.0
      // fuel = (20/100) * 3 * 3.0 = 1.80
      // total = 2.0 + 1.80 = 3.80
      const cost = service.calculateDeliveryCost({
        distance: 20,
        fuelConsumption: 3,
        fuelPrice: 3.0,
        baseFee: 2.0,
      });
      expect(cost).toBe(3.8);
    });

    it('should round to 2 decimal places', () => {
      // 7 km, 4.3 L/100km, price 2.5, base 5
      // fuel = (7/100) * 4.3 * 2.5 = 0.7525
      // total = 5.0 + 0.7525 = 5.7525 → 5.75
      const cost = service.calculateDeliveryCost({
        distance: 7,
        fuelConsumption: 4.3,
      });
      expect(cost).toBe(5.75);
    });

    it('should return base fee only for zero distance', () => {
      const cost = service.calculateDeliveryCost({
        distance: 0,
        fuelConsumption: 5,
      });
      expect(cost).toBe(5.0);
    });

    it('should handle large distances', () => {
      // 100 km, 6 L/100km, default price/base
      // fuel = (100/100) * 6 * 2.5 = 15.0
      // total = 5.0 + 15.0 = 20.0
      const cost = service.calculateDeliveryCost({
        distance: 100,
        fuelConsumption: 6,
      });
      expect(cost).toBe(20.0);
    });
  });

  // ── calculateFuelCost ────────────────────────────────────────────────

  describe('calculateFuelCost', () => {
    it('should compute fuel cost without base fee', () => {
      // 10 km, 5 L/100km, default 2.5
      // (10/100)*5*2.5 = 1.25
      const cost = service.calculateFuelCost(10, 5);
      expect(cost).toBe(1.25);
    });

    it('should use custom fuel price', () => {
      const cost = service.calculateFuelCost(10, 5, 4.0);
      // (10/100)*5*4 = 2.0
      expect(cost).toBe(2.0);
    });
  });
});
