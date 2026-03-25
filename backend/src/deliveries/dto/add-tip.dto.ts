import { Type } from 'class-transformer';
import { IsNumber, Min } from 'class-validator';

export class AddTipDto {
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  tipAmount!: number;
}
