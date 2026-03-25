import { Type } from 'class-transformer';
import { IsNumber, IsOptional, Min } from 'class-validator';

export class CompleteDeliveryDto {
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  actualCost?: number;
}
