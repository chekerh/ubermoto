import { IsUrl } from 'class-validator';

export class CreateSelfPortalSessionDto {
  @IsUrl()
  returnUrl!: string;
}

