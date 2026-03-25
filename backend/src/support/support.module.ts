import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { SupportController } from './support.controller';
import { SupportService } from './support.service';
import { SupportTicket, SupportTicketSchema } from './schemas/support-ticket.schema';
import { Feedback, FeedbackSchema } from './schemas/feedback.schema';
import { Faq, FaqSchema } from './schemas/faq.schema';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: SupportTicket.name, schema: SupportTicketSchema },
      { name: Feedback.name, schema: FeedbackSchema },
      { name: Faq.name, schema: FaqSchema },
    ]),
  ],
  controllers: [SupportController],
  providers: [SupportService],
  exports: [SupportService],
})
export class SupportModule {}
