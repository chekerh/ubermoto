import { Type } from 'class-transformer';
import { IsBoolean, IsOptional, IsString, ValidateNested } from 'class-validator';

class DriverDayScheduleDto {
  @IsBoolean()
  enabled!: boolean;

  @IsOptional()
  @IsString()
  startTime?: string | null;

  @IsOptional()
  @IsString()
  endTime?: string | null;
}

export class UpdateDriverScheduleDto {
  @IsOptional()
  @ValidateNested()
  @Type(() => DriverDayScheduleDto)
  monday?: DriverDayScheduleDto;

  @IsOptional()
  @ValidateNested()
  @Type(() => DriverDayScheduleDto)
  tuesday?: DriverDayScheduleDto;

  @IsOptional()
  @ValidateNested()
  @Type(() => DriverDayScheduleDto)
  wednesday?: DriverDayScheduleDto;

  @IsOptional()
  @ValidateNested()
  @Type(() => DriverDayScheduleDto)
  thursday?: DriverDayScheduleDto;

  @IsOptional()
  @ValidateNested()
  @Type(() => DriverDayScheduleDto)
  friday?: DriverDayScheduleDto;

  @IsOptional()
  @ValidateNested()
  @Type(() => DriverDayScheduleDto)
  saturday?: DriverDayScheduleDto;

  @IsOptional()
  @ValidateNested()
  @Type(() => DriverDayScheduleDto)
  sunday?: DriverDayScheduleDto;
}
