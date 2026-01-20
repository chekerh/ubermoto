import { IsString, IsNotEmpty, IsOptional, IsNumber, Min } from 'class-validator';

export class CreateDeliveryDto {
  @IsString()
  @IsNotEmpty()
  pickupLocation!: string;

  @IsString()
  @IsNotEmpty()
  deliveryAddress!: string;

  @IsString()
  @IsNotEmpty()
  deliveryType!: string;

  @IsNumber()
  @IsOptional()
  @Min(0)
  distance?: number;

  @IsString()
  @IsOptional()
  motorcycleId?: string;
}
