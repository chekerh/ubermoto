import { Controller, Get, ServiceUnavailableException } from '@nestjs/common';
import { InjectConnection } from '@nestjs/mongoose';
import { Connection } from 'mongoose';
import { SkipThrottle } from '@nestjs/throttler';

/**
 * Uses Mongoose connection state + admin ping so failures return **503** with a JSON body
 * instead of an unhandled 500 from Terminus when Mongo is down.
 */
@Controller('health')
export class HealthController {
  constructor(@InjectConnection() private readonly connection: Connection) {}

  @Get()
  @SkipThrottle()
  async check(): Promise<{ status: string; mongodb: string }> {
    if (this.connection.readyState !== 1) {
      throw new ServiceUnavailableException({
        status: 'error',
        mongodb: 'unavailable',
        message: 'Database connection is not ready',
      });
    }

    try {
      const db = this.connection.db;
      if (!db) {
        throw new ServiceUnavailableException({
          status: 'error',
          mongodb: 'unavailable',
          message: 'Database handle is not available',
        });
      }
      await db.admin().command({ ping: 1 });
    } catch (e) {
      if (e instanceof ServiceUnavailableException) {
        throw e;
      }
      throw new ServiceUnavailableException({
        status: 'error',
        mongodb: 'unavailable',
        message: 'Database ping failed',
      });
    }

    return { status: 'ok', mongodb: 'up' };
  }
}
