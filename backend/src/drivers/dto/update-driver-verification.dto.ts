import { IsBoolean } from 'class-validator';

export class UpdateDriverVerificationDto {
  @IsBoolean()
  isVerified!: boolean;
}
