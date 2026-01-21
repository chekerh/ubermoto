import { Injectable, UnauthorizedException, ConflictException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { UsersService } from '../users/users.service';
import { DriversService } from '../drivers/drivers.service';
import { LoginDto } from './dto/login.dto';
import { CustomerRegisterDto, DriverRegisterDto, RegisterDto } from './dto/register.dto';
import { UserRole } from '../users/schemas/user.schema';

export interface JwtPayload {
  sub: string;
  email: string;
  role: UserRole;
}

export interface AuthResponse {
  access_token: string;
}

@Injectable()
export class AuthService {
  constructor(
    private readonly usersService: UsersService,
    private readonly driversService: DriversService,
    private readonly jwtService: JwtService,
  ) {}

  async registerCustomer(registerDto: CustomerRegisterDto): Promise<AuthResponse> {
    const existingUser = await this.usersService.findByEmail(registerDto.email);

    if (existingUser) {
      throw new ConflictException('User with this email already exists');
    }

    const hashedPassword = await bcrypt.hash(registerDto.password, 10);

    const user = await this.usersService.create(
      registerDto.email,
      hashedPassword,
      registerDto.name,
      UserRole.CUSTOMER,
    );

    return this.generateToken(user._id.toString(), user.email, user.role);
  }

  async registerDriver(registerDto: DriverRegisterDto): Promise<AuthResponse> {
    const existingUser = await this.usersService.findByEmail(registerDto.email);

    if (existingUser) {
      throw new ConflictException('User with this email already exists');
    }

    const hashedPassword = await bcrypt.hash(registerDto.password, 10);

    const user = await this.usersService.create(
      registerDto.email,
      hashedPassword,
      registerDto.name,
      UserRole.DRIVER,
      registerDto.phoneNumber,
    );

    // Create driver profile
    await this.driversService.create({
      userId: user._id.toString(),
      licenseNumber: registerDto.licenseNumber,
      phoneNumber: registerDto.phoneNumber,
    });

    return this.generateToken(user._id.toString(), user.email, user.role);
  }

  // Keep backward compatibility (deprecated)
  async register(registerDto: RegisterDto): Promise<AuthResponse> {
    return this.registerCustomer(registerDto as CustomerRegisterDto);
  }

  async login(loginDto: LoginDto): Promise<AuthResponse> {
    const user = await this.usersService.findByEmail(loginDto.email);

    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const isPasswordValid = await bcrypt.compare(loginDto.password, user.password);

    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    return this.generateToken(user._id.toString(), user.email, user.role);
  }

  async validateUser(payload: JwtPayload): Promise<unknown> {
    const user = await this.usersService.findById(payload.sub);

    if (!user) {
      throw new UnauthorizedException('User not found');
    }

    return {
      id: user._id.toString(),
      email: user.email,
      name: user.name,
      role: user.role,
      isVerified: user.isVerified,
      phoneNumber: user.phoneNumber,
    };
  }

  private generateToken(userId: string, email: string, role: UserRole): AuthResponse {
    const payload: JwtPayload = {
      sub: userId,
      email,
      role,
    };

    const token = this.jwtService.sign(payload);
    return {
      access_token: token,
    };
  }
}
