import { IsString, IsNumber, IsOptional, Min, Max } from 'class-validator';
import { CreateMotorcycleDto } from './create-motorcycle.dto';

export class UpdateMotorcycleDto {
  @IsString()
  @IsOptional()
  model?: string;

  @IsString()
  @IsOptional()
  brand?: string;

  @IsNumber()
  @IsOptional()
  @Min(0.1)
  @Max(20)
  fuelConsumption?: number;

  @IsString()
  @IsOptional()
  engineType?: string;

  @IsNumber()
  @IsOptional()
  @Min(50)
  @Max(2000)
  capacity?: number;

  @IsNumber()
  @IsOptional()
  @Min(1950)
  @Max(2030)
  year?: number;
}
