import { IsString, IsUrl } from 'class-validator';

export class CreateCheckoutSessionDto {
  @IsString()
  merchantId!: string;

  @IsString()
  planKey!: string;

  @IsUrl()
  successUrl!: string;

  @IsUrl()
  cancelUrl!: string;
}
