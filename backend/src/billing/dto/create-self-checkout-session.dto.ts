import { IsString, IsUrl } from 'class-validator';

export class CreateSelfCheckoutSessionDto {
  @IsString()
  planKey!: string;

  @IsUrl()
  successUrl!: string;

  @IsUrl()
  cancelUrl!: string;
}

