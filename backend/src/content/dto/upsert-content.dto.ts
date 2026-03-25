import { IsBoolean, IsInt, IsObject, IsOptional, IsString, Max, Min } from 'class-validator';

export class UpsertContentDto {
  @IsString()
  key!: string;

  @IsInt()
  @Min(1)
  @Max(50)
  schemaVersion!: number;

  @IsObject()
  data!: Record<string, any>;

  @IsOptional()
  @IsBoolean()
  publish?: boolean;
}

