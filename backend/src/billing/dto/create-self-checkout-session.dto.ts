import { IsMongoId, IsOptional, IsString, IsUrl } from 'class-validator';

export class CreateSelfCheckoutSessionDto {
  /** When omitted, uses the user’s first active membership (sorted by createdAt). */
  @IsOptional()
  @IsMongoId()
  merchantId?: string;

  @IsString()
  planKey!: string;

  @IsUrl()
  successUrl!: string;

  @IsUrl()
  cancelUrl!: string;
}

