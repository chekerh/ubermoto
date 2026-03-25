import { Test, TestingModule } from '@nestjs/testing';
import { getModelToken } from '@nestjs/mongoose';
import { NotFoundException } from '@nestjs/common';
import { SupportService } from './support.service';
import { SupportTicket, TicketStatus, TicketPriority } from './schemas/support-ticket.schema';
import { Feedback, FeedbackType } from './schemas/feedback.schema';
import { Faq } from './schemas/faq.schema';

describe('SupportService', () => {
  let service: SupportService;
  let mockTicketModel: any;
  let mockFeedbackModel: any;
  let mockFaqModel: any;

  const userId = '507f1f77bcf86cd799439010';
  const ticketId = '507f1f77bcf86cd799439011';
  const adminId = '507f1f77bcf86cd799439013';

  const mockSavedTicket = {
    _id: ticketId,
    userId,
    subject: 'Missing item in delivery',
    description: 'One item was missing from my order.',
    status: TicketStatus.OPEN,
    priority: TicketPriority.MEDIUM,
  };

  beforeEach(async () => {
    // Constructor mock — supports `new this.ticketModel(data).save()`
    mockTicketModel = jest.fn().mockImplementation(() => ({
      save: jest.fn().mockResolvedValue(mockSavedTicket),
    }));
    mockTicketModel.find = jest.fn();
    mockTicketModel.findOne = jest.fn();
    mockTicketModel.findByIdAndUpdate = jest.fn();

    mockFeedbackModel = jest.fn().mockImplementation(() => ({
      save: jest.fn().mockResolvedValue({ _id: 'feedback-id-1', message: 'Great service!' }),
    }));

    mockFaqModel = jest.fn().mockImplementation(() => ({
      save: jest.fn().mockResolvedValue({ _id: 'faq-id-1', question: 'How do I track my order?' }),
    }));
    mockFaqModel.find = jest.fn();

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        SupportService,
        { provide: getModelToken(SupportTicket.name), useValue: mockTicketModel },
        { provide: getModelToken(Feedback.name), useValue: mockFeedbackModel },
        { provide: getModelToken(Faq.name), useValue: mockFaqModel },
      ],
    }).compile();

    service = module.get<SupportService>(SupportService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  // ── createTicket ────────────────────────────────────────────────────────────

  describe('createTicket', () => {
    it('should create and return a new support ticket', async () => {
      const result = await service.createTicket(
        userId,
        'Missing item in delivery',
        'One item was missing from my order.',
      );

      expect(mockTicketModel).toHaveBeenCalledTimes(1);
      expect(result).toEqual(mockSavedTicket);
    });

    it('should accept an optional priority', async () => {
      await service.createTicket(
        userId,
        'Urgent issue',
        'Driver never arrived.',
        TicketPriority.URGENT,
      );

      const constructorArg = mockTicketModel.mock.calls[0][0];
      expect(constructorArg.priority).toBe(TicketPriority.URGENT);
    });
  });

  // ── findMyTickets ────────────────────────────────────────────────────────────

  describe('findMyTickets', () => {
    it('should return tickets sorted by updatedAt desc', async () => {
      mockTicketModel.find.mockReturnValue({
        sort: jest.fn().mockReturnValue({
          exec: jest.fn().mockResolvedValue([mockSavedTicket]),
        }),
      });

      const result = await service.findMyTickets(userId);
      expect(result).toHaveLength(1);
      expect(result[0].subject).toBe('Missing item in delivery');
    });

    it('should return an empty array when no tickets exist', async () => {
      mockTicketModel.find.mockReturnValue({
        sort: jest.fn().mockReturnValue({
          exec: jest.fn().mockResolvedValue([]),
        }),
      });

      const result = await service.findMyTickets(userId);
      expect(result).toHaveLength(0);
    });
  });

  // ── findTicketById ───────────────────────────────────────────────────────────

  describe('findTicketById', () => {
    it('should throw NotFoundException when ticket is not found', async () => {
      mockTicketModel.findOne.mockReturnValue({ exec: jest.fn().mockResolvedValue(null) });

      await expect(service.findTicketById(ticketId, userId)).rejects.toThrow(NotFoundException);
    });

    it('should return the ticket when found', async () => {
      mockTicketModel.findOne.mockReturnValue({
        exec: jest.fn().mockResolvedValue(mockSavedTicket),
      });

      const result = await service.findTicketById(ticketId, userId);
      expect(result.subject).toBe('Missing item in delivery');
      expect(result.status).toBe(TicketStatus.OPEN);
    });
  });

  // ── updateTicketStatus ───────────────────────────────────────────────────────

  describe('updateTicketStatus', () => {
    it('should throw NotFoundException when ticket is not found', async () => {
      mockTicketModel.findByIdAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });

      await expect(
        service.updateTicketStatus(ticketId, TicketStatus.RESOLVED, adminId),
      ).rejects.toThrow(NotFoundException);
    });

    it('should update the ticket status and return the updated document', async () => {
      const updated = { ...mockSavedTicket, status: TicketStatus.RESOLVED, resolution: 'Refunded' };
      mockTicketModel.findByIdAndUpdate.mockReturnValue({
        exec: jest.fn().mockResolvedValue(updated),
      });

      const result = await service.updateTicketStatus(
        ticketId,
        TicketStatus.RESOLVED,
        adminId,
        'Refunded',
      );

      expect(result.status).toBe(TicketStatus.RESOLVED);
      expect(result.resolution).toBe('Refunded');
    });
  });

  // ── findAllTickets ───────────────────────────────────────────────────────────

  describe('findAllTickets', () => {
    it('should return all tickets when no filters are provided', async () => {
      mockTicketModel.find.mockReturnValue({
        sort: jest.fn().mockReturnValue({
          populate: jest.fn().mockReturnValue({
            exec: jest.fn().mockResolvedValue([mockSavedTicket]),
          }),
        }),
      });

      const result = await service.findAllTickets();
      expect(mockTicketModel.find).toHaveBeenCalledWith({});
      expect(result).toHaveLength(1);
    });

    it('should apply status and priority filters', async () => {
      mockTicketModel.find.mockReturnValue({
        sort: jest.fn().mockReturnValue({
          populate: jest.fn().mockReturnValue({
            exec: jest.fn().mockResolvedValue([]),
          }),
        }),
      });

      await service.findAllTickets(TicketStatus.IN_PROGRESS, TicketPriority.HIGH);

      expect(mockTicketModel.find).toHaveBeenCalledWith({
        status: TicketStatus.IN_PROGRESS,
        priority: TicketPriority.HIGH,
      });
    });
  });

  // ── submitFeedback ───────────────────────────────────────────────────────────

  describe('submitFeedback', () => {
    it('should create and save a feedback entry', async () => {
      const result = await service.submitFeedback(userId, 'Great service!', FeedbackType.APP, 5);

      expect(mockFeedbackModel).toHaveBeenCalledTimes(1);
      expect(result).toHaveProperty('_id', 'feedback-id-1');
    });

    it('should default type to APP when not provided', async () => {
      await service.submitFeedback(userId, 'Good delivery.');

      const constructorArg = mockFeedbackModel.mock.calls[0][0];
      expect(constructorArg.type).toBe(FeedbackType.APP);
    });
  });

  // ── getFaqs ──────────────────────────────────────────────────────────────────

  describe('getFaqs', () => {
    it('should return active FAQs sorted by sortOrder', async () => {
      mockFaqModel.find.mockReturnValue({
        sort: jest.fn().mockReturnValue({
          exec: jest
            .fn()
            .mockResolvedValue([
              { question: 'How do I track my order?', answer: 'Open the app and tap Track.' },
            ]),
        }),
      });

      const result = await service.getFaqs();
      expect(mockFaqModel.find).toHaveBeenCalledWith({ isActive: true });
      expect(result).toHaveLength(1);
    });

    it('should filter by category when provided', async () => {
      mockFaqModel.find.mockReturnValue({
        sort: jest.fn().mockReturnValue({
          exec: jest.fn().mockResolvedValue([]),
        }),
      });

      await service.getFaqs('delivery');
      expect(mockFaqModel.find).toHaveBeenCalledWith({ isActive: true, category: 'delivery' });
    });
  });

  // ── createFaq ────────────────────────────────────────────────────────────────

  describe('createFaq', () => {
    it('should create and return a new FAQ entry', async () => {
      const result = await service.createFaq(
        'How do I track my order?',
        'Open the app and tap Track.',
        'delivery',
        1,
      );

      expect(mockFaqModel).toHaveBeenCalledTimes(1);
      expect(result).toHaveProperty('question', 'How do I track my order?');
    });

    it('should default category to general and sortOrder to 0', async () => {
      await service.createFaq('What payment methods are accepted?', 'Cash and card.');

      const constructorArg = mockFaqModel.mock.calls[0][0];
      expect(constructorArg.category).toBe('general');
      expect(constructorArg.sortOrder).toBe(0);
    });
  });
});
