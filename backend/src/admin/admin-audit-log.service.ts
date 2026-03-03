import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import {
  AdminAuditLog,
  AdminAuditLogDocument,
  AdminAuditAction,
} from './schemas/admin-audit-log.schema';
import { UserRole } from '../users/schemas/user.schema';

export { AdminAuditAction };

export interface CreateAdminAuditLogDto {
  adminId: string;
  adminRole: UserRole;
  action: AdminAuditAction;
  targetId: string;
  targetRole?: UserRole;
  reason?: string;
  targetUserId?: string;
}

@Injectable()
export class AdminAuditLogService {
  constructor(
    @InjectModel(AdminAuditLog.name) private adminAuditLogModel: Model<AdminAuditLogDocument>,
  ) {}

  async create(createDto: CreateAdminAuditLogDto): Promise<AdminAuditLogDocument> {
    const entry = new this.adminAuditLogModel(createDto);
    return entry.save();
  }

  async findByAdminId(adminId: string, limit = 100): Promise<AdminAuditLogDocument[]> {
    return this.adminAuditLogModel
      .find({ adminId })
      .sort({ createdAt: -1 })
      .limit(limit)
      .populate('adminId', 'email name')
      .populate('targetUserId', 'email name')
      .exec();
  }

  async findByAction(action: AdminAuditAction, limit = 100): Promise<AdminAuditLogDocument[]> {
    return this.adminAuditLogModel
      .find({ action })
      .sort({ createdAt: -1 })
      .limit(limit)
      .populate('adminId', 'email name')
      .populate('targetUserId', 'email name')
      .exec();
  }

  async findAll(limit = 200): Promise<AdminAuditLogDocument[]> {
    return this.adminAuditLogModel
      .find()
      .sort({ createdAt: -1 })
      .limit(limit)
      .populate('adminId', 'email name')
      .populate('targetUserId', 'email name')
      .exec();
  }
}
