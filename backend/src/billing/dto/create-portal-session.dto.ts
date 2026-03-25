import { IsString, IsUrl } from 'class-validator';

export class CreatePortalSessionDto {
  @IsString()
  merchantId!: string;

  @IsUrl()
  returnUrl!: string;
}

