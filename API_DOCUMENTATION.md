# 📡 UberMoto API Documentation

Complete API reference for the UberMoto motorcycle delivery platform.

## Base URL
```
Production: https://api.ubermoto.com
Development: http://localhost:3001
```

## Authentication

All API requests require authentication except for registration and login endpoints.

### Headers
```
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

### Token Expiration
- Access tokens expire after 24 hours
- Refresh tokens can be used to get new access tokens
- Include refresh token logic in your client applications

## Response Format

### Success Response
```json
{
  "statusCode": 200,
  "message": "Success",
  "data": { ... }
}
```

### Error Response
```json
{
  "statusCode": 400,
  "message": "Error description",
  "error": "Bad Request"
}
```

---

## Authentication Endpoints

### POST /auth/register/customer
Register a new customer account.

**Request:**
```bash
curl -X POST http://localhost:3001/auth/register/customer \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "securepassword123"
  }'
```

**Response (201):**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "id": "64f1a2b3c4d5e6f7g8h9i0j1",
    "name": "John Doe",
    "email": "john@example.com",
    "role": "CUSTOMER",
    "isVerified": false
  }
}
```

### POST /auth/register/driver
Register a new driver account with license information.

**Request:**
```bash
curl -X POST http://localhost:3001/auth/register/driver \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Jane Driver",
    "email": "jane@example.com",
    "password": "securepassword123",
    "phoneNumber": "+21612345678",
    "licenseNumber": "DRV123456789"
  }'
```

**Response (201):**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "id": "64f1a2b3c4d5e6f7g8h9i0j2",
    "name": "Jane Driver",
    "email": "jane@example.com",
    "role": "DRIVER",
    "isVerified": false
  }
}
```

### POST /auth/login
Authenticate user and receive access token.

**Request:**
```bash
curl -X POST http://localhost:3001/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "securepassword123"
  }'
```

**Response (200):**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "id": "64f1a2b3c4d5e6f7g8h9i0j1",
    "name": "John Doe",
    "email": "john@example.com",
    "role": "CUSTOMER"
  }
}
```

---

## Delivery Endpoints

### POST /deliveries
Create a new delivery request.

**Headers:** `Authorization: Bearer <token>`

**Request:**
```bash
curl -X POST http://localhost:3001/deliveries \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "pickupLocation": "Downtown Mall, Tunis",
    "deliveryAddress": "123 Residential St, Tunis",
    "deliveryType": "Food",
    "distance": 5.2,
    "motorcycleId": "64f1a2b3c4d5e6f7g8h9i0j3"
  }'
```

**Response (201):**
```json
{
  "_id": "64f1a2b3c4d5e6f7g8h9i0j4",
  "pickupLocation": "Downtown Mall, Tunis",
  "deliveryAddress": "123 Residential St, Tunis",
  "deliveryType": "Food",
  "status": "pending",
  "userId": "64f1a2b3c4d5e6f7g8h9i0j1",
  "distance": 5.2,
  "estimatedCost": 7.88,
  "pickupLatitude": 36.8065,
  "pickupLongitude": 10.1815,
  "deliveryLatitude": 36.8188,
  "deliveryLongitude": 10.1658,
  "createdAt": "2024-01-22T10:00:00.000Z",
  "updatedAt": "2024-01-22T10:00:00.000Z"
}
```

### GET /deliveries
Get all deliveries for the authenticated user.

**Headers:** `Authorization: Bearer <token>`

**Request:**
```bash
curl -X GET http://localhost:3001/deliveries \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIs..."
```

**Response (200):**
```json
{
  "data": [
    {
      "_id": "64f1a2b3c4d5e6f7g8h9i0j4",
      "pickupLocation": "Downtown Mall, Tunis",
      "deliveryAddress": "123 Residential St, Tunis",
      "status": "pending",
      "estimatedCost": 7.88,
      "createdAt": "2024-01-22T10:00:00.000Z"
    }
  ],
  "total": 1,
  "page": 1,
  "limit": 10
}
```

### GET /deliveries/:id
Get specific delivery details.

**Headers:** `Authorization: Bearer <token>`

**Request:**
```bash
curl -X GET http://localhost:3001/deliveries/64f1a2b3c4d5e6f7g8h9i0j4 \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIs..."
```

### PATCH /deliveries/:id/status
Update delivery status (driver only).

**Headers:** `Authorization: Bearer <token>`

**Request:**
```bash
curl -X PATCH http://localhost:3001/deliveries/64f1a2b3c4d5e6f7g8h9i0j4/status \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "status": "accepted"
  }'
```

**Valid Status Transitions:**
- `pending` → `accepted` (driver accepts delivery)
- `accepted` → `picked_up` (driver picks up package)
- `picked_up` → `in_progress` (delivery in transit)
- `in_progress` → `completed` (delivery completed)

---

## Driver Endpoints

### GET /drivers/profile
Get driver profile information.

**Headers:** `Authorization: Bearer <token>`

### PATCH /drivers/:id/availability
Update driver availability status.

**Headers:** `Authorization: Bearer <token>`

**Request:**
```bash
curl -X PATCH http://localhost:3001/drivers/64f1a2b3c4d5e6f7g8h9i0j2/availability \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "isAvailable": true
  }'
```

### POST /drivers/:id/documents
Upload driver documents.

**Headers:** `Authorization: Bearer <token>`

**Request:**
```bash
curl -X POST http://localhost:3001/drivers/64f1a2b3c4d5e6f7g8h9i0j2/documents \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "licenseDocument": "/uploads/drivers/license_123.jpg",
    "idDocument": "/uploads/drivers/id_123.jpg",
    "motorcycleDocument": "/uploads/drivers/motorcycle_123.jpg"
  }'
```

---

## Motorcycle Endpoints

### GET /motorcycles
Get all available motorcycles.

**Headers:** `Authorization: Bearer <token>`

### POST /motorcycles
Create a new motorcycle (admin only).

**Headers:** `Authorization: Bearer <token>`

**Request:**
```bash
curl -X POST http://localhost:3001/motorcycles \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIs..." \
  -H "Content-Type: application/json" \
  -d '{
    "model": "Forza 350",
    "brand": "Honda",
    "fuelConsumption": 3.5,
    "engineType": "4-stroke",
    "capacity": 350,
    "year": 2023
  }'
```

---

## WebSocket API

### Connection
```javascript
import io from 'socket.io-client';

const socket = io('http://localhost:3001/delivery', {
  auth: { token: 'your_jwt_token' }
});
```

### Authentication
WebSocket connections require JWT token authentication:
```javascript
{
  auth: { token: 'eyJhbGciOiJIUzI1NiIs...' }
}
```

### Events

#### Server → Client Events

**new_delivery** (to drivers)
```javascript
socket.on('new_delivery', (data) => {
  console.log('New delivery available:', data);
  // data: { deliveryId, pickupLocation, deliveryAddress, estimatedCost, distance, createdAt }
});
```

**delivery_status_update**
```javascript
socket.on('delivery_status_update', (data) => {
  console.log('Delivery status updated:', data);
  // data: { deliveryId, status, driverId, updatedAt }
});
```

**driver_assigned** (to customers)
```javascript
socket.on('driver_assigned', (data) => {
  console.log('Driver assigned to delivery:', data);
  // data: { deliveryId, driverId }
});
```

**location_update**
```javascript
socket.on('location_update', (data) => {
  console.log('Driver location updated:', data);
  // data: { deliveryId, driverId, latitude, longitude, timestamp }
});
```

#### Client → Server Events

**subscribe_to_delivery**
```javascript
socket.emit('subscribe_to_delivery', {
  deliveryId: '64f1a2b3c4d5e6f7g8h9i0j4'
});
```

**update_location** (drivers only)
```javascript
socket.emit('update_location', {
  deliveryId: '64f1a2b3c4d5e6f7g8h9i0j4',
  latitude: 36.8065,
  longitude: 10.1815
});
```

---

## Error Codes

### Authentication Errors (401)
- `Unauthorized`: Invalid or missing JWT token
- `TokenExpired`: JWT token has expired
- `InvalidToken`: Malformed JWT token

### Validation Errors (400)
- `ValidationError`: Invalid request data
- `MissingFields`: Required fields are missing
- `InvalidFormat`: Data format is incorrect

### Not Found Errors (404)
- `UserNotFound`: User does not exist
- `DeliveryNotFound`: Delivery does not exist
- `DriverNotFound`: Driver profile not found

### Conflict Errors (409)
- `UserExists`: User with email already exists
- `DriverExists`: Driver profile already exists
- `InvalidTransition`: Invalid status transition

### Server Errors (500)
- `InternalServerError`: Unexpected server error
- `DatabaseError`: Database operation failed
- `WebSocketError`: Real-time communication failed

---

## Rate Limiting

- **Authenticated requests:** 1000 requests per hour
- **Unauthenticated requests:** 100 requests per hour
- **WebSocket connections:** 10 concurrent connections per user

Rate limit headers are included in responses:
```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1640995200
```

---

## SDKs and Libraries

### JavaScript/Node.js
```javascript
const UberMotoAPI = require('ubermoto-api-sdk');

const client = new UberMotoAPI({
  baseURL: 'https://api.ubermoto.com',
  apiKey: 'your_api_key'
});

// Create delivery
const delivery = await client.deliveries.create({
  pickupLocation: 'Location A',
  deliveryAddress: 'Location B',
  deliveryType: 'Food'
});
```

### Mobile SDKs
```dart
// Flutter
final ubermoto = UberMotoSDK(
  apiKey: 'your_api_key',
  baseUrl: 'https://api.ubermoto.com'
);

// Create delivery
final delivery = await ubermoto.deliveries.create(
  pickupLocation: 'Location A',
  deliveryAddress: 'Location B',
  deliveryType: DeliveryType.food
);
```

---

## Changelog

### Version 1.0.0
- Initial release with core delivery functionality
- Real-time tracking with WebSocket support
- Google Maps integration for delivery visualization
- Driver onboarding with document verification
- Cost calculation based on fuel consumption
- Mobile and web platform support

---

## Support

For API support and questions:
- 📧 Email: api@ubermoto.com
- 📖 Documentation: https://docs.ubermoto.com
- 🐛 Issues: https://github.com/ubermoto/platform/issues
- 💬 Community: https://community.ubermoto.com

---

*Last updated: January 22, 2026*
*API Version: 1.0.0*
