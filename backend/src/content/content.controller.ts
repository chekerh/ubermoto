import { Body, Controller, Get, Param, Put, Request, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { UserRole } from '../users/schemas/user.schema';
import { AdminAuditLogService, AdminAuditAction } from '../admin/admin-audit-log.service';
import { ContentService } from './content.service';
import { UpsertContentDto } from './dto/upsert-content.dto';
import { Public } from '../common/decorators/public.decorator';

interface AuthenticatedRequest extends Request {
  user: { sub: string; role: UserRole };
}

@ApiTags('content')
@Controller()
export class ContentController {
  constructor(
    private readonly contentService: ContentService,
    private readonly audit: AdminAuditLogService,
  ) {}

  @Public()
  @Get('content')
  @ApiOperation({ summary: 'List published dynamic content keys' })
  @ApiResponse({ status: 200, description: 'Published content key list' })
  listPublished() {
    return this.contentService.listPublished();
  }

  @Public()
  @Get('content/:key')
  @ApiOperation({ summary: 'Get published dynamic content by key' })
  @ApiResponse({ status: 200, description: 'Published content payload' })
  getPublished(@Param('key') key: string) {
    return this.contentService.getPublished(key);
  }

  @Get('admin/content')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Admin: list all dynamic content docs' })
  listAdmin() {
    return this.contentService.listAdmin();
  }

  @Get('admin/content/:key')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Admin: view content (draft/published)' })
  getAdmin(@Param('key') key: string) {
    return this.contentService.getAdminView(key);
  }

  @Put('admin/content/:key')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Admin: upsert content (optionally publish)' })
  async upsert(
    @Param('key') key: string,
    @Body() body: Omit<UpsertContentDto, 'key'>,
    @Request() req: AuthenticatedRequest,
  ) {
    const doc = await this.contentService.upsert(
      key,
      body.schemaVersion,
      body.data,
      !!body.publish,
      req.user.sub,
    );

    await this.audit.create({
      adminId: req.user.sub,
      adminRole: req.user.role,
      action: body.publish ? AdminAuditAction.CONTENT_PUBLISH : AdminAuditAction.CONTENT_UPSERT,
      targetId: key,
      reason: body.publish ? 'publish' : 'upsert',
    });

    return doc;
  }
}

