import { Injectable } from '@nestjs/common';

type PromoType = 'percentage' | 'fixed';

interface PromoCodeRule {
  code: string;
  type: PromoType;
  value: number;
  minOrderTotal: number;
  active: boolean;
}

@Injectable()
export class PromoCodesService {
  private readonly promoCodes: PromoCodeRule[] = [
    { code: 'WELCOME10', type: 'percentage', value: 10, minOrderTotal: 20, active: true },
    { code: 'RAMADAN15', type: 'percentage', value: 15, minOrderTotal: 30, active: true },
    { code: 'SAVE5', type: 'fixed', value: 5, minOrderTotal: 15, active: true },
  ];

  validate(code: string, subtotal = 0) {
    const promo = this.promoCodes.find((p) => p.code === code.toUpperCase() && p.active);
    if (!promo) {
      return {
        valid: false,
        message: 'Promo code is invalid or inactive',
      };
    }

    if (subtotal < promo.minOrderTotal) {
      return {
        valid: false,
        message: `Minimum order total is ${promo.minOrderTotal.toFixed(2)} TND`,
        code: promo.code,
        minOrderTotal: promo.minOrderTotal,
      };
    }

    return {
      valid: true,
      code: promo.code,
      type: promo.type,
      value: promo.value,
      minOrderTotal: promo.minOrderTotal,
      message: 'Promo code is valid',
    };
  }

  apply(code: string, orderTotal: number) {
    const validation = this.validate(code, orderTotal);
    if (!validation.valid) {
      return {
        success: false,
        ...validation,
      };
    }

    const promo = this.promoCodes.find((p) => p.code === code.toUpperCase())!;
    const rawDiscount =
      promo.type === 'percentage' ? (orderTotal * promo.value) / 100 : promo.value;
    const discountAmount = Math.min(rawDiscount, orderTotal);
    const finalTotal = orderTotal - discountAmount;

    return {
      success: true,
      code: promo.code,
      discountType: promo.type,
      discountValue: promo.value,
      discountAmount: parseFloat(discountAmount.toFixed(2)),
      finalTotal: parseFloat(finalTotal.toFixed(2)),
      message: 'Promo code applied successfully',
    };
  }
}
