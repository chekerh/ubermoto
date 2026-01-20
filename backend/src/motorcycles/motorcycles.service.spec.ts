import { Test, TestingModule } from '@nestjs/testing';
import { getModelToken } from '@nestjs/mongoose';
import { MotorcyclesService } from './motorcycles.service';
import { NotFoundException } from '@nestjs/common';
import { Motorcycle } from './schemas/motorcycle.schema';

describe('MotorcyclesService', () => {
  let service: MotorcyclesService;

  const mockMotorcycle = {
    _id: '507f1f77bcf86cd799439011',
    model: 'Forza',
    brand: 'Honda',
    fuelConsumption: 3.5,
    save: jest.fn().mockResolvedValue(true),
  };

  const mockMotorcycleModel = {
    find: jest.fn().mockReturnValue({
      exec: jest.fn().mockResolvedValue([mockMotorcycle]),
    }),
    findById: jest.fn().mockReturnValue({
      exec: jest.fn().mockResolvedValue(mockMotorcycle),
    }),
    create: jest.fn().mockResolvedValue(mockMotorcycle),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        MotorcyclesService,
        {
          provide: getModelToken(Motorcycle.name),
          useValue: mockMotorcycleModel,
        },
      ],
    }).compile();

    service = module.get<MotorcyclesService>(MotorcyclesService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('create', () => {
    it('should create a motorcycle', async () => {
      const createDto = {
        model: 'Forza',
        brand: 'Honda',
        fuelConsumption: 3.5,
      };

      const result = await service.create(createDto);

      expect(result).toBeDefined();
      expect(mockMotorcycleModel.create).toHaveBeenCalled();
    });
  });

  describe('findAll', () => {
    it('should return an array of motorcycles', async () => {
      const result = await service.findAll();

      expect(result).toBeDefined();
      expect(Array.isArray(result)).toBe(true);
    });
  });

  describe('findOne', () => {
    it('should return a motorcycle', async () => {
      const result = await service.findOne('507f1f77bcf86cd799439011');

      expect(result).toBeDefined();
    });

    it('should throw NotFoundException if motorcycle not found', async () => {
      mockMotorcycleModel.findById.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });

      await expect(service.findOne('507f1f77bcf86cd799439011')).rejects.toThrow(NotFoundException);
    });
  });
});
