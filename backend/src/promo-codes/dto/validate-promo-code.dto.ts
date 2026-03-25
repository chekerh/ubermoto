import { IsNumber, IsOptional, IsString, Min } from 'class-validator';

export class ValidatePromoCodeDto {
  @IsString()
  code!: string;

  @IsOptional()
  @IsNumber()
  @Min(0)
  subtotal?: number;
}
