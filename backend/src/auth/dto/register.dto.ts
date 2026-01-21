import { IsEmail, IsNotEmpty, IsString, MinLength, IsOptional, IsEnum } from 'class-validator';
import { UserRole } from '../../users/schemas/user.schema';

// Base registration DTO
export class BaseRegisterDto {
  @IsEmail()
  @IsNotEmpty()
  email!: string;

  @IsString()
  @IsNotEmpty()
  @MinLength(6)
  password!: string;

  @IsString()
  @IsNotEmpty()
  name!: string;
}

// Customer registration DTO
export class CustomerRegisterDto extends BaseRegisterDto {
  @IsEnum(UserRole)
  @IsOptional()
  role?: UserRole = UserRole.CUSTOMER;
}

// Driver registration DTO
export class DriverRegisterDto extends BaseRegisterDto {
  @IsEnum(UserRole)
  @IsOptional()
  role?: UserRole = UserRole.DRIVER;

  @IsString()
  @IsNotEmpty()
  phoneNumber!: string;

  @IsString()
  @IsNotEmpty()
  licenseNumber!: string;
}

// Keep the original for backward compatibility (will be deprecated)
export class RegisterDto extends BaseRegisterDto {}
