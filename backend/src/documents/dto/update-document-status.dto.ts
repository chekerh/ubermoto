import { IsEnum, IsOptional, IsString } from 'class-validator';
import { DocumentStatus } from '../schemas/document.schema';

export class UpdateDocumentStatusDto {
  @IsEnum(DocumentStatus)
  status!: DocumentStatus;

  @IsOptional()
  @IsString()
  rejectionReason?: string;
}
