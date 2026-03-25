import { initializeSentry } from './sentry.config';
import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';
import { AllExceptionsFilter } from './common/filters/all-exceptions.filter';
import { validateProductionEnvironment } from './config/bootstrap-validation';
import helmet from 'helmet';
import compression from 'compression';
import bodyParser from 'body-parser';
import { Response, NextFunction } from 'express';

async function bootstrap(): Promise<void> {
  validateProductionEnvironment();

  // Initialize Sentry
  initializeSentry();
  const app = await NestFactory.create(AppModule);

  // Stripe webhook signature verification needs access to raw request body.
  app.use(
    '/billing/webhooks/stripe',
    bodyParser.raw({ type: 'application/json' }),
    (req: any, _res: Response, next: NextFunction) => {
      req.rawBody = req.body;
      next();
    },
  );

  app.use(compression());

  app.use(
    helmet({
      crossOriginResourcePolicy: false,
    }),
  );

  const frontendOriginsFromEnv = (process.env.FRONTEND_ORIGINS ?? '')
    .split(',')
    .map((origin) => origin.trim())
    .filter((origin) => origin.length > 0);

  const devAllowedOrigins = [
    'http://localhost:8080',
    'http://127.0.0.1:8080',
    'http://localhost:3000',
    'http://127.0.0.1:3000',
  ];

  const isProduction = process.env.NODE_ENV === 'production';
  const allowedOrigins = new Set([
    ...(isProduction ? [] : devAllowedOrigins),
    ...frontendOriginsFromEnv,
  ]);

  // Enable CORS for Flutter frontend
  app.enableCors({
    origin: (origin, callback) => {
      // Allow server-to-server and native app requests with no origin header
      if (!origin) {
        callback(null, true);
        return;
      }

      if (allowedOrigins.has(origin)) {
        callback(null, true);
        return;
      }

      callback(new Error('CORS origin not allowed'));
    },
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
    credentials: true,
  });

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );

  app.useGlobalFilters(new AllExceptionsFilter());

  // Swagger Configuration
  const config = new DocumentBuilder()
    .setTitle('Nassib API')
    .setDescription('API documentation for Nassib - Motorcycle delivery platform')
    .setVersion('1.0')
    .addBearerAuth(
      {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
        name: 'JWT',
        description: 'Enter JWT token',
        in: 'header',
      },
      'JWT-auth',
    )
    .addTag('auth', 'Authentication endpoints')
    .addTag('users', 'User management')
    .addTag('motorcycles', 'Motorcycle management')
    .addTag('deliveries', 'Delivery management')
    .addTag('health', 'Health check')
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api', app, document, {
    swaggerOptions: {
      persistAuthorization: true,
    },
  });

  // Try to use PORT from environment, otherwise try available ports
  let port = process.env.PORT ? parseInt(process.env.PORT, 10) : null;

  if (!port) {
    // Try ports 3001-3004 in order
    const availablePorts = [3001, 3002, 3003, 3004];
    port = availablePorts[0]; // Default to 3001, can be changed via PORT env var
  }

  await app.listen(port);
  console.log(`🚀 Application is running on: http://localhost:${port}`);
  console.log(`📚 Swagger documentation: http://localhost:${port}/api`);
  console.log(`💡 Available ports for other projects: 3002, 3003, 3004`);
}

bootstrap();
