import { IsEnum } from 'class-validator';
import { DocumentType } from '../schemas/document.schema';

export class UploadDocumentDto {
  @IsEnum(DocumentType)
  documentType!: DocumentType;
}
