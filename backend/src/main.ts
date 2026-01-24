import { initializeSentry } from './sentry.config'
import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';
import { AllExceptionsFilter } from './common/filters/all-exceptions.filter';

async function bootstrap(): Promise<void> {
  // Initialize Sentry
  initializeSentry();
  const app = await NestFactory.create(AppModule);

  // Enable CORS for Flutter frontend
  app.enableCors({
    origin: true, // Allow all origins in development
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
    .setTitle('UberMoto API')
    .setDescription('API documentation for UberMoto - Motorcycle delivery platform')
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
