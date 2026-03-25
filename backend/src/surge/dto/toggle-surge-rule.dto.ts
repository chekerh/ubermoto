import { IsBoolean } from 'class-validator';

export class ToggleSurgeRuleDto {
  @IsBoolean()
  active!: boolean;
}
