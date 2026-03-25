import { IsBoolean, IsObject, IsOptional, IsString } from 'class-validator';

export class UpsertPlanDto {
  @IsString()
  key!: string;

  @IsString()
  name!: string;

  @IsString()
  description!: string;

  @IsString()
  stripePriceId!: string;

  @IsObject()
  features!: Record<string, boolean>;

  @IsObject()
  limits!: Record<string, number>;

  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}
