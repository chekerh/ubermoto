import { Test, TestingModule } from '@nestjs/testing';
import { getModelToken } from '@nestjs/mongoose';
import { NotFoundException } from '@nestjs/common';
import * as fs from 'fs';
import { DocumentsService } from './documents.service';
import { DocumentEntity } from './schemas/document.schema';
import { UsersService } from '../users/users.service';

jest.mock('fs', () => {
  const actual = jest.requireActual<typeof import('fs')>('fs');
  return {
    ...actual,
    existsSync: jest.fn().mockReturnValue(false),
    unlinkSync: jest.fn(),
  };
});

describe('DocumentsService', () => {
  let service: DocumentsService;
  let mockModel: {
    findById: jest.Mock;
    findByIdAndDelete: jest.Mock;
  };

  const mockUsersService = {
    findById: jest.fn(),
    updateVerificationStatus: jest.fn(),
  };

  beforeEach(async () => {
    mockModel = {
      findById: jest.fn(),
      findByIdAndDelete: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        DocumentsService,
        { provide: getModelToken(DocumentEntity.name), useValue: mockModel },
        { provide: UsersService, useValue: mockUsersService },
      ],
    }).compile();

    service = module.get<DocumentsService>(DocumentsService);
    (fs.existsSync as jest.Mock).mockReturnValue(false);
    (fs.unlinkSync as jest.Mock).mockClear();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('delete', () => {
    it('throws when document missing', async () => {
      mockModel.findById.mockReturnValue({ exec: jest.fn().mockResolvedValue(null) });

      await expect(service.delete('507f1f77bcf86cd799439011')).rejects.toThrow(NotFoundException);
      expect(mockModel.findByIdAndDelete).not.toHaveBeenCalled();
    });

    it('unlinks file under uploads when present', async () => {
      const doc = { filePath: 'uploads/documents/driver-license/x.pdf' };
      mockModel.findById.mockReturnValue({ exec: jest.fn().mockResolvedValue(doc) });
      mockModel.findByIdAndDelete.mockReturnValue({ exec: jest.fn().mockResolvedValue(doc) });
      (fs.existsSync as jest.Mock).mockReturnValue(true);

      await service.delete('507f1f77bcf86cd799439011');

      expect(fs.unlinkSync).toHaveBeenCalled();
      expect(mockModel.findByIdAndDelete).toHaveBeenCalledWith('507f1f77bcf86cd799439011');
    });

    it('does not unlink when stored path contains ..', async () => {
      const doc = { filePath: 'uploads/../../../etc/passwd' };
      mockModel.findById.mockReturnValue({ exec: jest.fn().mockResolvedValue(doc) });
      mockModel.findByIdAndDelete.mockReturnValue({ exec: jest.fn().mockResolvedValue({}) });

      await service.delete('507f1f77bcf86cd799439011');

      expect(fs.unlinkSync).not.toHaveBeenCalled();
    });
  });
});
