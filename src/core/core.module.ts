import { Module } from '@nestjs/common';
import { CostCalculatorService } from './utils/cost-calculator.service';

@Module({
  providers: [CostCalculatorService],
  exports: [CostCalculatorService],
})
export class CoreModule {}
