import { IsEnum, IsOptional, IsString } from 'class-validator';
import { TicketStatus } from '../schemas/support-ticket.schema';

export class UpdateTicketStatusDto {
  @IsEnum(TicketStatus)
  status!: TicketStatus;

  @IsOptional()
  @IsString()
  resolution?: string;
}
