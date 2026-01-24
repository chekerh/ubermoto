import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import {
  DocumentEntity,
  DocumentDocument,
  DocumentType,
  DocumentStatus,
} from './schemas/document.schema';
import { UsersService } from '../users/users.service';
import { UserRole } from '../users/schemas/user.schema';

export interface CreateDocumentDto {
  userId: string;
  documentType: DocumentType;
  fileName: string;
  filePath: string;
  mimeType: string;
  fileSize: number;
}

@Injectable()
export class DocumentsService {
  constructor(
    @InjectModel(DocumentEntity.name) private documentModel: Model<DocumentDocument>,
    private readonly usersService: UsersService,
  ) {}

  async create(createDocumentDto: CreateDocumentDto): Promise<DocumentDocument> {
    // Verify user exists and is a driver
    const user = await this.usersService.findById(createDocumentDto.userId);
    if (!user) {
      throw new NotFoundException('User not found');
    }

    if (user.role !== UserRole.DRIVER) {
      throw new BadRequestException('Only drivers can upload documents');
    }

    // Check if document type already exists for this user
    const existingDocument = await this.documentModel
      .findOne({
        userId: createDocumentDto.userId,
        documentType: createDocumentDto.documentType,
      })
      .exec();

    if (existingDocument) {
      throw new BadRequestException(
        `Document of type ${createDocumentDto.documentType} already exists for this user`,
      );
    }

    const document = new this.documentModel(createDocumentDto);
    return document.save();
  }

  async findAllByUserId(userId: string): Promise<DocumentDocument[]> {
    return this.documentModel.find({ userId }).populate('userId').populate('reviewedBy').exec();
  }

  async findOne(id: string): Promise<DocumentDocument> {
    const document = await this.documentModel
      .findById(id)
      .populate('userId')
      .populate('reviewedBy')
      .exec();
    if (!document) {
      throw new NotFoundException(`Document with ID ${id} not found`);
    }
    return document;
  }

  async updateStatus(
    id: string,
    status: DocumentStatus,
    reviewedBy: string,
    rejectionReason?: string,
  ): Promise<DocumentDocument> {
    const updateData: any = {
      status,
      reviewedBy,
      reviewedAt: new Date(),
    };

    if (rejectionReason) {
      updateData.rejectionReason = rejectionReason;
    }

    const document = await this.documentModel
      .findByIdAndUpdate(id, updateData, { new: true })
      .populate('userId')
      .populate('reviewedBy')
      .exec();

    if (!document) {
      throw new NotFoundException(`Document with ID ${id} not found`);
    }

    // If all documents are approved, mark driver as verified
    if (status === DocumentStatus.APPROVED) {
      await this.checkAndUpdateDriverVerification(document.userId.toString());
    }

    return document;
  }

  async findPendingDocuments(): Promise<DocumentDocument[]> {
    return this.documentModel.find({ status: DocumentStatus.PENDING }).populate('userId').exec();
  }

  async getDocumentStats(userId: string): Promise<{
    total: number;
    approved: number;
    pending: number;
    rejected: number;
    isComplete: boolean;
  }> {
    const documents = await this.documentModel.find({ userId }).exec();

    const stats = {
      total: documents.length,
      approved: documents.filter((doc) => doc.status === DocumentStatus.APPROVED).length,
      pending: documents.filter((doc) => doc.status === DocumentStatus.PENDING).length,
      rejected: documents.filter((doc) => doc.status === DocumentStatus.REJECTED).length,
      isComplete: false,
    };

    // Driver needs all 4 document types approved
    stats.isComplete = stats.approved >= 4;

    return stats;
  }

  private async checkAndUpdateDriverVerification(userId: string): Promise<void> {
    const stats = await this.getDocumentStats(userId);
    if (stats.isComplete) {
      await this.usersService.updateVerificationStatus(userId, true);
    }
  }

  async delete(id: string): Promise<void> {
    const document = await this.documentModel.findById(id).exec();
    if (!document) {
      throw new NotFoundException(`Document with ID ${id} not found`);
    }

    // TODO: Delete file from storage

    await this.documentModel.findByIdAndDelete(id).exec();
  }
}
