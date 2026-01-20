# UberMoto

Full-stack application with separate frontend and backend.

## Project Structure

```
ubermoto/
├── backend/          # NestJS backend API
└── frontend/        # Flutter frontend application
```

## Backend

The backend is a NestJS application with JWT authentication and MongoDB integration.

See [backend/README.md](./backend/README.md) for detailed backend documentation.

### Quick Start

```bash
cd backend
npm install
cp .env.example .env  # Configure your environment variables
npm run start:dev
```

## Frontend

The frontend is a Flutter application with Riverpod state management, JWT authentication, and delivery management features.

See [frontend/README.md](./frontend/README.md) for detailed frontend documentation.

### Quick Start

```bash
cd frontend
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

## Development

- Backend runs on `http://localhost:3000`
- Frontend runs on a separate port (Flutter default)

### API Configuration

Update the API base URL in `frontend/lib/config/app_config.dart`:
- For Android emulator: `http://10.0.2.2:3000`
- For iOS simulator: `http://localhost:3000`
- For physical device: `http://<your-ip>:3000`

## Features

### Backend
- ✅ JWT Authentication
- ✅ User Registration & Login
- ✅ MongoDB Integration
- ✅ Health Check Endpoint
- ✅ Global Exception Handling
- ✅ TypeScript Strict Mode
- ✅ Unit Tests
- ✅ Swagger API Documentation
- ✅ Postman Collection

### Frontend
- ✅ JWT Authentication (Login/Register)
- ✅ Delivery Management (Create, List)
- ✅ Riverpod State Management
- ✅ Secure Token Storage
- ✅ Clean Architecture
- ✅ Material Design UI
- ✅ Error Handling

## License

MIT
