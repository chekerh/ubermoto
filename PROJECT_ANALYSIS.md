# 🏍️ UberMoto — Project Analysis & Fix Plan

> Generated: 3 March 2026

## Project Overview

UberMoto is a **motorcycle-based delivery/ride-hailing platform** with:
- **Backend**: NestJS + MongoDB (Mongoose) — 15 modules
- **Frontend**: Flutter with Riverpod state management + WebView "Stitch" UI screens
- **Real-time**: Socket.IO WebSocket gateway for live tracking

### Architecture

```
┌─────────────────────────────────────────────┐
│                Flutter App                   │
│  ┌─────────────┐  ┌──────────────────────┐  │
│  │ Riverpod    │  │  WebView Stitch      │  │
│  │ Providers   │  │  HTML Screens        │  │
│  │ + Services  │◄─┤  (JS Bridge)         │  │
│  └──────┬──────┘  └──────────────────────┘  │
│         │                                    │
│  ┌──────▼──────┐  ┌──────────────────────┐  │
│  │ API Service │  │  WebSocket Service   │  │
│  │ (HTTP)      │  │  (Socket.IO)         │  │
│  └──────┬──────┘  └──────────┬───────────┘  │
└─────────┼────────────────────┼───────────────┘
          │                    │
┌─────────▼────────────────────▼───────────────┐
│              NestJS Backend                   │
│  Auth │ Users │ Drivers │ Deliveries │ Orders │
│  Catalog │ Admin │ Documents │ Surge │ WS     │
│  ┌─────────────────────────────────────────┐ │
│  │              MongoDB                     │ │
│  └─────────────────────────────────────────┘ │
└───────────────────────────────────────────────┘
```

## User Roles & Flows

### 👤 Customer Flow
1. Splash → Login/Register as Customer
2. Customer Home → Browse catalog, view products
3. Add to cart → Checkout with promo codes
4. Confirm order → Creates order + delivery request
5. Live tracking → WebSocket real-time updates
6. Order confirmation / cancellation

### 🏍️ Driver Flow
1. Splash → Login/Register as Driver (requires phone + license)
2. Driver Dashboard → Toggle availability (go online)
3. Upload verification documents → Wait for admin approval
4. Receive new delivery notifications (WebSocket)
5. Accept delivery → Navigate to pickup
6. Start delivery → Navigate to drop-off
7. Complete delivery → Mark done, receive next

### 🔧 Admin Flow
1. Login as Admin
2. Dashboard → View stats
3. Verify/reject pending drivers
4. Review/approve documents
5. Manage catalog, analytics

---

## 🔴 Critical Issues Found & Fixed

| # | Issue | Impact | Fix |
|---|---|---|---|
| 1 | WebSocket event name mismatch (frontend snake_case vs backend camelCase) | All real-time features broken | Fixed frontend to use camelCase |
| 2 | DriversService calls `/drivers/me` — endpoint doesn't exist | Driver profile always fails | Changed to use `/drivers/user/:userId` pattern |
| 3 | DeliveryService expects `{data: [...]}` but backend returns raw array | Deliveries always empty | Fixed response parsing |
| 4 | DeliveryService uses POST for status update, backend expects PATCH | Status updates fail | Changed to PATCH |
| 5 | No delivery status state machine — any transition allowed | Illogical state jumps | Added status transition validation |
| 6 | Admin verifyDriver uses userId as driverId | Wrong document updated | Fixed to find Driver by userId first |
| 7 | completeDelivery double-sets COMPLETED status | Redundant DB writes | Removed duplicate status set |
| 8 | Order deliveryFee always 0 | Revenue loss | Added basic delivery fee calculation |
| 9 | No driver dashboard Stitch bindings | Driver screen is non-functional | Added full driver JS bindings |
| 10 | DriverAvailabilityNotifier stubbed (TODO) | Drivers can't go online | Connected to real API |
| 11 | No delivery cancellation endpoint | Customers can't cancel | Added cancel endpoint |
| 12 | No connection between Orders and Deliveries | Orders don't get delivered | Auto-create delivery on order |
| 13 | getPendingDrivers uses non-existent virtual populate | Returns undefined | Fixed to use proper query |
| 14 | Debug endpoint exposes all users | Security vulnerability | Added ADMIN role guard |
| 15 | console.log pollution throughout backend | Not production-ready | Cleaned up debug logs |
| 16 | User ID vs Driver ID mismatch in accept/start/complete | Driver actions always fail | Added userId→driverId resolution |
| 17 | Soft delete doesn't prevent login | Deleted users can still log in | Now invalidates password |
| 18 | Delivery cancellation auth check fails for drivers | Driver ID comparison broken | Fixed to resolve userId→driverId |

---

## Database Entities

```
User (email, password, name, role, isVerified, phoneNumber, preferences)
  │
  ├── 1:1 → Driver (userId, licenseNumber, phoneNumber, motorcycleId, isAvailable, rating)
  ├── 1:N → Address (userId, label, street, city, coordinates)
  ├── 1:N → Document (userId, type, fileUrl, status)
  ├── 1:N → Order (userId, items[], subtotal, deliveryFee, total, status)
  │
  └── 1:N → Delivery (userId, driverId, motorcycleId, pickupLocation, 
                        deliveryAddress, status, estimatedCost, orderId)

Motorcycle (brand, model, year, fuelConsumption, maxLoad, type)
Category (name, description, icon)
Product (name, price, description, categoryId, merchantId, images)
Merchant (name, address, phone, categories)
SurgeRule (name, region, dayOfWeek, startHour, endHour, multiplier)
```

## API Endpoints Summary

| Module | Endpoints | Auth |
|---|---|---|
| Auth | POST register/customer, register/driver, login | Public |
| Users | GET/PATCH me, password, preferences, addresses | JWT |
| Drivers | CRUD + availability, documents, verification | JWT + Roles |
| Deliveries | Create, accept, start, complete, cancel, calculate-cost | JWT + Roles |
| Orders | Create, list, get, update status | JWT + Roles |
| Catalog | Categories, products, search | Public |
| Admin | Dashboard, verify drivers, documents, stats | JWT + Admin |
| Documents | Upload, list, status updates | JWT + Roles |
| WebSocket | Subscribe, location updates, status events | JWT |
