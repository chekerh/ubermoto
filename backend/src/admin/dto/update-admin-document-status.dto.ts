import { IsEnum, IsOptional, IsString } from 'class-validator';
import { DocumentStatus } from '../../documents/schemas/document.schema';

export class UpdateAdminDocumentStatusDto {
  @IsEnum(DocumentStatus)
  status!: DocumentStatus;

  @IsOptional()
  @IsString()
  rejectionReason?: string;
}
