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

    const userId = user._id.toString();
    console.log('Created user:', { id: userId, email: user.email, role: user.role });

    return this.generateToken(userId, user.email, user.role);
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

    const driverUserId = user._id.toString();
    console.log('Created driver user:', { id: driverUserId, email: user.email, role: user.role });

    // Create driver profile
    await this.driversService.create({
      userId: driverUserId,
      licenseNumber: registerDto.licenseNumber,
      phoneNumber: registerDto.phoneNumber,
    });

    return this.generateToken(driverUserId, user.email, user.role);
  }

  // Keep backward compatibility (deprecated)
  async register(registerDto: RegisterDto): Promise<AuthResponse> {
    return this.registerCustomer(registerDto as CustomerRegisterDto);
  }

  async login(loginDto: LoginDto): Promise<AuthResponse> {
    console.log('Login attempt for email:', loginDto.email);

    const user = await this.usersService.findByEmail(loginDto.email);
    console.log('User found:', user ? { id: user._id.toString(), email: user.email } : 'null');

    if (!user) {
      console.log('No user found with email:', loginDto.email);
      throw new UnauthorizedException('Invalid credentials');
    }

    const isPasswordValid = await bcrypt.compare(loginDto.password, user.password);
    console.log('Password valid:', isPasswordValid);

    if (!isPasswordValid) {
      console.log('Invalid password for user:', user.email);
      throw new UnauthorizedException('Invalid credentials');
    }

    const loginUserId = user._id.toString();
    console.log('Login successful for user:', { id: loginUserId, email: user.email });
    return this.generateToken(loginUserId, user.email, user.role);
  }

  async validateUser(payload: JwtPayload): Promise<unknown> {
    console.log('Validating user with payload:', payload);

    const user = await this.usersService.findById(payload.sub);
    console.log('Found user:', user ? { id: user._id.toString(), email: user.email } : 'null');

    if (!user) {
      console.log('User not found for ID:', payload.sub);
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
