import { IsNotEmpty, IsString } from 'class-validator';

export class UpdateMotorcycleDto {
  @IsString()
  @IsNotEmpty()
  motorcycleId!: string;
}
