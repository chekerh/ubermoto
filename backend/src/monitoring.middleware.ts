import { Injectable, NestMiddleware } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';
import responseTime from 'response-time';

@Injectable()
export class MonitoringMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction) {
    // Add response time tracking
    responseTime()(req, res, next);

    // Log API requests
    const startTime = Date.now();
    res.on('finish', () => {
      const duration = Date.now() - startTime;
      console.log(`${req.method} ${req.originalUrl} ${res.statusCode} ${duration}ms`);

      // Alert on slow requests (>1000ms)
      if (duration > 1000) {
        console.warn(`Slow request: ${req.method} ${req.originalUrl} took ${duration}ms`);
      }
    });
  }
}
