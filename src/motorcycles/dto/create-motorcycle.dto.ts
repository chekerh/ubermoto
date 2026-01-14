import { IsString, IsNumber, IsOptional, Min, Max } from 'class-validator';

export class CreateMotorcycleDto {
  @IsString()
  model!: string;

  @IsString()
  brand!: string;

  @IsNumber()
  @Min(0.1)
  @Max(20)
  fuelConsumption!: number; // Liters per 100 km

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
