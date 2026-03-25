import { Controller, Get } from '@nestjs/common';

// eslint-disable-next-line @typescript-eslint/no-var-requires
const pkg = require('../../package.json') as { version: string; name: string };

@Controller('system')
export class SystemController {
  @Get('version')
  getVersion() {
    return {
      name: pkg.name,
      version: pkg.version,
      environment: process.env.NODE_ENV || 'development',
      timestamp: new Date().toISOString(),
    };
  }
}
