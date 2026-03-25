import { IsMongoId, IsOptional, IsUrl } from 'class-validator';

export class CreateSelfPortalSessionDto {
  /** When omitted, uses the user’s first active membership (sorted by createdAt). */
  @IsOptional()
  @IsMongoId()
  merchantId?: string;

  @IsUrl()
  returnUrl!: string;
}
