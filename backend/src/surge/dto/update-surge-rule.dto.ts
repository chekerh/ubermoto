import { PartialType } from '@nestjs/mapped-types';
import { CreateSurgeRuleDto } from './create-surge-rule.dto';

export class UpdateSurgeRuleDto extends PartialType(CreateSurgeRuleDto) {}
