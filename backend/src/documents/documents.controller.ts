import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Patch,
  Delete,
  UseGuards,
  UploadedFile,
  UseInterceptors,
  HttpCode,
  HttpStatus,
  Request,
  BadRequestException,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ApiTags, ApiOperation, ApiResponse, ApiConsumes, ApiBody } from '@nestjs/swagger';
import { DocumentsService, CreateDocumentDto } from './documents.service';
import { DocumentType, DocumentStatus } from './schemas/document.schema';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { UserRole } from '../users/schemas/user.schema';
import * as fs from 'fs';
import * as path from 'path';

interface AuthenticatedRequest extends Request {
  user: {
    sub: string;
    email: string;
    role: UserRole;
  };
}

@ApiTags('documents')
@Controller('documents')
@UseGuards(JwtAuthGuard, RolesGuard)
export class DocumentsController {
  private readonly uploadsDir = path.join(process.cwd(), 'uploads');
  private readonly maxFileSize = 5 * 1024 * 1024; // 5MB
  private readonly allowedMimeTypes = [
    'image/jpeg',
    'image/jpg',
    'image/png',
    'image/webp',
    'application/pdf',
  ];

  constructor(private readonly documentsService: DocumentsService) {
    // Ensure uploads directory exists
    this.ensureUploadsDirectory();
  }

  private ensureUploadsDirectory(): void {
    const documentTypes = Object.values(DocumentType);
    documentTypes.forEach((docType) => {
      const dir = path.join(this.uploadsDir, 'documents', docType.toLowerCase().replace('_', '-'));
      if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
      }
    });
  }

  private validateFile(file: Express.Multer.File): void {
    if (!file) {
      throw new BadRequestException('No file uploaded');
    }

    if (file.size > this.maxFileSize) {
      throw new BadRequestException(`File size exceeds maximum allowed size of ${this.maxFileSize / 1024 / 1024}MB`);
    }

    if (!this.allowedMimeTypes.includes(file.mimetype)) {
      throw new BadRequestException(
        `Invalid file type. Allowed types: ${this.allowedMimeTypes.join(', ')}`,
      );
    }
  }

  private getDocumentDirectory(documentType: DocumentType): string {
    return path.join(
      this.uploadsDir,
      'documents',
      documentType.toLowerCase().replace('_', '-'),
    );
  }

  @Post('upload')
  @Roles(UserRole.DRIVER)
  @UseInterceptors(FileInterceptor('file'))
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        file: {
          type: 'string',
          format: 'binary',
        },
        documentType: {
          type: 'string',
          enum: Object.values(DocumentType),
        },
      },
    },
  })
  @ApiOperation({ summary: 'Upload a document for verification' })
  @ApiResponse({
    status: 201,
    description: 'Document uploaded successfully',
  })
  async uploadDocument(
    @UploadedFile() file: Express.Multer.File,
    @Body() body: { documentType: DocumentType },
    @Request() req: AuthenticatedRequest,
  ) {
    // Validate file
    this.validateFile(file);

    // Validate document type
    if (!body.documentType || !Object.values(DocumentType).includes(body.documentType)) {
      throw new BadRequestException('Invalid document type');
    }

    // Generate unique filename
    const fileName = `${Date.now()}-${req.user.sub}-${file.originalname}`;
    const documentDir = this.getDocumentDirectory(body.documentType);
    const filePath = path.join(documentDir, fileName);

    // Ensure directory exists
    if (!fs.existsSync(documentDir)) {
      fs.mkdirSync(documentDir, { recursive: true });
    }

    // Write file to disk
    try {
      fs.writeFileSync(filePath, file.buffer);
    } catch (error) {
      throw new BadRequestException(`Failed to save file: ${error instanceof Error ? error.message : 'Unknown error'}`);
    }

    // Create relative path for storage in database
    const relativePath = path.relative(process.cwd(), filePath);

    const createDocumentDto: CreateDocumentDto = {
      userId: req.user.sub,
      documentType: body.documentType,
      fileName: file.originalname,
      filePath: relativePath,
      mimeType: file.mimetype,
      fileSize: file.size,
    };

    return this.documentsService.create(createDocumentDto);
  }

  @Get('my-documents')
  @ApiOperation({ summary: 'Get current user documents' })
  @ApiResponse({
    status: 200,
    description: 'List of user documents',
  })
  getMyDocuments(@Request() req: AuthenticatedRequest) {
    return this.documentsService.findAllByUserId(req.user.sub);
  }

  @Get('stats')
  @ApiOperation({ summary: 'Get document verification stats for current user' })
  @ApiResponse({
    status: 200,
    description: 'Document verification statistics',
  })
  getDocumentStats(@Request() req: AuthenticatedRequest) {
    return this.documentsService.getDocumentStats(req.user.sub);
  }

  @Get('pending')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get all pending documents (Admin only)' })
  @ApiResponse({
    status: 200,
    description: 'List of pending documents',
  })
  getPendingDocuments() {
    return this.documentsService.findPendingDocuments();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get document by ID' })
  @ApiResponse({
    status: 200,
    description: 'Document details',
  })
  @ApiResponse({ status: 404, description: 'Document not found' })
  findOne(@Param('id') id: string) {
    return this.documentsService.findOne(id);
  }

  @Patch(':id/status')
  @Roles(UserRole.ADMIN)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Update document status (Admin only)' })
  @ApiResponse({
    status: 200,
    description: 'Document status updated',
  })
  @ApiResponse({ status: 404, description: 'Document not found' })
  updateStatus(
    @Param('id') id: string,
    @Body() body: { status: DocumentStatus; rejectionReason?: string },
    @Request() req: AuthenticatedRequest,
  ) {
    return this.documentsService.updateStatus(
      id,
      body.status,
      req.user.sub,
      body.rejectionReason,
    );
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete document' })
  @ApiResponse({
    status: 204,
    description: 'Document deleted',
  })
  @ApiResponse({ status: 404, description: 'Document not found' })
  async remove(@Param('id') id: string, @Request() req: AuthenticatedRequest) {
    // Get document before deletion to access file path
    const document = await this.documentsService.findOne(id);

    // Verify user owns the document or is admin
    if (document.userId.toString() !== req.user.sub && req.user.role !== UserRole.ADMIN) {
      throw new BadRequestException('You do not have permission to delete this document');
    }

    // Delete file from disk if it exists
    if (document.filePath) {
      const absolutePath = path.join(process.cwd(), document.filePath);
      if (fs.existsSync(absolutePath)) {
        try {
          fs.unlinkSync(absolutePath);
        } catch (error) {
          // Log error but don't fail the request if file deletion fails
          console.error(`Failed to delete file ${absolutePath}:`, error);
        }
      }
    }

    // Delete document from database
    await this.documentsService.delete(id);
  }
}