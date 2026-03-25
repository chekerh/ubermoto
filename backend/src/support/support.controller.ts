import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Request,
  Query,
  UseGuards,
  HttpCode,
  HttpStatus,
  Patch,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiQuery } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { UserRole } from '../users/schemas/user.schema';
import { SupportService } from './support.service';
import { TicketStatus, TicketPriority } from './schemas/support-ticket.schema';
import { CreateSupportTicketDto } from './dto/create-support-ticket.dto';
import { UpdateTicketStatusDto } from './dto/update-ticket-status.dto';
import { SubmitFeedbackDto } from './dto/submit-feedback.dto';
import { CreateFaqDto } from './dto/create-faq.dto';
import { Request as ExpressRequest } from 'express';
import { Public } from '../common/decorators/public.decorator';

interface AuthenticatedRequest extends ExpressRequest {
  user: { sub: string; role: UserRole };
}

@ApiTags('support')
@Controller()
@UseGuards(JwtAuthGuard, RolesGuard)
export class SupportController {
  constructor(private readonly supportService: SupportService) {}

  // ── Support Tickets ──────────────────────────────────────────────────────────

  @Post('support/tickets')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Create a support ticket' })
  @ApiResponse({ status: 201, description: 'Ticket created' })
  createTicket(@Body() body: CreateSupportTicketDto, @Request() req: AuthenticatedRequest) {
    return this.supportService.createTicket(
      req.user.sub,
      body.subject,
      body.description,
      body.priority,
      body.referenceId,
      body.referenceType,
    );
  }

  @Get('support/tickets')
  @ApiOperation({ summary: 'Get my support tickets' })
  @ApiResponse({ status: 200, description: 'List of my support tickets' })
  getMyTickets(@Request() req: AuthenticatedRequest) {
    return this.supportService.findMyTickets(req.user.sub);
  }

  @Get('support/tickets/:id')
  @ApiOperation({ summary: 'Get a specific support ticket' })
  @ApiResponse({ status: 200, description: 'Ticket details' })
  @ApiResponse({ status: 404, description: 'Ticket not found' })
  getTicket(@Param('id') id: string, @Request() req: AuthenticatedRequest) {
    return this.supportService.findTicketById(id, req.user.sub);
  }

  @Patch('admin/support/tickets/:id/status')
  @Roles(UserRole.ADMIN)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Update support ticket status (Admin)' })
  @ApiResponse({ status: 200, description: 'Ticket status updated' })
  updateTicketStatus(
    @Param('id') id: string,
    @Body() body: UpdateTicketStatusDto,
    @Request() req: AuthenticatedRequest,
  ) {
    return this.supportService.updateTicketStatus(id, body.status, req.user.sub, body.resolution);
  }

  @Get('admin/support/tickets')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get all support tickets (Admin)' })
  @ApiQuery({ name: 'status', required: false, enum: TicketStatus })
  @ApiQuery({ name: 'priority', required: false, enum: TicketPriority })
  @ApiResponse({ status: 200, description: 'All support tickets' })
  getAllTickets(
    @Query('status') status?: TicketStatus,
    @Query('priority') priority?: TicketPriority,
  ) {
    return this.supportService.findAllTickets(status, priority);
  }

  // ── Feedback ────────────────────────────────────────────────────────────────

  @Post('feedback')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Submit platform feedback' })
  @ApiResponse({ status: 201, description: 'Feedback submitted' })
  submitFeedback(@Body() body: SubmitFeedbackDto, @Request() req: AuthenticatedRequest) {
    return this.supportService.submitFeedback(
      req.user.sub,
      body.message,
      body.type,
      body.rating,
      body.referenceId,
      body.referenceType,
    );
  }

  // ── FAQ ─────────────────────────────────────────────────────────────────────

  @Public()
  @Get('faqs')
  @ApiOperation({ summary: 'Get frequently asked questions (public)' })
  @ApiQuery({ name: 'category', required: false })
  @ApiResponse({ status: 200, description: 'FAQ list' })
  getFaqs(@Query('category') category?: string) {
    return this.supportService.getFaqs(category);
  }

  @Post('faqs')
  @Roles(UserRole.ADMIN)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Create a FAQ entry (Admin)' })
  @ApiResponse({ status: 201, description: 'FAQ created' })
  createFaq(@Body() body: CreateFaqDto) {
    return this.supportService.createFaq(body.question, body.answer, body.category, body.sortOrder);
  }
}
