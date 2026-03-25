# 🚀 UberMoto - Motorcycle Delivery Platform

A comprehensive full-stack motorcycle delivery marketplace built with modern technologies, featuring real-time tracking, geolocation services, and seamless user experience.

## ✨ Features

### 🎯 Core Functionality
- **Real-time Delivery Tracking** with Google Maps integration
- **Cost Calculation Engine** based on fuel consumption and distance
- **Driver Onboarding** with document verification
- **WebSocket Communication** for live updates
- **Geolocation Services** with address-to-coordinates conversion
- **Role-based Authentication** (Customer, Driver, Admin)

### 👤 User Features
- **Customer Dashboard:** Create deliveries, track progress, view history
- **Driver Portal:** Accept deliveries, update status, manage availability
- **Real-time Notifications:** Live updates on delivery status
- **Secure Payments:** Integrated payment processing (future feature)

### 🛠️ Technical Features
- **Responsive Design:** Mobile-first approach across all platforms
- **Offline Support:** Graceful handling of network interruptions
- **Performance Optimized:** Fast loading and smooth interactions
- **Automated tests:** backend Jest (unit + MongoDB Memory Server e2e smoke); Flutter `flutter test` for providers/models — run `npm test` / `npm run test:e2e` / `flutter test` for current counts (coverage varies by run)

## 🏗️ Architecture

### Backend (NestJS + MongoDB)
```
src/
├── auth/           # Authentication & authorization
├── users/          # User management & profiles
├── drivers/        # Driver-specific functionality
├── deliveries/     # Delivery management & tracking
├── motorcycles/    # Motorcycle data & cost calculation
├── websocket/      # Real-time communication
├── core/           # Shared utilities & services
└── health/         # Health checks & monitoring
```

### Frontend (Flutter)
```
lib/
├── core/           # App configuration & utilities
├── features/       # Feature-based architecture
│   ├── auth/       # Authentication screens & providers
│   ├── delivery/   # Delivery creation & tracking
│   ├── driver/     # Driver-specific features
│   └── customer/   # Customer-specific features
├── models/         # Data models & serialization
├── services/       # API services & WebSocket
├── widgets/        # Reusable UI components
└── providers/      # State management
```

## 🚀 Quick Start

### Prerequisites
- Node.js 18+ and npm
- Flutter 3.0+ and Dart
- MongoDB database
- Google Maps API key
- Firebase project (for hosting)

### Backend Setup
```bash
cd backend
npm install
cp .env.example .env
# Configure environment variables
npm run start:dev
```

### Frontend Setup
```bash
cd frontend
flutter pub get
flutter run -d web-server --web-port=8080
```

### Environment Variables

#### Backend (.env)
```bash
MONGODB_URI=mongodb://localhost:27017/ubermoto
JWT_SECRET=your_jwt_secret_here
PORT=3001
NODE_ENV=development

# Optional
SENTRY_DSN=your_sentry_dsn
GOOGLE_MAPS_API_KEY=your_maps_api_key
```

#### Frontend
```bash
flutter run \
  --dart-define=API_BASE_URL=http://localhost:3001 \
  --dart-define=GOOGLE_MAPS_API_KEY=your_maps_api_key \
  --dart-define=SENTRY_DSN=your_sentry_dsn
```

## 📡 API Documentation

### Authentication Endpoints

#### POST /auth/register/customer
Register a new customer account.

**Request Body:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "securepassword"
}
```

**Response:**
```json
{
  "access_token": "jwt_token_here",
  "user": {
    "id": "user_id",
    "name": "John Doe",
    "email": "john@example.com",
    "role": "CUSTOMER"
  }
}
```

#### POST /auth/login
Authenticate user and get access token.

**Request Body:**
```json
{
  "email": "john@example.com",
  "password": "securepassword"
}
```

### Delivery Endpoints

#### POST /deliveries
Create a new delivery request.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "pickupLocation": "Downtown Mall, City",
  "deliveryAddress": "123 Residential St, City",
  "deliveryType": "Food",
  "distance": 5.2,
  "motorcycleId": "motorcycle_id"
}
```

**Response:**
```json
{
  "_id": "delivery_id",
  "pickupLocation": "Downtown Mall, City",
  "deliveryAddress": "123 Residential St, City",
  "deliveryType": "Food",
  "status": "pending",
  "estimatedCost": 7.88,
  "distance": 5.2,
  "createdAt": "2024-01-22T10:00:00.000Z"
}
```

#### PATCH /deliveries/:id/status
Update delivery status.

**Status Flow:** `pending` → `accepted` → `picked_up` → `in_progress` → `completed`

**Request Body:**
```json
{
  "status": "accepted"
}
```

### WebSocket Events

Connect to: `ws://your-server/delivery`

#### Authentication
```javascript
const socket = io('http://localhost:3001/delivery', {
  auth: { token: 'your_jwt_token' }
});
```

#### Listen for Events
```javascript
// New delivery available (drivers)
socket.on('new_delivery', (data) => {
  console.log('New delivery:', data);
});

// Delivery status updates
socket.on('delivery_status_update', (data) => {
  console.log('Status update:', data);
});

// Driver assigned to delivery
socket.on('driver_assigned', (data) => {
  console.log('Assigned to delivery:', data);
});
```

#### Emit Events
```javascript
// Subscribe to specific delivery
socket.emit('subscribe_to_delivery', { deliveryId: 'delivery_id' });

// Update driver location
socket.emit('update_location', {
  deliveryId: 'delivery_id',
  latitude: 36.8065,
  longitude: 10.1815
});
```

## 🗄️ Database Schema

### Users Collection
```javascript
{
  _id: ObjectId,
  email: String (unique),
  password: String (hashed),
  name: String,
  role: Enum ['CUSTOMER', 'DRIVER', 'ADMIN'],
  isVerified: Boolean,
  createdAt: Date,
  updatedAt: Date
}
```

### Drivers Collection
```javascript
{
  _id: ObjectId,
  userId: ObjectId (ref: 'users'),
  licenseNumber: String,
  phoneNumber: String,
  motorcycleId: ObjectId (ref: 'motorcycles'),
  isAvailable: Boolean,
  totalDeliveries: Number,
  rating: Number,
  licenseDocument: String,    // File path/URL
  idDocument: String,         // File path/URL
  motorcycleDocument: String, // File path/URL
  isVerified: Boolean
}
```

### Deliveries Collection
```javascript
{
  _id: ObjectId,
  pickupLocation: String,
  deliveryAddress: String,
  deliveryType: String,
  status: Enum ['pending', 'accepted', 'picked_up', 'in_progress', 'completed', 'cancelled'],
  userId: ObjectId (ref: 'users'),
  driverId: ObjectId (ref: 'drivers'),
  motorcycleId: ObjectId (ref: 'motorcycles'),
  distance: Number,
  estimatedCost: Number,
  actualCost: Number,
  pickupLatitude: Number,
  pickupLongitude: Number,
  deliveryLatitude: Number,
  deliveryLongitude: Number,
  driverLatitude: Number,
  driverLongitude: Number,
  createdAt: Date,
  updatedAt: Date
}
```

## 🧪 Testing

### Backend Tests
```bash
cd backend
npm run test              # Run all tests
npm run test:cov         # Run with coverage
npm run test:e2e         # Run e2e tests
```

### Frontend Tests
```bash
cd frontend
flutter test             # Run unit tests
flutter test integration_test/  # Run integration tests
flutter test --coverage  # Run with coverage
```

### Automated Testing Scripts
```bash
# Run comprehensive test suite
./scripts/verify-ci-cd.sh

# Test real-time features
./scripts/test-realtime-features.sh
```

## 🚀 Deployment

### Backend Deployment
```bash
# Prepare for deployment
./scripts/prepare-backend-deployment.sh

# Deploy to production (manual step)
# - Heroku: heroku create && git push heroku main
# - AWS: Use Elastic Beanstalk or EC2
# - Docker: docker build && docker run
```

### Frontend Deployment
```bash
# Prepare builds
./scripts/prepare-frontend-deployment.sh

# Deploy web to Firebase
firebase deploy --only hosting

# Submit mobile apps to stores
# - Android: Submit AAB to Google Play Console
# - iOS: Submit to App Store Connect via Xcode
```

### Environment Setup
```bash
# Copy environment templates
cp backend/.env.example backend/.env
cp frontend/.env.example frontend/.env

# Configure required variables
# See deployment documentation for details
```

## 📊 Monitoring & Analytics

### Setup Monitoring
```bash
# Run monitoring setup script
./scripts/setup-monitoring.sh
```

### Configured Services
- **Sentry:** Error tracking and performance monitoring
- **Google Analytics:** User behavior and conversion tracking
- **Response Time Monitoring:** API performance tracking
- **Health Checks:** Application and database status

### Key Metrics Tracked
- API response times and error rates
- User registration and login events
- Delivery creation and completion rates
- Driver availability and assignment stats
- Real-time WebSocket connection status

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

### Development Guidelines
- Follow existing code style and patterns
- Add tests for new features
- Update documentation as needed
- Ensure all tests pass before submitting PR

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:
- Create an issue on GitHub
- Check the documentation in `/docs`
- Review the troubleshooting guide

## 🗺️ Roadmap

### Phase 1 (Current) ✅
- Core delivery platform with real-time tracking
- Driver and customer management
- Basic geolocation and mapping

### Phase 2 (Next) 🚧
- Payment integration (Stripe/PayPal)
- Advanced driver analytics
- Customer loyalty program
- Multi-language support

### Phase 3 (Future) 📋
- AI-powered route optimization
- Predictive delivery time estimation
- Advanced driver matching algorithms
- Integration with third-party logistics

---

**Built with ❤️ using NestJS, Flutter, MongoDB, and modern web technologies**
