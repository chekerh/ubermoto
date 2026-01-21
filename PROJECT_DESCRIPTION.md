# UberMoto - Complete Project Description

## Project Overview

**UberMoto** is a full-stack motorcycle delivery platform built as a monorepo with separate backend and frontend applications. The platform allows users to create deliveries and calculates costs based on motorcycle fuel consumption, complying with Tunisian legal framework for delivery services.

## Architecture

### Repository Structure
```
ubermoto/
├── backend/          # NestJS backend API (TypeScript)
└── frontend/         # Flutter frontend application (Dart)
```

### Current Configuration
- **Backend Port**: 3003 (configurable: 3001, 3002, 3003, 3004)
- **Frontend Port**: Flutter default (dynamic)
- **Database**: MongoDB (Mongoose ODM)
- **Authentication**: JWT with Passport.js
- **State Management**: Riverpod (Flutter)
- **API Documentation**: Swagger UI at `/api`

---

## Backend (NestJS)

### Technology Stack
- **Framework**: NestJS 10.x
- **Language**: TypeScript (strict mode enabled)
- **Database**: MongoDB with Mongoose
- **Authentication**: JWT (passport-jwt, @nestjs/jwt)
- **Password Hashing**: bcryptjs
- **Validation**: class-validator, class-transformer
- **API Docs**: Swagger/OpenAPI (@nestjs/swagger)
- **Testing**: Jest
- **Code Quality**: ESLint + Prettier

### Project Structure
```
backend/src/
├── auth/                    # Authentication module
│   ├── dto/                # LoginDto, RegisterDto
│   ├── guards/             # JwtAuthGuard
│   ├── strategies/         # JWT Strategy (passport)
│   ├── auth.controller.ts  # POST /auth/login, /auth/register
│   ├── auth.service.ts     # Business logic for auth
│   └── auth.module.ts
├── users/                  # User management
│   ├── schemas/           # User MongoDB schema
│   ├── users.service.ts    # User CRUD operations
│   └── users.module.ts
├── motorcycles/            # Motorcycle management
│   ├── dto/               # CreateMotorcycleDto, UpdateMotorcycleDto
│   ├── schemas/           # Motorcycle schema (model, brand, fuelConsumption, etc.)
│   ├── motorcycles.controller.ts  # CRUD endpoints
│   ├── motorcycles.service.ts
│   └── motorcycles.module.ts
├── deliveries/            # Delivery management
│   ├── dto/               # CreateDeliveryDto
│   ├── schemas/           # Delivery schema (pickup, delivery, cost, status)
│   ├── deliveries.controller.ts  # Delivery endpoints
│   ├── deliveries.service.ts     # Delivery logic + cost calculation
│   └── deliveries.module.ts
├── drivers/               # Driver schema (references User and Motorcycle)
│   └── schemas/
│       └── driver.schema.ts
├── core/                  # Core utilities
│   ├── utils/
│   │   └── cost-calculator.service.ts  # Delivery cost calculation
│   └── core.module.ts
├── common/                # Shared utilities
│   └── filters/
│       └── all-exceptions.filter.ts  # Global exception handler
├── config/                # Configuration
│   └── database-config.service.ts    # MongoDB connection config
├── health/                # Health check module
│   ├── health.controller.ts  # GET /health
│   └── health.module.ts
├── app.module.ts          # Root module
└── main.ts                # Application bootstrap (CORS enabled, Swagger setup)
```

### Database Schemas

#### User Schema
```typescript
{
  email: string (unique, required)
  password: string (hashed with bcrypt)
  name: string (required)
  timestamps: createdAt, updatedAt
}
```

#### Motorcycle Schema
```typescript
{
  model: string (required)
  brand: string (required)
  fuelConsumption: number (required) // Liters per 100 km
  engineType: string (optional)
  capacity: number (optional) // CC
  year: number (optional)
  timestamps: createdAt, updatedAt
}
```

#### Driver Schema
```typescript
{
  userId: ObjectId (ref: User, unique, required)
  licenseNumber: string (required)
  phoneNumber: string (required)
  motorcycleId: ObjectId (ref: Motorcycle, optional)
  isAvailable: boolean (default: false)
  totalDeliveries: number (default: 0)
  rating: number (default: 0)
  timestamps: createdAt, updatedAt
}
```

#### Delivery Schema
```typescript
{
  userId: ObjectId (ref: User, required)
  driverId: ObjectId (ref: Driver, optional)
  motorcycleId: ObjectId (ref: Motorcycle, optional)
  pickupLocation: string (required)
  deliveryAddress: string (required)
  deliveryType: string (required) // "Food", "Package", etc.
  distance: number (required) // kilometers
  estimatedCost: number (calculated)
  actualCost: number (optional)
  estimatedTime: number (optional) // minutes
  status: string (default: "pending") // "pending", "in_progress", "completed", "cancelled"
  timestamps: createdAt, updatedAt
}
```

### API Endpoints

#### Authentication (Public)
- `POST /auth/register` - Register new user
  ```json
  Request: { "email": "user@example.com", "password": "pass123", "name": "John Doe" }
  Response: { "access_token": "jwt_token_here" }
  ```
- `POST /auth/login` - Login user
  ```json
  Request: { "email": "user@example.com", "password": "pass123" }
  Response: { "access_token": "jwt_token_here" }
  ```

#### Health Check (Public)
- `GET /health` - Health check with MongoDB status

#### Motorcycles (Public, but should be protected)
- `GET /motorcycles` - List all motorcycles
- `GET /motorcycles/:id` - Get motorcycle by ID
- `POST /motorcycles` - Create motorcycle
  ```json
  Request: {
    "model": "Forza",
    "brand": "Honda",
    "fuelConsumption": 3.5,
    "engineType": "4-stroke",
    "capacity": 300,
    "year": 2020
  }
  ```
- `PATCH /motorcycles/:id` - Update motorcycle
- `DELETE /motorcycles/:id` - Delete motorcycle

#### Deliveries (Should be protected with JWT)
- `GET /deliveries` - Get all deliveries (for authenticated user)
- `POST /deliveries` - Create delivery
  ```json
  Request: {
    "pickupLocation": "Address 1",
    "deliveryAddress": "Address 2",
    "deliveryType": "Food",
    "distance": 10.5,
    "motorcycleId": "motorcycle_id"
  }
  ```
- `GET /deliveries/:id` - Get delivery by ID
- `PATCH /deliveries/:id/status` - Update delivery status
- `POST /deliveries/:id/calculate-cost` - Calculate delivery cost

### Cost Calculation Formula

```typescript
Cost = BASE_DELIVERY_FEE + (Distance / 100) * Fuel Consumption * FUEL_PRICE_PER_LITER
```

**Environment Variables:**
- `BASE_DELIVERY_FEE` (default: 5.0)
- `FUEL_PRICE_PER_LITER` (default: 2.5)

### Environment Configuration (.env)
```env
NODE_ENV=development
PORT=3003
MONGODB_URI=mongodb://localhost:27017/ubermoto
JWT_SECRET=your-super-secret-jwt-key-change-in-production
JWT_EXPIRES_IN=1h
FUEL_PRICE_PER_LITER=2.5
BASE_DELIVERY_FEE=5.0
```

### Key Features
- ✅ JWT Authentication with Passport.js
- ✅ Password hashing with bcryptjs (10 rounds)
- ✅ Global exception filter (AllExceptionsFilter)
- ✅ CORS enabled for Flutter frontend
- ✅ Swagger documentation at `/api`
- ✅ Health check endpoint
- ✅ TypeScript strict mode
- ✅ Unit tests for services and controllers
- ✅ Validation with class-validator DTOs
- ✅ MongoDB integration with Mongoose

### Security
- JWT tokens in Authorization header: `Bearer <token>`
- Password hashing with bcryptjs
- Global exception filter for error handling
- CORS configured for development (allows all origins)

---

## Frontend (Flutter)

### Technology Stack
- **Framework**: Flutter 3.x
- **Language**: Dart 3.x
- **State Management**: Riverpod 2.x (flutter_riverpod, riverpod_annotation)
- **HTTP Client**: http package
- **Storage**: flutter_secure_storage (JWT tokens)
- **Geolocation**: geolocator, geocoding
- **Maps**: google_maps_flutter
- **Serialization**: json_annotation, json_serializable
- **Code Generation**: build_runner

### Project Structure
```
frontend/lib/
├── config/
│   └── app_config.dart          # API base URL, endpoints (currently port 3003)
├── core/
│   ├── constants/
│   │   └── storage_keys.dart   # Storage key constants
│   ├── errors/
│   │   └── app_exception.dart  # Custom exceptions (NetworkException, etc.)
│   └── utils/
│       ├── storage_service.dart      # Secure storage wrapper
│       ├── geolocation_service.dart  # Get current location
│       └── distance_calculator.dart  # Calculate distance between coordinates
├── models/                      # Data models with JSON serialization
│   ├── user_model.dart
│   ├── auth_response_model.dart
│   ├── delivery_model.dart
│   └── motorcycle_model.dart
├── services/                    # API service layer
│   ├── api_service.dart         # Base HTTP client (GET, POST, PATCH)
│   ├── auth_service.dart        # Login, Register, Logout
│   ├── delivery_service.dart    # Delivery CRUD operations
│   └── motorcycle_service.dart # Motorcycle CRUD operations
├── features/                    # Feature-based organization
│   ├── auth/
│   │   ├── providers/
│   │   │   └── auth_provider.dart  # Riverpod auth state provider
│   │   └── screens/
│   │       ├── login_screen.dart    # Login UI
│   │       └── register_screen.dart # Registration UI
│   ├── delivery/
│   │   ├── providers/
│   │   │   └── delivery_provider.dart  # Riverpod delivery state
│   │   └── screens/
│   │       ├── delivery_create_screen.dart  # Create delivery with cost estimation
│   │       └── delivery_list_screen.dart    # List all deliveries
│   └── motorcycles/
│       ├── providers/
│       │   └── motorcycle_provider.dart  # Riverpod motorcycle state
│       └── screens/
│           ├── motorcycle_register_screen.dart  # Register motorcycle
│           └── motorcycle_list_screen.dart      # List motorcycles
├── widgets/                     # Reusable UI components
│   ├── custom_button.dart
│   ├── custom_text_field.dart
│   └── error_message.dart
└── main.dart                    # App entry point (checks auth, routes to Login/DeliveryList)
```

### Data Models

#### AuthResponseModel
```dart
{
  accessToken: string (from 'access_token' in JSON)
}
```

#### UserModel
```dart
{
  id: string
  email: string
  name: string
}
```

#### DeliveryModel
```dart
{
  id: string
  userId: string
  driverId: string (optional)
  motorcycleId: string (optional)
  pickupLocation: string
  deliveryAddress: string
  deliveryType: string
  distance: number
  estimatedCost: number
  actualCost: number (optional)
  estimatedTime: number (optional)
  status: string
  createdAt: DateTime
  updatedAt: DateTime
}
```

#### MotorcycleModel
```dart
{
  id: string
  model: string
  brand: string
  fuelConsumption: number
  engineType: string (optional)
  capacity: number (optional)
  year: number (optional)
}
```

### API Configuration

**Current Setup:**
- Base URL: `http://localhost:3003` (configurable in `app_config.dart`)
- iOS Simulator: `http://localhost:3003`
- Android Emulator: `http://10.0.2.2:3003`
- Physical Device: `http://<your-ip>:3003`

**Endpoints:**
- Login: `/auth/login`
- Register: `/auth/register`
- Deliveries: `/deliveries`
- Motorcycles: `/motorcycles`

### Authentication Flow
1. User registers/logs in → Receives JWT token
2. Token stored securely using `flutter_secure_storage`
3. Token included in Authorization header for protected requests
4. App checks token on startup → Routes to Login or DeliveryListScreen

### Key Features
- ✅ JWT Authentication (Login/Register)
- ✅ Secure token storage
- ✅ Delivery creation with cost estimation
- ✅ Delivery listing
- ✅ Motorcycle registration
- ✅ Motorcycle listing
- ✅ Geolocation integration
- ✅ Distance calculation
- ✅ Material Design UI
- ✅ Error handling with custom exceptions
- ✅ Riverpod state management
- ✅ Clean architecture (features, services, models separation)

### Current Issues/Notes
- Backend currently runs on port 3003 (port 3002 was occupied by another project)
- Frontend configured for port 3003
- CORS enabled on backend for development
- Some endpoints may need JWT protection (motorcycles, deliveries)

---

## Development Workflow

### Starting the Application

1. **Backend:**
   ```bash
   cd backend
   npm install
   # Create .env file with configuration
   npm run start:dev  # Runs on port from .env (currently 3003)
   ```

2. **Frontend:**
   ```bash
   cd frontend
   flutter pub get
   flutter pub run build_runner build --delete-conflicting-outputs
   flutter run
   ```

### Port Management
- Script available: `./switch-port.sh <PORT>` to change ports
- Backend supports ports: 3001, 3002, 3003, 3004
- Frontend port configured in `lib/config/app_config.dart`

### Testing
- **Backend**: `npm test` (Jest)
- **Frontend**: `flutter test`
- **API Testing**: Swagger UI at `http://localhost:3003/api`
- **Postman**: Collection available in `backend/UberMoto_API.postman_collection.json`

---

## Legal Framework Compliance

The platform is designed to comply with Tunisian legal framework:
- **Option C**: Delivery services using motorcycles are legal
- **Option B**: Private peer-to-peer transport facilitation (platform doesn't take responsibility)

---

## Current Status

### Completed Features
- ✅ Backend authentication (JWT)
- ✅ User registration and login
- ✅ Motorcycle CRUD operations
- ✅ Delivery CRUD operations
- ✅ Cost calculation based on fuel consumption
- ✅ Frontend authentication screens
- ✅ Delivery creation and listing
- ✅ Motorcycle registration and listing
- ✅ Swagger API documentation
- ✅ Postman collection
- ✅ CORS configuration
- ✅ Secure token storage
- ✅ Error handling

### Known Issues
- Some endpoints may need JWT protection
- Port configuration needs to be synchronized between backend and frontend
- Delivery cost calculation needs motorcycle data linked to driver

### Next Steps (Potential)
- Link motorcycles to drivers/users
- Implement driver registration flow
- Add delivery status tracking
- Implement real-time updates
- Add payment integration
- Add rating system
- Add push notifications
- Add driver availability management

---

## Git Repository

- **Repository**: https://github.com/chekerh/ubermoto.git
- **Main Branch**: `main` (monorepo with both backend and frontend)
- **CI/CD**: GitHub Actions configured for both backend and frontend

---

## Contact & Documentation

- Backend README: `backend/README.md`
- Frontend README: `frontend/README.md`
- API Testing Guide: `backend/API_TESTING_GUIDE.md`
- Swagger UI: `http://localhost:3003/api` (when backend is running)
