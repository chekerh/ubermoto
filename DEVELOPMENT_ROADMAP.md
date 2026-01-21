# UberMoto Development Roadmap - Complete Plan

## Executive Summary

This document provides a comprehensive roadmap for the UberMoto motorcycle delivery platform, from fixing current compilation errors to achieving a production-ready state. The platform separates customer and driver registration flows and implements real-time delivery tracking.

---

## Table of Contents

1. [Current State Assessment](#current-state-assessment)
2. [Immediate Fixes Required](#immediate-fixes-required)
3. [Registration Separation Verification](#registration-separation-verification)
4. [Phase 1: Foundation & Core Features](#phase-1-foundation--core-features)
5. [Phase 2: Real-Time Features & Matching](#phase-2-real-time-features--matching)
6. [Phase 3: Production Readiness](#phase-3-production-readiness)
7. [Phase 4: Advanced Features](#phase-4-advanced-features)
8. [Technical Architecture](#technical-architecture)
9. [Testing Strategy](#testing-strategy)
10. [Deployment Plan](#deployment-plan)

---

## Current State Assessment

### ✅ What's Already Implemented

#### Backend (NestJS)
- **Authentication System**
  - JWT-based authentication with Passport.js
  - Separate registration endpoints: `/auth/register/customer` and `/auth/register/driver`
  - Role-based access control (CUSTOMER, DRIVER, ADMIN)
  - User schema with role and verification fields

- **User Management**
  - User CRUD operations
  - Role-based user creation
  - Phone number support for drivers
  - Verification status tracking

- **Driver Module**
  - Driver schema with license number, phone, motorcycle reference
  - Driver service with availability management
  - Driver profile creation linked to user accounts
  - Driver rating and delivery count tracking

- **Document Management**
  - Document schema for driver verification
  - Document upload endpoint (local storage)
  - Document type enum (LICENSE, ID_CARD, INSURANCE, VEHICLE_REGISTRATION)
  - Admin document review endpoints

- **Delivery System**
  - Delivery CRUD operations
  - Cost calculation based on fuel consumption
  - Delivery status workflow (PENDING, ACCEPTED, PICKED_UP, DELIVERED, CANCELLED)
  - Delivery matching service (location-based scoring)

- **Admin Module**
  - Admin controller and service
  - Driver verification workflow
  - Document approval/rejection

- **WebSocket Infrastructure**
  - WebSocket gateway structure (incomplete - has errors)
  - Real-time event emission methods
  - Room-based messaging (user, role, delivery rooms)

#### Frontend (Flutter)
- **Authentication Screens**
  - Role selection screen
  - Customer registration screen
  - Driver registration screen
  - Driver documents upload screen
  - Login screen
  - Home screen with role-based navigation

- **State Management**
  - Riverpod providers for auth, documents
  - Auth provider with customer/driver registration methods

- **Services**
  - Auth service with separate customer/driver registration
  - API service base layer
  - Secure token storage

### ❌ Current Issues

#### Critical Compilation Errors
1. **WebSocket Dependencies Missing**
   - `@nestjs/websockets` package not installed
   - `socket.io` package not installed
   - `@types/socket.io` types missing

2. **TypeScript Type Errors in WebSocket Gateway**
   - `AuthenticatedSocket` interface doesn't properly extend Socket
   - Missing `handshake`, `disconnect`, `join`, `leave` properties
   - Error handling type issues

3. **Unused Imports**
   - `UseGuards` imported but not used
   - `args` parameter declared but unused

#### Functional Gaps
1. **File Storage**
   - Document upload saves to local path but file isn't actually written
   - No cloud storage integration

2. **Location Services**
   - GPS tracking not fully implemented
   - Distance calculation placeholder in matching service

3. **Frontend Integration**
   - WebSocket client not implemented in Flutter
   - Real-time updates not connected

---

## Immediate Fixes Required

### Priority 1: Fix Compilation Errors

#### 1.1 Install Missing WebSocket Dependencies
```bash
cd backend
npm install @nestjs/websockets socket.io
npm install --save-dev @types/socket.io
```

#### 1.2 Fix TypeScript Types in WebSocket Gateway
- Update `AuthenticatedSocket` interface to properly extend Socket
- Fix error handling types
- Remove unused imports

#### 1.3 Verify Registration Separation
- Confirm customer registration doesn't require driver fields
- Confirm driver registration requires license and phone
- Test both endpoints independently

---

## Registration Separation Verification

### Current Implementation Status

#### Backend Separation ✅
- **Customer Registration**: `/auth/register/customer`
  - DTO: `CustomerRegisterDto` (email, password, name)
  - Role: Automatically set to `CUSTOMER`
  - No driver-specific fields required

- **Driver Registration**: `/auth/register/driver`
  - DTO: `DriverRegisterDto` (email, password, name, phoneNumber, licenseNumber)
  - Role: Automatically set to `DRIVER`
  - Creates user account + driver profile
  - Requires phone number and license number

#### Frontend Separation ✅
- **Role Selection Screen**: User chooses CUSTOMER or DRIVER
- **Customer Registration Screen**: Simple form (email, password, name)
- **Driver Registration Screen**: Extended form (email, password, name, phone, license)
- **Driver Documents Screen**: Document upload after registration

### Verification Checklist
- [x] Separate DTOs exist (CustomerRegisterDto, DriverRegisterDto)
- [x] Separate endpoints exist (/register/customer, /register/driver)
- [x] Separate service methods exist (registerCustomer, registerDriver)
- [x] Frontend has separate registration screens
- [x] Driver registration creates driver profile automatically
- [ ] Test customer registration doesn't create driver profile
- [ ] Test driver registration requires all fields
- [ ] Test validation errors for missing driver fields

---

## Phase 1: Foundation & Core Features

### 1.1 Fix Immediate Errors (Week 1)

**Backend Tasks**
- [ ] Install WebSocket dependencies
- [ ] Fix TypeScript types in `delivery.gateway.ts`
- [ ] Remove unused imports
- [ ] Fix error handling types
- [ ] Test WebSocket connection

**Frontend Tasks**
- [ ] Verify customer registration flow works
- [ ] Verify driver registration flow works
- [ ] Test document upload (if file storage is fixed)

### 1.2 Complete File Storage System (Week 1-2)

**Backend Tasks**
- [ ] Implement local file storage for documents
- [ ] Create uploads directory structure
- [ ] Add file validation (size, type, format)
- [ ] Implement file deletion on document removal
- [ ] Add file serving endpoint for document retrieval
- [ ] Prepare for cloud storage migration (S3/Azure)

**File Structure**
```
backend/
├── uploads/
│   ├── documents/
│   │   ├── licenses/
│   │   ├── id-cards/
│   │   ├── insurance/
│   │   └── vehicle-registration/
```

### 1.3 Complete Driver Verification Workflow (Week 2)

**Backend Tasks**
- [ ] Admin endpoint to list pending verifications
- [ ] Admin endpoint to approve/reject documents
- [ ] Auto-verify driver when all 4 documents approved
- [ ] Email notification on verification status change
- [ ] Document rejection reason tracking

**Frontend Tasks**
- [ ] Admin dashboard for document review
- [ ] Document preview functionality
- [ ] Approval/rejection UI
- [ ] Driver verification status display

### 1.4 Enhance Delivery Matching (Week 2-3)

**Backend Tasks**
- [ ] Implement GPS coordinate storage for deliveries
- [ ] Implement GPS coordinate storage for drivers
- [ ] Calculate real distance between driver and pickup
- [ ] Add estimated time calculation
- [ ] Improve matching algorithm with location data
- [ ] Add motorcycle type matching (if relevant)

**Location Schema Updates**
```typescript
// Delivery schema
pickupCoordinates: { lat: number, lng: number }
deliveryCoordinates: { lat: number, lng: number }

// Driver schema
currentLocation: { lat: number, lng: number }
lastLocationUpdate: Date
```

---

## Phase 2: Real-Time Features & Matching

### 2.1 Complete WebSocket Implementation (Week 3)

**Backend Tasks**
- [ ] Fix all WebSocket gateway errors
- [ ] Implement proper authentication for WebSocket connections
- [ ] Add connection/disconnection logging
- [ ] Test all event emissions
- [ ] Add error handling for WebSocket events

**Frontend Tasks**
- [ ] Install Socket.io client for Flutter
- [ ] Create WebSocket service wrapper
- [ ] Implement connection management
- [ ] Handle reconnection logic
- [ ] Subscribe to delivery updates

### 2.2 Real-Time Delivery Tracking (Week 3-4)

**Backend Tasks**
- [ ] Driver location update endpoint
- [ ] Broadcast location updates to delivery subscribers
- [ ] Calculate ETA based on current location
- [ ] Store location history for deliveries
- [ ] Optimize WebSocket message frequency

**Frontend Tasks**
- [ ] Map integration (Google Maps)
- [ ] Real-time driver location display
- [ ] Route visualization
- [ ] ETA display
- [ ] Location update for drivers

### 2.3 Delivery Assignment Flow (Week 4)

**Backend Tasks**
- [ ] Driver accept/reject delivery endpoint
- [ ] Auto-assign best matching driver (optional)
- [ ] Delivery status update workflow
- [ ] Notify customer when driver accepts
- [ ] Handle driver cancellation

**Frontend Tasks**
- [ ] Available deliveries list for drivers
- [ ] Delivery details screen
- [ ] Accept/reject buttons
- [ ] Active delivery tracking screen
- [ ] Status update UI

### 2.4 Driver Dashboard (Week 4-5)

**Backend Tasks**
- [ ] Driver earnings calculation
- [ ] Delivery history endpoint
- [ ] Statistics endpoint (total deliveries, rating, earnings)
- [ ] Availability toggle endpoint

**Frontend Tasks**
- [ ] Driver dashboard screen
- [ ] Earnings display
- [ ] Delivery history list
- [ ] Availability toggle
- [ ] Profile management

---

## Phase 3: Production Readiness

### 3.1 Security Hardening (Week 5-6)

**Backend Tasks**
- [ ] Rate limiting on all endpoints
- [ ] Input sanitization
- [ ] SQL injection prevention (MongoDB injection)
- [ ] XSS protection
- [ ] CORS configuration for production
- [ ] JWT token refresh mechanism
- [ ] Password strength requirements
- [ ] Account lockout after failed attempts

**Security Checklist**
- [ ] All endpoints protected with JWT guards
- [ ] Role-based access control verified
- [ ] File upload validation strict
- [ ] Environment variables secured
- [ ] Error messages don't leak sensitive info

### 3.2 Error Handling & Logging (Week 6)

**Backend Tasks**
- [ ] Structured logging (Winston/Pino)
- [ ] Error tracking (Sentry integration)
- [ ] Request/response logging
- [ ] Performance monitoring
- [ ] Database query logging

**Frontend Tasks**
- [ ] Global error handler
- [ ] User-friendly error messages
- [ ] Network error handling
- [ ] Offline mode detection

### 3.3 Database Optimization (Week 6-7)

**Backend Tasks**
- [ ] Add database indexes
  - User email (unique)
  - Driver userId (unique)
  - Delivery status, driverId, userId
  - Document userId, documentType
- [ ] Query optimization
- [ ] Connection pooling
- [ ] Database migration scripts

### 3.4 API Documentation (Week 7)

**Backend Tasks**
- [ ] Complete Swagger documentation
- [ ] Add request/response examples
- [ ] Document error responses
- [ ] Add authentication examples
- [ ] Generate Postman collection

### 3.5 Testing (Week 7-8)

**Backend Tasks**
- [ ] Unit tests for all services
- [ ] Integration tests for endpoints
- [ ] WebSocket connection tests
- [ ] E2E tests for critical flows
- [ ] Load testing

**Frontend Tasks**
- [ ] Widget tests
- [ ] Integration tests
- [ ] E2E tests with Flutter Driver
- [ ] UI tests

---

## Phase 4: Advanced Features

### 4.1 Payment Integration (Month 3)

**Backend Tasks**
- [ ] Payment gateway integration (Stripe/PayPal)
- [ ] Payment processing for deliveries
- [ ] Driver payout system
- [ ] Transaction history
- [ ] Refund handling

**Frontend Tasks**
- [ ] Payment method selection
- [ ] Payment confirmation
- [ ] Transaction history
- [ ] Driver earnings withdrawal

### 4.2 Rating & Review System (Month 3)

**Backend Tasks**
- [ ] Rating schema (delivery ratings)
- [ ] Review text storage
- [ ] Average rating calculation
- [ ] Rating endpoints

**Frontend Tasks**
- [ ] Rating UI after delivery
- [ ] Review text input
- [ ] Display ratings on profiles
- [ ] Rating history

### 4.3 Push Notifications (Month 3-4)

**Backend Tasks**
- [ ] Firebase Cloud Messaging setup
- [ ] Notification service
- [ ] Delivery status notifications
- [ ] Driver assignment notifications

**Frontend Tasks**
- [ ] FCM integration
- [ ] Notification handling
- [ ] Notification preferences
- [ ] Badge counts

### 4.4 Analytics & Reporting (Month 4)

**Backend Tasks**
- [ ] Analytics service
- [ ] Delivery metrics
- [ ] Driver performance metrics
- [ ] Revenue analytics
- [ ] Admin dashboard data

**Frontend Tasks**
- [ ] Admin analytics dashboard
- [ ] Charts and graphs
- [ ] Export functionality
- [ ] Date range filters

---

## Technical Architecture

### Backend Architecture

```
backend/src/
├── auth/              # Authentication & Authorization
│   ├── guards/        # JWT, Roles, Verified Driver
│   ├── strategies/    # Passport JWT strategy
│   └── dto/          # Login, Register DTOs
├── users/             # User management
├── drivers/           # Driver profiles
├── documents/         # Document upload & verification
├── deliveries/        # Delivery management
│   └── delivery-matching.service.ts
├── motorcycles/       # Motorcycle CRUD
├── admin/            # Admin operations
├── websocket/        # Real-time communication
│   └── delivery.gateway.ts
├── core/             # Shared utilities
└── config/           # Configuration
```

### Frontend Architecture

```
frontend/lib/
├── config/           # App configuration
├── core/             # Core utilities
│   ├── constants/
│   ├── errors/
│   └── utils/
├── models/           # Data models
├── services/         # API services
├── features/         # Feature modules
│   ├── auth/
│   ├── delivery/
│   ├── driver/
│   └── motorcycles/
└── widgets/          # Reusable widgets
```

### Database Schema Relationships

```
User (1) ──< (1) Driver
User (1) ──< (*) Delivery
User (1) ──< (*) Document
Driver (1) ──< (1) Motorcycle
Driver (1) ──< (*) Delivery
Delivery (1) ──< (1) Motorcycle
```

### WebSocket Event Flow

```
Customer creates delivery
  └─> emitNewDelivery() → All drivers
      └─> Driver accepts
          └─> emitDeliveryAssigned() → Customer & Driver
              └─> Driver updates location
                  └─> emitLocationUpdate() → Delivery room
                      └─> Delivery status changes
                          └─> emitDeliveryStatusUpdate() → Customer & Driver
```

---

## Testing Strategy

### Backend Testing

**Unit Tests**
- Service methods
- Utility functions
- DTO validation
- Schema methods

**Integration Tests**
- API endpoints
- Database operations
- Authentication flows
- WebSocket connections

**E2E Tests**
- Complete user registration flow
- Complete delivery creation flow
- Driver assignment flow
- Document verification flow

### Frontend Testing

**Widget Tests**
- Individual widgets
- Form validation
- State management

**Integration Tests**
- Screen navigation
- API service calls
- State provider updates

**E2E Tests**
- Complete user journeys
- Cross-screen flows
- Real device testing

---

## Deployment Plan

### Development Environment
- Backend: `localhost:3003`
- Frontend: Flutter development build
- Database: Local MongoDB

### Staging Environment
- Backend: Deploy to staging server
- Frontend: Build APK/IPA for testing
- Database: Staging MongoDB instance
- File Storage: Staging S3 bucket

### Production Environment
- Backend: Production server (AWS/DigitalOcean)
- Frontend: App Store / Play Store
- Database: Production MongoDB (Atlas)
- File Storage: Production S3 bucket
- CDN: CloudFront for static assets
- Monitoring: Sentry, LogRocket

### CI/CD Pipeline
- GitHub Actions for backend tests
- GitHub Actions for frontend tests
- Automated deployment to staging
- Manual approval for production
- Database migration scripts
- Rollback procedures

---

## Risk Mitigation

### Technical Risks
1. **WebSocket Connection Issues**
   - Mitigation: Implement reconnection logic, fallback to polling
   
2. **File Storage Scalability**
   - Mitigation: Plan for cloud migration from day one

3. **Location Accuracy**
   - Mitigation: Use multiple location providers, validate coordinates

4. **Payment Processing**
   - Mitigation: Use established payment gateway, test thoroughly

### Business Risks
1. **Driver Verification Delays**
   - Mitigation: Automated checks where possible, clear SLA for manual review

2. **Low Driver Adoption**
   - Mitigation: Competitive pricing, driver incentives, marketing

3. **Legal Compliance**
   - Mitigation: Legal review, compliance checklist, regular audits

---

## Success Metrics

### Technical Metrics
- API response time < 200ms (p95)
- WebSocket connection success rate > 99%
- Uptime > 99.9%
- Zero critical security vulnerabilities

### Business Metrics
- Driver verification time < 24 hours
- Delivery assignment time < 5 minutes
- Customer satisfaction rating > 4.5/5
- Driver retention rate > 80%

---

## Timeline Summary

| Phase | Duration | Key Deliverables |
|-------|----------|------------------|
| **Phase 1** | Weeks 1-3 | Fix errors, file storage, verification workflow |
| **Phase 2** | Weeks 3-5 | WebSocket, real-time tracking, driver dashboard |
| **Phase 3** | Weeks 5-8 | Security, testing, optimization, documentation |
| **Phase 4** | Month 3-4 | Payments, ratings, notifications, analytics |

---

## Next Steps

1. **Immediate (This Week)**
   - Fix WebSocket compilation errors
   - Verify registration separation
   - Test both registration flows

2. **Short-term (Next 2 Weeks)**
   - Complete file storage implementation
   - Finish driver verification workflow
   - Enhance delivery matching with GPS

3. **Medium-term (Next Month)**
   - Complete WebSocket integration
   - Implement real-time tracking
   - Build driver dashboard

4. **Long-term (Months 2-4)**
   - Production hardening
   - Payment integration
   - Advanced features

---

## Appendix

### Dependencies to Install

**Backend**
```bash
npm install @nestjs/websockets socket.io
npm install --save-dev @types/socket.io
```

**Frontend**
```yaml
# pubspec.yaml
dependencies:
  socket_io_client: ^2.0.3+1
  google_maps_flutter: ^2.5.0
```

### Environment Variables

```env
# Backend .env
NODE_ENV=production
PORT=3003
MONGODB_URI=mongodb://...
JWT_SECRET=...
JWT_EXPIRES_IN=1h
FUEL_PRICE_PER_LITER=2.5
BASE_DELIVERY_FEE=5.0

# File Storage
STORAGE_TYPE=local  # or 's3', 'azure'
AWS_ACCESS_KEY_ID=...
AWS_SECRET_ACCESS_KEY=...
AWS_S3_BUCKET=...
AWS_REGION=...

# WebSocket
WS_PORT=3004  # Optional separate port
```

---

**Document Version**: 1.0  
**Last Updated**: 2024  
**Maintained By**: Development Team
