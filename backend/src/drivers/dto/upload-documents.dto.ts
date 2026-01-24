import { IsOptional, IsString } from 'class-validator';

export class UploadDocumentsDto {
  @IsOptional()
  @IsString()
  licenseDocument?: string;

  @IsOptional()
  @IsString()
  idDocument?: string;

  @IsOptional()
  @IsString()
  motorcycleDocument?: string;
}

export class UpdateDriverDocumentsDto {
  @IsOptional()
  @IsString()
  licenseDocument?: string;

  @IsOptional()
  @IsString()
  idDocument?: string;

  @IsOptional()
  @IsString()
  motorcycleDocument?: string;
}
