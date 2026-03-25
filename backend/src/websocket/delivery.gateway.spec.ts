import { Test, TestingModule } from '@nestjs/testing';
import { getModelToken } from '@nestjs/mongoose';
import { JwtService } from '@nestjs/jwt';
import { DeliveryGateway } from './delivery.gateway';
import { Delivery } from '../deliveries/schemas/delivery.schema';
import { Driver } from '../drivers/schemas/driver.schema';
import { UserRole } from '../users/schemas/user.schema';

describe('DeliveryGateway', () => {
  let gateway: DeliveryGateway;
  let deliveryModel: {
    findById: jest.Mock;
  };
  let driverModel: {
    findOne: jest.Mock;
    findById: jest.Mock;
  };

  const mockClient = (overrides: Partial<{ userId: string; userRole: UserRole }> = {}) =>
    ({
      userId: 'user-1',
      userRole: UserRole.CUSTOMER,
      join: jest.fn(),
      leave: jest.fn(),
      ...overrides,
    }) as any;

  beforeEach(async () => {
    deliveryModel = {
      findById: jest.fn(),
    };
    driverModel = {
      findOne: jest.fn(),
      findById: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        DeliveryGateway,
        { provide: getModelToken(Delivery.name), useValue: deliveryModel },
        { provide: getModelToken(Driver.name), useValue: driverModel },
        { provide: JwtService, useValue: { verify: jest.fn() } },
      ],
    }).compile();

    gateway = module.get<DeliveryGateway>(DeliveryGateway);
    gateway.server = {
      to: jest.fn().mockReturnThis(),
      emit: jest.fn(),
    } as any;
  });

  describe('handleSubscribeToDelivery', () => {
    it('allows customer who owns the delivery', async () => {
      deliveryModel.findById.mockReturnValue({
        exec: jest.fn().mockResolvedValue({
          userId: { toString: () => 'user-1' },
          driverId: null,
        }),
      });
      const client = mockClient({ userId: 'user-1', userRole: UserRole.CUSTOMER });
      const result = await gateway.handleSubscribeToDelivery({ deliveryId: 'del-1' }, client);
      expect(result).toEqual({ success: true });
      expect(client.join).toHaveBeenCalledWith('delivery_del-1');
    });

    it('denies customer who does not own the delivery', async () => {
      deliveryModel.findById.mockReturnValue({
        exec: jest.fn().mockResolvedValue({
          userId: { toString: () => 'other-user' },
          driverId: null,
        }),
      });
      const client = mockClient({ userId: 'user-1', userRole: UserRole.CUSTOMER });
      const result = await gateway.handleSubscribeToDelivery({ deliveryId: 'del-1' }, client);
      expect(result).toEqual({ success: false, error: 'Forbidden' });
      expect(client.join).not.toHaveBeenCalled();
    });

    it('allows admin for any delivery', async () => {
      deliveryModel.findById.mockReturnValue({
        exec: jest.fn().mockResolvedValue({
          userId: { toString: () => 'other-user' },
          driverId: null,
        }),
      });
      const client = mockClient({ userId: 'admin-1', userRole: UserRole.ADMIN });
      const result = await gateway.handleSubscribeToDelivery({ deliveryId: 'del-1' }, client);
      expect(result).toEqual({ success: true });
      expect(client.join).toHaveBeenCalledWith('delivery_del-1');
    });

    it('allows assigned driver (Driver doc matches delivery.driverId)', async () => {
      deliveryModel.findById.mockReturnValue({
        exec: jest.fn().mockResolvedValue({
          userId: { toString: () => 'customer-1' },
          driverId: { toString: () => 'mongo-driver-1' },
        }),
      });
      driverModel.findOne.mockReturnValue({
        exec: jest.fn().mockResolvedValue({
          _id: { toString: () => 'mongo-driver-1' },
          userId: 'driver-user-1',
        }),
      });
      const client = mockClient({
        userId: 'driver-user-1',
        userRole: UserRole.DRIVER,
      });
      const result = await gateway.handleSubscribeToDelivery({ deliveryId: 'del-1' }, client);
      expect(result).toEqual({ success: true });
      expect(driverModel.findOne).toHaveBeenCalledWith({ userId: 'driver-user-1' });
    });

    it('denies driver not assigned to delivery', async () => {
      deliveryModel.findById.mockReturnValue({
        exec: jest.fn().mockResolvedValue({
          userId: { toString: () => 'customer-1' },
          driverId: { toString: () => 'mongo-driver-1' },
        }),
      });
      driverModel.findOne.mockReturnValue({
        exec: jest.fn().mockResolvedValue({
          _id: { toString: () => 'different-mongo-driver' },
          userId: 'driver-user-1',
        }),
      });
      const client = mockClient({
        userId: 'driver-user-1',
        userRole: UserRole.DRIVER,
      });
      const result = await gateway.handleSubscribeToDelivery({ deliveryId: 'del-1' }, client);
      expect(result).toEqual({ success: false, error: 'Forbidden' });
    });

    it('returns not found when delivery missing', async () => {
      deliveryModel.findById.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });
      const result = await gateway.handleSubscribeToDelivery(
        { deliveryId: 'missing' },
        mockClient(),
      );
      expect(result).toEqual({ success: false, error: 'Delivery not found' });
    });
  });

  describe('handleUpdateLocation', () => {
    it('rejects non-drivers', async () => {
      const result = await gateway.handleUpdateLocation(
        { deliveryId: 'd1', latitude: 1, longitude: 2 },
        mockClient({ userRole: UserRole.CUSTOMER }),
      );
      expect(result).toEqual({ error: 'Unauthorized' });
    });

    it('broadcasts when driver is assigned to delivery', async () => {
      deliveryModel.findById.mockReturnValue({
        exec: jest.fn().mockResolvedValue({
          driverId: { toString: () => 'mongo-driver-1' },
        }),
      });
      driverModel.findOne.mockReturnValue({
        exec: jest.fn().mockResolvedValue({
          _id: { toString: () => 'mongo-driver-1' },
          userId: 'driver-user-1',
        }),
      });
      const toMock = jest.fn().mockReturnThis();
      const emitMock = jest.fn();
      gateway.server = { to: toMock, emit: emitMock } as any;

      const result = await gateway.handleUpdateLocation(
        { deliveryId: 'del-1', latitude: 36.8, longitude: 10.18 },
        mockClient({ userId: 'driver-user-1', userRole: UserRole.DRIVER }),
      );

      expect(result).toEqual({ success: true });
      expect(toMock).toHaveBeenCalledWith('delivery_del-1');
      expect(emitMock).toHaveBeenCalledWith(
        'location_update',
        expect.objectContaining({
          deliveryId: 'del-1',
          latitude: 36.8,
          longitude: 10.18,
        }),
      );
    });

    it('rejects driver not assigned to delivery', async () => {
      deliveryModel.findById.mockReturnValue({
        exec: jest.fn().mockResolvedValue({
          driverId: { toString: () => 'mongo-driver-1' },
        }),
      });
      driverModel.findOne.mockReturnValue({
        exec: jest.fn().mockResolvedValue({
          _id: { toString: () => 'other-driver' },
          userId: 'driver-user-1',
        }),
      });
      const result = await gateway.handleUpdateLocation(
        { deliveryId: 'del-1', latitude: 1, longitude: 2 },
        mockClient({ userId: 'driver-user-1', userRole: UserRole.DRIVER }),
      );
      expect(result).toEqual({ error: 'Unauthorized' });
    });
  });
});
