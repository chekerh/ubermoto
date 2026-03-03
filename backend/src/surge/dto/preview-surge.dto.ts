import { IsDateString, IsNotEmpty, IsNumber, IsOptional, IsString } from 'class-validator';

export class PreviewSurgeDto {
  @IsString()
  @IsNotEmpty()
  region!: string;

  @IsDateString()
  @IsOptional()
  timestamp?: string;

  @IsNumber()
  @IsOptional()
  latitude?: number;

  @IsNumber()
  @IsOptional()
  longitude?: number;
}
