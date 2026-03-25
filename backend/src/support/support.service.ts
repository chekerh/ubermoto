import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import {
  SupportTicket,
  SupportTicketDocument,
  TicketStatus,
  TicketPriority,
} from './schemas/support-ticket.schema';
import { Feedback, FeedbackDocument, FeedbackType } from './schemas/feedback.schema';
import { Faq, FaqDocument } from './schemas/faq.schema';

@Injectable()
export class SupportService {
  constructor(
    @InjectModel(SupportTicket.name)
    private ticketModel: Model<SupportTicketDocument>,
    @InjectModel(Feedback.name)
    private feedbackModel: Model<FeedbackDocument>,
    @InjectModel(Faq.name)
    private faqModel: Model<FaqDocument>,
  ) {}

  // ── Support Tickets ──────────────────────────────────────────────────────────

  async createTicket(
    userId: string,
    subject: string,
    description: string,
    priority: TicketPriority = TicketPriority.MEDIUM,
    referenceId?: string,
    referenceType?: string,
  ) {
    const ticket = new this.ticketModel({
      userId: new Types.ObjectId(userId),
      subject,
      description,
      priority,
      referenceId: referenceId ? new Types.ObjectId(referenceId) : undefined,
      referenceType,
    });
    return ticket.save();
  }

  async findMyTickets(userId: string) {
    return this.ticketModel
      .find({ userId: new Types.ObjectId(userId) })
      .sort({ updatedAt: -1 })
      .exec();
  }

  async findTicketById(ticketId: string, userId: string) {
    const ticket = await this.ticketModel
      .findOne({
        _id: new Types.ObjectId(ticketId),
        userId: new Types.ObjectId(userId),
      })
      .exec();

    if (!ticket) {
      throw new NotFoundException('Ticket not found');
    }
    return ticket;
  }

  async updateTicketStatus(
    ticketId: string,
    status: TicketStatus,
    adminId: string,
    resolution?: string,
  ) {
    const ticket = await this.ticketModel
      .findByIdAndUpdate(
        ticketId,
        {
          status,
          assignedTo: new Types.ObjectId(adminId),
          ...(resolution ? { resolution } : {}),
        },
        { new: true },
      )
      .exec();

    if (!ticket) throw new NotFoundException('Ticket not found');
    return ticket;
  }

  async findAllTickets(status?: TicketStatus, priority?: TicketPriority) {
    const filter: Record<string, unknown> = {};
    if (status) filter.status = status;
    if (priority) filter.priority = priority;
    return this.ticketModel
      .find(filter)
      .sort({ updatedAt: -1 })
      .populate('userId', 'name email')
      .exec();
  }

  // ── Feedback ────────────────────────────────────────────────────────────────

  async submitFeedback(
    userId: string,
    message: string,
    type: FeedbackType = FeedbackType.APP,
    rating?: number,
    referenceId?: string,
    referenceType?: string,
  ) {
    const feedback = new this.feedbackModel({
      userId: new Types.ObjectId(userId),
      message,
      type,
      rating,
      referenceId: referenceId ? new Types.ObjectId(referenceId) : undefined,
      referenceType,
    });
    return feedback.save();
  }

  // ── FAQ ─────────────────────────────────────────────────────────────────────

  async getFaqs(category?: string) {
    const filter: Record<string, unknown> = { isActive: true };
    if (category) filter.category = category;
    return this.faqModel.find(filter).sort({ sortOrder: 1, createdAt: 1 }).exec();
  }

  async createFaq(question: string, answer: string, category = 'general', sortOrder = 0) {
    const faq = new this.faqModel({ question, answer, category, sortOrder });
    return faq.save();
  }
}
