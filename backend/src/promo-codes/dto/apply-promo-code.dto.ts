import { IsNumber, IsString, Min } from 'class-validator';

export class ApplyPromoCodeDto {
  @IsString()
  code!: string;

  @IsNumber()
  @Min(0)
  orderTotal!: number;
}
