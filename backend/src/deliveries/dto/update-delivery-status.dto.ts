import { IsEnum } from 'class-validator';
import { DeliveryStatus } from '../schemas/delivery.schema';

export class UpdateDeliveryStatusDto {
  @IsEnum(DeliveryStatus)
  status!: DeliveryStatus;
}
