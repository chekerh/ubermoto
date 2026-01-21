import { Injectable, CanActivate, ExecutionContext, ForbiddenException } from '@nestjs/common';
import { UserRole } from '../../users/schemas/user.schema';

@Injectable()
export class VerifiedDriverGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const { user } = context.switchToHttp().getRequest();

    // Check if user is a driver
    if (user.role !== UserRole.DRIVER) {
      throw new ForbiddenException('Only drivers can access this resource');
    }

    // Check if driver is verified
    if (!user.isVerified) {
      throw new ForbiddenException('Driver account is not verified. Please complete document verification.');
    }

    return true;
  }
}