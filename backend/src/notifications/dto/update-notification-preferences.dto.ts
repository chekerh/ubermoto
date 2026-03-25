import { IsArray, IsOptional, IsString } from 'class-validator';

export class UpdateNotificationPreferencesDto {
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  categories?: string[];
}
