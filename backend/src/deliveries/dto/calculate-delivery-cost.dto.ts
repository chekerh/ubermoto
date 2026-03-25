import { Type } from 'class-transformer';
import { IsNumber, IsOptional, IsString, Min } from 'class-validator';

export class CalculateDeliveryCostDto {
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  distance!: number;

  @IsString()
  motorcycleId!: string;

  @IsOptional()
  @IsString()
  region?: string;
}
