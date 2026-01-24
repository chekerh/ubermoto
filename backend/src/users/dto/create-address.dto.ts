import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsBoolean,
  IsObject,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';

class CoordinatesDto {
  @IsOptional()
  lat?: number;

  @IsOptional()
  lng?: number;
}

export class CreateAddressDto {
  @IsString()
  @IsNotEmpty()
  label!: string;

  @IsString()
  @IsNotEmpty()
  address!: string;

  @IsString()
  @IsNotEmpty()
  city!: string;

  @IsString()
  @IsOptional()
  postalCode?: string;

  @IsObject()
  @IsOptional()
  @ValidateNested()
  @Type(() => CoordinatesDto)
  coordinates?: CoordinatesDto;

  @IsBoolean()
  @IsOptional()
  isDefault?: boolean;
}

export class UpdateAddressDto {
  @IsString()
  @IsOptional()
  label?: string;

  @IsString()
  @IsOptional()
  address?: string;

  @IsString()
  @IsOptional()
  city?: string;

  @IsString()
  @IsOptional()
  postalCode?: string;

  @IsObject()
  @IsOptional()
  @ValidateNested()
  @Type(() => CoordinatesDto)
  coordinates?: CoordinatesDto;

  @IsBoolean()
  @IsOptional()
  isDefault?: boolean;
}
