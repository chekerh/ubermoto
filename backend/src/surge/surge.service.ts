import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { SurgeRule, SurgeRuleDocument } from './schemas/surge-rule.schema';
import { CreateSurgeRuleDto } from './dto/create-surge-rule.dto';
import { UpdateSurgeRuleDto } from './dto/update-surge-rule.dto';
import { AdminAuditLogService, AdminAuditAction } from '../admin/admin-audit-log.service';
import { UserRole } from '../users/schemas/user.schema';

interface Point {
  lat: number;
  lng: number;
}

@Injectable()
export class SurgeService {
  constructor(
    @InjectModel(SurgeRule.name) private surgeModel: Model<SurgeRuleDocument>,
    private readonly auditLog: AdminAuditLogService,
  ) {}

  async create(dto: CreateSurgeRuleDto, adminId: string): Promise<SurgeRuleDocument> {
    const rule = new this.surgeModel({
      ...dto,
      createdBy: adminId,
      updatedBy: adminId,
    });
    const saved = await rule.save();
    await this.auditLog.create({
      adminId,
      adminRole: UserRole.ADMIN,
      action: AdminAuditAction.SURGE_CREATE,
      targetId: saved._id.toString(),
    });
    return saved;
  }

  async findAll(): Promise<SurgeRuleDocument[]> {
    return this.surgeModel.find().sort({ createdAt: -1 }).exec();
  }

  async update(id: string, dto: UpdateSurgeRuleDto, adminId: string): Promise<SurgeRuleDocument> {
    const updated = await this.surgeModel
      .findByIdAndUpdate(id, { ...dto, updatedBy: adminId }, { new: true })
      .exec();
    if (!updated) throw new NotFoundException('Surge rule not found');
    await this.auditLog.create({
      adminId,
      adminRole: UserRole.ADMIN,
      action: AdminAuditAction.SURGE_UPDATE,
      targetId: id,
    });
    return updated;
  }

  async toggle(id: string, active: boolean, adminId: string): Promise<SurgeRuleDocument> {
    const updated = await this.surgeModel
      .findByIdAndUpdate(id, { active, updatedBy: adminId }, { new: true })
      .exec();
    if (!updated) throw new NotFoundException('Surge rule not found');
    await this.auditLog.create({
      adminId,
      adminRole: UserRole.ADMIN,
      action: AdminAuditAction.SURGE_TOGGLE,
      targetId: id,
    });
    return updated;
  }

  async remove(id: string, adminId: string): Promise<void> {
    const res = await this.surgeModel.findByIdAndDelete(id).exec();
    if (!res) throw new NotFoundException('Surge rule not found');
    await this.auditLog.create({
      adminId,
      adminRole: UserRole.ADMIN,
      action: AdminAuditAction.SURGE_DELETE,
      targetId: id,
    });
  }

  async preview(region: string, timestamp?: Date, point?: Point): Promise<number> {
    const now = timestamp || new Date();
    const rules = await this.surgeModel
      .find({ region, active: true })
      .sort({ multiplier: -1 })
      .exec();
    return this.pickMultiplier(rules, now, point);
  }

  async getMultiplierFor(region: string, timestamp: Date, point?: Point): Promise<number> {
    const rules = await this.surgeModel
      .find({ region, active: true })
      .sort({ multiplier: -1 })
      .exec();
    return this.pickMultiplier(rules, timestamp, point);
  }

  private pickMultiplier(rules: SurgeRule[], timestamp: Date, point?: Point): number {
    const weekday = timestamp.getDay();
    const hh = timestamp.getHours().toString().padStart(2, '0');
    const mm = timestamp.getMinutes().toString().padStart(2, '0');
    const nowStr = `${hh}:${mm}`;

    for (const rule of rules) {
      const withinWeekday = !rule.weekdays || rule.weekdays.includes(weekday);
      const withinTime = this.isBetween(nowStr, rule.startTime, rule.endTime);
      const withinPoly = !rule.polygon || !point || this.pointInPolygon(point, rule.polygon);
      if (withinWeekday && withinTime && withinPoly) {
        return rule.multiplier;
      }
    }
    return 1;
  }

  private isBetween(now: string, start: string, end: string): boolean {
    if (start === end) return true;
    if (start < end) return now >= start && now <= end;
    // overnight window
    return now >= start || now <= end;
  }

  private pointInPolygon(point: Point, polygon: number[][]): boolean {
    // ray-casting; polygon as [[lng, lat], ...]
    let inside = false;
    for (let i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      const xi = polygon[i][1];
      const yi = polygon[i][0];
      const xj = polygon[j][1];
      const yj = polygon[j][0];
      const intersect =
        yi > point.lng !== yj > point.lng &&
        point.lat < ((xj - xi) * (point.lng - yi)) / (yj - yi) + xi;
      if (intersect) inside = !inside;
    }
    return inside;
  }
}
