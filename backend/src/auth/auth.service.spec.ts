import { Test, TestingModule } from '@nestjs/testing';
import { AuthService } from './auth.service';
import { UsersService } from '../users/users.service';
import { DriversService } from '../drivers/drivers.service';
import { JwtService } from '@nestjs/jwt';
import { UnauthorizedException, ConflictException } from '@nestjs/common';
import * as bcrypt from 'bcryptjs';

// Mock bcryptjs so tests never depend on real hashing
jest.mock('bcryptjs', () => ({
  hash: jest.fn(),
  compare: jest.fn(),
}));

describe('AuthService', () => {
  let service: AuthService;
  let usersService: any;
  let driversService: any;
  let jwtService: any;

  const mockUser = {
    _id: { toString: () => '507f1f77bcf86cd799439011' },
    id: '507f1f77bcf86cd799439011',
    email: 'test@example.com',
    name: 'Test User',
    password: 'hashed-password',
    role: 'CUSTOMER',
    isVerified: true,
    phoneNumber: '+21612345678',
  };

  beforeEach(async () => {
    usersService = {
      findByEmail: jest.fn(),
      findByPhoneNumber: jest.fn(),
      create: jest.fn(),
    };

    driversService = {
      create: jest.fn(),
      findByUserId: jest.fn(),
    };

    jwtService = {
      sign: jest.fn().mockReturnValue('mock.jwt.token'),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        { provide: UsersService, useValue: usersService },
        { provide: DriversService, useValue: driversService },
        { provide: JwtService, useValue: jwtService },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  // ── Login ────────────────────────────────────────────────────────────

  describe('login', () => {
    it('should return access_token for valid email + password', async () => {
      usersService.findByEmail!.mockResolvedValue(mockUser as any);
      (bcrypt.compare as jest.Mock).mockResolvedValue(true);

      const result = await service.login({
        email: 'test@example.com',
        password: 'password123',
      });

      expect(result).toEqual({ access_token: 'mock.jwt.token' });
      expect(usersService.findByEmail).toHaveBeenCalledWith('test@example.com');
      expect(bcrypt.compare).toHaveBeenCalledWith('password123', 'hashed-password');
      expect(jwtService.sign).toHaveBeenCalledWith({
        sub: '507f1f77bcf86cd799439011',
        email: 'test@example.com',
        role: 'CUSTOMER',
      });
    });

    it('should support login with phone number', async () => {
      usersService.findByPhoneNumber!.mockResolvedValue(mockUser as any);
      (bcrypt.compare as jest.Mock).mockResolvedValue(true);

      const result = await service.login({
        email: '+21612345678', // phone number in email field
        password: 'password123',
      });

      expect(result).toEqual({ access_token: 'mock.jwt.token' });
      expect(usersService.findByPhoneNumber).toHaveBeenCalledWith('+21612345678');
      expect(usersService.findByEmail).not.toHaveBeenCalled();
    });

    it('should throw UnauthorizedException when user not found', async () => {
      usersService.findByEmail!.mockResolvedValue(null);

      await expect(
        service.login({ email: 'nobody@example.com', password: 'x' }),
      ).rejects.toThrow(UnauthorizedException);
    });

    it('should throw UnauthorizedException when password is wrong', async () => {
      usersService.findByEmail!.mockResolvedValue(mockUser as any);
      (bcrypt.compare as jest.Mock).mockResolvedValue(false);

      await expect(
        service.login({ email: 'test@example.com', password: 'wrong' }),
      ).rejects.toThrow(UnauthorizedException);
    });
  });

  // ── Customer Registration ────────────────────────────────────────────

  describe('registerCustomer', () => {
    it('should hash password and return token', async () => {
      usersService.findByEmail!.mockResolvedValue(null);
      (bcrypt.hash as jest.Mock).mockResolvedValue('hashed-new-password');
      usersService.create!.mockResolvedValue(mockUser as any);

      const result = await service.registerCustomer({
        email: 'new@example.com',
        password: 'password123',
        name: 'New User',
      });

      expect(result).toEqual({ access_token: 'mock.jwt.token' });
      expect(bcrypt.hash).toHaveBeenCalledWith('password123', 10);
      expect(usersService.create).toHaveBeenCalledWith(
        'new@example.com',
        'hashed-new-password',
        'New User',
        'CUSTOMER',
      );
    });

    it('should throw ConflictException if email already exists', async () => {
      usersService.findByEmail!.mockResolvedValue(mockUser as any);

      await expect(
        service.registerCustomer({
          email: 'test@example.com',
          password: 'password123',
          name: 'Dup',
        }),
      ).rejects.toThrow(ConflictException);
    });
  });

  // ── Driver Registration ──────────────────────────────────────────────

  describe('registerDriver', () => {
    it('should create user + driver profile and return token', async () => {
      usersService.findByEmail!.mockResolvedValue(null);
      (bcrypt.hash as jest.Mock).mockResolvedValue('hashed-driver-pw');
      usersService.create!.mockResolvedValue({
        ...mockUser,
        role: 'DRIVER',
      } as any);
      driversService.create!.mockResolvedValue({} as any);

      const result = await service.registerDriver({
        email: 'driver@example.com',
        password: 'password123',
        name: 'Test Driver',
        phoneNumber: '+21698765432',
        licenseNumber: 'DRV-001',
      });

      expect(result).toEqual({ access_token: 'mock.jwt.token' });
      expect(driversService.create).toHaveBeenCalledWith({
        userId: '507f1f77bcf86cd799439011',
        licenseNumber: 'DRV-001',
        phoneNumber: '+21698765432',
      });
    });

    it('should throw ConflictException if email already exists', async () => {
      usersService.findByEmail!.mockResolvedValue(mockUser as any);

      await expect(
        service.registerDriver({
          email: 'test@example.com',
          password: 'x',
          name: 'Dup',
          phoneNumber: '+216111',
          licenseNumber: 'X',
        }),
      ).rejects.toThrow(ConflictException);
    });
  });
});
