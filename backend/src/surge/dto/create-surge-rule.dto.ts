import { IsArray, IsBoolean, IsNotEmpty, IsNumber, IsOptional, IsString, Max, Min } from 'class-validator';

export class CreateSurgeRuleDto {
  @IsString()
  @IsNotEmpty()
  label!: string;

  @IsString()
  @IsNotEmpty()
  region!: string;

  @IsArray()
  @IsOptional()
  polygon?: number[][];

  @IsArray()
  @IsOptional()
  weekdays?: number[];

  @IsString()
  @IsNotEmpty()
  startTime!: string; // HH:mm

  @IsString()
  @IsNotEmpty()
  endTime!: string; // HH:mm

  @IsNumber()
  @Min(1)
  @Max(10)
  multiplier!: number;

  @IsBoolean()
  @IsOptional()
  active?: boolean;
}
