# UberMoto Backend

NestJS backend application with clean architecture, JWT authentication, and MongoDB integration.

## Features

- TypeScript strict mode
- ESLint + Prettier configured
- ConfigModule for environment variables
- MongoDB connection using @nestjs/mongoose
- JWT Authentication with passport-jwt
- Password hashing with bcryptjs
- Global exception filter
- Health module with /health endpoint
- Clean folder structure following clean architecture principles
- Unit tests for all modules

## Installation

```bash
npm install
```

## Environment Variables

Create a `.env` file in the root directory:

```env
NODE_ENV=development
PORT=3000
MONGODB_URI=mongodb://localhost:27017/ubermoto
JWT_SECRET=your-super-secret-jwt-key-change-in-production
JWT_EXPIRES_IN=1h
```

## Running the app

```bash
# development
npm run start:dev

# production mode
npm run start:prod
```

## API Endpoints

### Authentication

- `POST /auth/register` - Register a new user
  ```json
  {
    "email": "user@example.com",
    "password": "password123",
    "name": "John Doe"
  }
  ```

- `POST /auth/login` - Login and get JWT token
  ```json
  {
    "email": "user@example.com",
    "password": "password123"
  }
  ```
  Returns:
  ```json
  {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
  ```

### Health Check

- `GET /health` - Health check endpoint

### Protected Routes

To protect a route, use the `@UseGuards(JwtAuthGuard)` decorator:

```typescript
import { Controller, Get, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from './auth/guards/jwt-auth.guard';

@Controller('protected')
@UseGuards(JwtAuthGuard)
export class ProtectedController {
  @Get()
  getProtectedData() {
    return { message: 'This is protected data' };
  }
}
```

Then include the JWT token in the Authorization header:
```
Authorization: Bearer <your-jwt-token>
```

## Test

```bash
# unit tests
npm run test

# test coverage
npm run test:cov
```

## Linting

```bash
# lint
npm run lint

# format
npm run format
```

## Project Structure

```
src/
├── auth/              # Authentication module
│   ├── dto/          # Data Transfer Objects
│   ├── guards/       # JWT Auth Guard
│   ├── strategies/   # JWT Strategy
│   ├── auth.controller.ts
│   ├── auth.service.ts
│   └── auth.module.ts
├── users/            # Users module
│   ├── schemas/      # MongoDB schemas
│   ├── users.service.ts
│   └── users.module.ts
├── common/           # Shared utilities, filters, etc.
│   └── filters/
├── config/           # Configuration services
├── health/           # Health check module
├── app.module.ts     # Root module
└── main.ts           # Application entry point
```

## Code Quality

- ✅ TypeScript strict mode enabled
- ✅ Zero lint errors
- ✅ Zero TypeScript warnings
- ✅ All unit tests passing
- ✅ SonarQube-friendly code structure
