import { Test, TestingModule } from '@nestjs/testing';
import { DeliveryGateway } from './delivery.gateway';
import { JwtService } from '@nestjs/jwt';

describe('DeliveryGateway', () => {
  let gateway: DeliveryGateway;
  let jwtService: JwtService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        DeliveryGateway,
        {
          provide: JwtService,
          useValue: {
            verify: jest.fn().mockReturnValue({ sub: 'user-id', role: 'DRIVER' }),
          },
        },
      ],
    }).compile();

    gateway = module.get<DeliveryGateway>(DeliveryGateway);
    jwtService = module.get<JwtService>(JwtService);
  });

  it('should be defined', () => {
    expect(gateway).toBeDefined();
  });

  describe('handleConnection', () => {
    it('should authenticate user and join rooms', () => {
      const mockClient = {
        handshake: {
          auth: { token: 'valid-token' },
        },
        userId: null,
        userRole: null,
        join: jest.fn(),
        disconnect: jest.fn(),
      };

      gateway.handleConnection(mockClient as any);

      expect(mockClient.userId).toBe('user-id');
      expect(mockClient.userRole).toBe('DRIVER');
      expect(mockClient.join).toHaveBeenCalledWith('user_user-id');
      expect(mockClient.join).toHaveBeenCalledWith('role_DRIVER');
    });

    it('should disconnect client without token', () => {
      const mockClient = {
        handshake: { auth: {} },
        disconnect: jest.fn(),
      };

      gateway.handleConnection(mockClient as any);

      expect(mockClient.disconnect).toHaveBeenCalled();
    });
  });

  describe('emitDeliveryStatusUpdate', () => {
    it('should emit status update to delivery room and users', () => {
      const mockServer = {
        to: jest.fn().mockReturnThis(),
        emit: jest.fn(),
      };

      gateway.server = mockServer as any;

      const mockDelivery = {
        _id: 'delivery-id',
        status: 'completed',
        driverId: 'driver-id',
        updatedAt: new Date(),
      };

      gateway.emitDeliveryStatusUpdate('delivery-id', mockDelivery);

      expect(mockServer.to).toHaveBeenCalledWith('delivery_delivery-id');
      expect(mockServer.emit).toHaveBeenCalledWith('delivery_status_update', {
        deliveryId: 'delivery-id',
        status: 'completed',
        driverId: 'driver-id',
        updatedAt: mockDelivery.updatedAt,
      });
    });
  });

  describe('emitNewDelivery', () => {
    it('should emit new delivery to available drivers', () => {
      const mockServer = {
        to: jest.fn().mockReturnThis(),
        emit: jest.fn(),
      };

      gateway.server = mockServer as any;

      const mockDelivery = {
        _id: 'delivery-id',
        pickupLocation: 'Location A',
        deliveryAddress: 'Location B',
        deliveryType: 'Food',
        estimatedCost: 12.50,
        distance: 5.2,
        createdAt: new Date(),
      };

      gateway.emitNewDelivery(mockDelivery);

      expect(mockServer.to).toHaveBeenCalledWith('role_DRIVER');
      expect(mockServer.emit).toHaveBeenCalledWith('new_delivery', {
        deliveryId: 'delivery-id',
        pickupLocation: 'Location A',
        deliveryAddress: 'Location B',
        deliveryType: 'Food',
        estimatedCost: 12.50,
        distance: 5.2,
        createdAt: mockDelivery.createdAt,
      });
    });
  });
});