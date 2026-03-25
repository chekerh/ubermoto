import { CanActivate, ExecutionContext, ForbiddenException, Injectable } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { BillingService } from '../billing.service';
import { REQUIRE_FEATURE_KEY } from './require-feature.decorator';

@Injectable()
export class FeatureGuard implements CanActivate {
  constructor(
    private readonly reflector: Reflector,
    private readonly billingService: BillingService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const featureKey = this.reflector.getAllAndOverride<string>(REQUIRE_FEATURE_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (!featureKey) {
      return true;
    }

    const req = context.switchToHttp().getRequest();
    const user = req.user as { sub: string; role: string } | undefined;
    if (!user?.sub || !user.role) {
      throw new ForbiddenException('Missing user context');
    }

    if (user.role === 'ADMIN') {
      return true;
    }

    const merchantId =
      (req.query?.merchantId as string | undefined) || (req.body?.merchantId as string | undefined);

    const ent = await this.billingService.getEntitlementsForUser(user.sub, user.role, merchantId);
    const has = !!ent?.merchant?.features?.[featureKey];
    if (!has) {
      throw new ForbiddenException(`Missing entitlement: ${featureKey}`);
    }
    return true;
  }
}
