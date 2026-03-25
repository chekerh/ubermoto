import { Test, TestingModule } from '@nestjs/testing';
import { getConnectionToken } from '@nestjs/mongoose';
import { ServiceUnavailableException } from '@nestjs/common';
import { HealthController } from './health.controller';

describe('HealthController', () => {
  let controller: HealthController;
  let mockAdminCommand: jest.Mock;

  const createController = (readyState: number, pingOk: boolean) => {
    mockAdminCommand = jest.fn().mockImplementation(() =>
      pingOk ? Promise.resolve({ ok: 1 }) : Promise.reject(new Error('ping failed')),
    );
    const mockConnection = {
      readyState,
      db: {
        admin: () => ({
          command: mockAdminCommand,
        }),
      },
    };
    return mockConnection;
  };

  beforeEach(async () => {
    const mockConnection = createController(1, true);

    const module: TestingModule = await Test.createTestingModule({
      controllers: [HealthController],
      providers: [
        {
          provide: getConnectionToken(),
          useValue: mockConnection,
        },
      ],
    }).compile();

    controller = module.get<HealthController>(HealthController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('check', () => {
    it('should return ok when connected and ping succeeds', async () => {
      const result = await controller.check();
      expect(result).toEqual({ status: 'ok', mongodb: 'up' });
      expect(mockAdminCommand).toHaveBeenCalledWith({ ping: 1 });
    });

    it('should throw ServiceUnavailable when not connected', async () => {
      const mockConnection = {
        readyState: 0,
        db: { admin: () => ({ command: jest.fn() }) },
      };
      const module: TestingModule = await Test.createTestingModule({
        controllers: [HealthController],
        providers: [{ provide: getConnectionToken(), useValue: mockConnection }],
      }).compile();
      const c = module.get<HealthController>(HealthController);
      await expect(c.check()).rejects.toThrow(ServiceUnavailableException);
    });

    it('should throw ServiceUnavailable when ping fails', async () => {
      const mockConnection = {
        readyState: 1,
        db: {
          admin: () => ({
            command: jest.fn().mockRejectedValue(new Error('down')),
          }),
        },
      };
      const module: TestingModule = await Test.createTestingModule({
        controllers: [HealthController],
        providers: [{ provide: getConnectionToken(), useValue: mockConnection }],
      }).compile();
      const c = module.get<HealthController>(HealthController);
      await expect(c.check()).rejects.toThrow(ServiceUnavailableException);
    });
  });
});
