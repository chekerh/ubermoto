import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

export interface DeliveryCostParams {
  distance: number; // Distance in kilometers
  fuelConsumption: number; // Liters per 100 km
  fuelPrice?: number; // Price per liter (default from config or current market price)
  baseFee?: number; // Base delivery fee
  timeMultiplier?: number; // Multiplier based on delivery time (rush hour, etc.)
}

@Injectable()
export class CostCalculatorService {
  constructor(private readonly configService: ConfigService) {}

  calculateDeliveryCost(params: DeliveryCostParams): number {
    const {
      distance,
      fuelConsumption,
      fuelPrice = this.configService.get<number>('FUEL_PRICE_PER_LITER') || 2.5,
      baseFee = this.configService.get<number>('BASE_DELIVERY_FEE') || 5.0,
      timeMultiplier = 1.0,
    } = params;

    // Calculate fuel cost: (distance / 100) * fuelConsumption * fuelPrice
    const fuelCost = (distance / 100) * fuelConsumption * fuelPrice;

    // Calculate total cost: base fee + fuel cost * time multiplier
    const totalCost = baseFee + fuelCost * timeMultiplier;

    // Round to 2 decimal places
    return Math.round(totalCost * 100) / 100;
  }

  calculateFuelCost(distance: number, fuelConsumption: number, fuelPrice?: number): number {
    const price = fuelPrice || this.configService.get<number>('FUEL_PRICE_PER_LITER') || 2.5;
    const fuelCost = (distance / 100) * fuelConsumption * price;
    return Math.round(fuelCost * 100) / 100;
  }
}
