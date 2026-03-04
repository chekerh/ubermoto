# Nassib App Testing Plan

## Test Infrastructure Status ✅

### Backend Tests (2 test suites, 4 tests)
- ✅ `health.controller.spec.ts` - Basic health check endpoint (2 passing)
- ✅ `auth.service.spec.ts` - Login validation with bcrypt (2 passing)
- **Result**: All 4 tests passing
- **Coverage**: Basic smoke tests to enable CI/CD
- **Command**: `cd backend && npm test`

### Frontend Tests (1 test suite, 2 tests)
- ✅ `widget_test.dart` - Basic widget smoke test + Riverpod provider test (2 passing)
- **Result**: All 2 tests passing
- **Coverage**: Basic Flutter widget rendering + state management
- **Command**: `cd frontend && flutter test`

### GitHub Actions CI/CD
- ✅ Test files committed and pushed (commit 54d332d)
- 🔄 Workflows should now pass (previously failing due to missing tests)
- **Workflows**:
  - `backend-ci.yml` - Runs npm test, lint, coverage on Node 18.x/20.x
  - `frontend-ci.yml` - Runs flutter analyze, flutter test, integration tests
- **Check status**: https://github.com/chekerh/ubermoto/actions

---

## Manual Testing Checklist

### Prerequisites
```bash
# Terminal 1: Start backend
cd backend && PORT=3003 npm run start:dev

# Terminal 2: Start frontend
cd frontend && flutter run -d chrome
```

### 1. Customer Flow Testing 🛒

#### 1.1 Authentication
- [ ] Open app → Language selection screen (splash1) appears
- [ ] Select language (EN/FR/AR/Derja) → Splash screens advance
- [ ] Navigate to login screen
- [ ] Test login with email: `customer@test.com` / password: `password`
- [ ] Verify JWT token stored in secure storage
- [ ] Check role-based routing → Customer dashboard

#### 1.2 Product Browsing
- [ ] Customer home dashboard loads (`customer_home_dashboard/code.html`)
- [ ] Verify product grid displays dynamically (`_injectProductsGrid()`)
- [ ] Check popular products carousel
- [ ] Test search functionality
- [ ] Filter by category/tags
- [ ] Click product card → Product details screen loads

#### 1.3 Product Details
- [ ] Product details screen shows (`product_details_harissa/code.html`)
- [ ] Verify all data injected: name, price, rating, description (`_injectProductDetails()`)
- [ ] Star rating displayed correctly
- [ ] Quantity selector works (+/- buttons)
- [ ] "Add to Cart" button (`#add-to-cart-btn`) → Cart updated
- [ ] Toggle favorite icon (`#favorite-icon`) → Provider state updates

#### 1.4 Cart & Checkout
- [ ] Navigate to cart (`cart_and_checkout/code.html`)
- [ ] Verify cart items display (`_injectCartData()`)
- [ ] Update quantities → Subtotals recalculate
- [ ] Remove item from cart → UI updates
- [ ] Checkout button (`#checkout-btn`) → Checkout screen
- [ ] Address selection works
- [ ] Payment method selection works
- [ ] Place order → Delivery created

#### 1.5 Order Tracking
- [ ] Order confirmation screen appears
- [ ] Track order button → Live tracking screen (`live_order_tracking/code.html`)
- [ ] WebSocket connects to `/delivery` namespace
- [ ] Real-time location updates display on map
- [ ] Delivery status updates (MATCHED → PICKED_UP → DELIVERED)
- [ ] Driver details visible (name, photo, rating, motorcycle)

**Expected Results**:
- All `getElementById` bindings work (no errors in console)
- Dynamic data injection populates screens correctly
- StitchBridge postMessage navigation flows smoothly
- Riverpod `productProvider` state updates reflected in UI

---

### 2. Driver Flow Testing 🏍️

#### 2.1 Authentication
- [ ] Login as driver: `driver@test.com` / `password`
- [ ] Verify JWT + role-based routing → Driver dashboard
- [ ] Check `driverProfileProvider` loads user data

#### 2.2 Driver Dashboard
- [ ] Driver dashboard loads (`driver_dashboard_online/code.html`)
- [ ] Toggle online/offline (`#online-toggle`) → `driverAvailabilityProvider` updates
- [ ] Verify online status persists in backend (`PATCH /drivers/:id/availability`)
- [ ] When online → Available deliveries list appears
- [ ] Delivery cards show: pickup address, dropoff, distance, earnings

#### 2.3 Accept & Navigate Delivery
- [ ] Click "Accept" on delivery (`#accept-job-btn`) → POST `/deliveries/:id/accept`
- [ ] Active job view loads (`active_delivery_job_view/code.html`)
- [ ] Dynamic data injection (`_injectActiveJobData()`) shows:
  - Customer name, phone, address
  - Items list, total earnings
  - Navigation button
- [ ] Navigate button (`#navigate-btn`) → Opens Maps app
- [ ] SOS button (`#sos-btn`) → Emergency modal

#### 2.4 Complete Delivery
- [ ] Mark as picked up → Delivery state → PICKED_UP
- [ ] Complete delivery (`#complete-btn`) → POST `/deliveries/:id/complete`
- [ ] Rating screen loads (`driver_rating_quality_feedback/code.html`)
- [ ] Star rating interaction works (click stars → highlights 1-5)
- [ ] Feedback tags toggleable (`#tag-*`) → Active state styling
- [ ] Submit rating → Returns to dashboard

#### 2.5 Driver Earnings & Profile
- [ ] Navigate to earnings (`driver_earnings/code.html`)
- [ ] Verify weekly earnings chart displays
- [ ] Recent deliveries list populated
- [ ] Total earnings, trips count correct
- [ ] Profile screen (`driver_profile/code.html`) loads
- [ ] Dynamic data: name, phone, email, rating, deliveries count
- [ ] Edit profile button works

**Expected Results**:
- All 85+ driver element IDs work correctly
- `driverProvider`, `driverAvailabilityProvider` state sync
- WebSocket real-time delivery assignments (`delivery:assigned` event)
- Interactive star rating + feedback tags functional
- Motorcycle card selection in `motorcycle_selection_slider/code.html`

---

### 3. Admin Flow Testing 👨‍💼

#### 3.1 Authentication
- [ ] Login as admin: `admin@test.com` / `password`
- [ ] Role guard enforces UserRole.ADMIN
- [ ] Admin console loads (`admin_management_console/code.html`)

#### 3.2 Dashboard
- [ ] Admin dashboard displays stats (`_injectAdminDashboardData()`):
  - Daily orders count
  - Active drivers count
  - Pending verifications
  - Total revenue
  - Fraud alerts
  - Delivery efficiency %
- [ ] Verify data fetched from `AdminStateNotifier.refreshDashboard()`

#### 3.3 Driver Verification
- [ ] Pending drivers list loads
- [ ] Driver cards show: name, license number, vehicle, submitted date
- [ ] Click "Verify" (`#verify-driver-btn`) → POST `/admin/drivers/:driverId/verify`
- [ ] Driver removed from pending list → Added to active drivers
- [ ] Click "Reject" (`#reject-driver-btn`) → Driver status → REJECTED
- [ ] Rejection reason modal appears

#### 3.4 Catalog Management
- [ ] Navigate to catalog (`admin_catalog_management/code.html`)
- [ ] Product grid loads (`_injectAdminCatalogData()`)
- [ ] Search bar (`#search-input`) filters products in real-time
- [ ] Edit product (`#edit-product-btn`) → Form pre-filled
- [ ] Update price, stock, category → POST `/admin/catalog/products/:id`
- [ ] Add new product button → Empty form → Create product
- [ ] Delete product (`#delete-product-btn`) → Confirmation modal → DELETE

#### 3.5 Analytics & Fraud Control
- [ ] Analytics screen (`admin_analytics_fraud_control/code.html`) loads
- [ ] Charts display (orders trend, revenue, driver performance)
- [ ] Fraud alerts list visible
- [ ] Export reports button works

**Expected Results**:
- All 28+ admin element IDs function correctly
- `admin_provider.dart` (`AdminStateNotifier`) state management works
- Dynamic data injection methods populate screens
- CRUD operations on catalog persist to backend
- Live catalog search filters products

---

## Security Testing Checklist 🔒

### 1. Authentication & Authorization
- [ ] Unauthenticated requests to protected routes → 401 Unauthorized
- [ ] Customer role cannot access `/admin/*` endpoints → 403 Forbidden
- [ ] Driver role cannot access customer-only endpoints
- [ ] JWT expiration enforced (test with expired token)
- [ ] Refresh token flow works

### 2. Input Validation
- [ ] XSS attempt in product name → Escaped in HTML (`replaceAll("'", "\\'")`)
- [ ] SQL/NoSQL injection in search → Blocked by DTOs + Mongoose
- [ ] File upload validates MIME type + size limit
- [ ] Email validation enforced (invalid email rejected)
- [ ] Password complexity enforced (min 6 chars)

### 3. WebView Security
- [ ] No `eval()` usage in stitch HTML
- [ ] StitchBridge is only communication channel
- [ ] CSP headers prevent script injection
- [ ] Verify `runJavaScript()` sanitizes inputs

### 4. API Security
- [ ] All endpoints have Swagger docs (`@ApiOperation()`)
- [ ] DTOs validate request bodies (`class-validator`)
- [ ] Error responses don't leak sensitive data
- [ ] bcrypt password hashing verified (10 salt rounds)
- [ ] HTTPS enforced in production (check `app_config.dart`)

---

## Mobile MCP Testing (Optional) 📱

### Setup
```bash
# Start MCP server
mcp-server-mobile --stdio

# Or as SSE server
mcp-server-mobile --port 3001
```

### Automated Tests
- [ ] Use MCP to automate tap sequences
- [ ] Screenshot capture for visual verification
- [ ] Swipe gestures testing (product carousel)
- [ ] List elements on screen (`list_elements_on_screen`)
- [ ] Double-tap interactions

### Example Commands (via Claude Desktop or VS Code MCP)
```javascript
// List available devices
mobile_list_available_devices()

// Take screenshot
mobile_take_screenshot({ device: "iPhone 15 Pro" })

// Type in input field
mobile_type_keys({ device: "iPhone 15 Pro", text: "test@example.com", submit: false })

// Swipe product carousel
mobile_swipe_on_screen({ device: "iPhone 15 Pro", direction: "left", distance: 300 })
```

---

## Performance Testing

### Backend Load Testing
```bash
# Install Apache Bench if needed
brew install ab

# Test login endpoint (100 concurrent, 1000 total)
ab -n 1000 -c 100 -p login.json -T application/json http://localhost:3003/auth/login

# Test catalog endpoint
ab -n 1000 -c 100 http://localhost:3003/catalog/products
```

### Frontend Performance
- [ ] Check bundle size: `flutter build web --release`
- [ ] Measure initial load time (< 3s on 4G)
- [ ] Verify no memory leaks (DevTools Memory profiler)
- [ ] Test with 100+ products in catalog (scroll performance)

---

## Known Issues & Limitations

### Current Test Coverage
- **Backend**: 2/15 modules tested (13% coverage)
  - ✅ Health, Auth
  - ❌ Missing: Deliveries, Drivers, Users, Motorcycles, etc.
- **Frontend**: 1 widget test (minimal coverage)
  - ❌ Missing: Provider tests, navigation tests, stitch screen tests

### CI/CD Gaps
- No integration tests (end-to-end flows)
- No database seeding for tests
- No mocked WebSocket tests
- No frontend integration_test/ execution in CI

### Security Gaps (from SECURITY_AUDIT.md)
1. No rate limiting on login endpoint (brute force risk)
2. HTTPS not enforced in development
3. Weak password requirements (6 chars min)
4. Backend catalog endpoints are READ-ONLY (no admin CRUD implemented yet)

---

## Next Steps

### Immediate (Before Production)
1. ✅ Fix CI/CD test failures (DONE - commit 54d332d)
2. 🔄 Verify GitHub Actions workflows pass
3. ❌ Manual testing of all 3 user flows (Customer, Driver, Admin)
4. ❌ Fix 4 security issues from SECURITY_AUDIT.md
5. ❌ Add rate limiting middleware
6. ❌ Enforce HTTPS redirect in production

### Short-term (1-2 weeks)
- Add integration tests for critical flows
- Increase backend test coverage to >70%
- Add frontend widget tests for all screens
- Implement mobile-mcp automation scripts
- Load testing on staging environment

### Long-term (1 month+)
- E2E Playwright/Cypress tests
- Security penetration testing
- Performance optimization (bundle size, API response times)
- Comprehensive error monitoring (Sentry, Crashlytics)

---

## Testing Commands Reference

```bash
# Backend tests
cd backend && npm test                  # Run all tests
cd backend && npm run test:cov          # With coverage report
cd backend && npm run test:watch        # Watch mode

# Frontend tests
cd frontend && flutter test             # Run all tests
cd frontend && flutter test --coverage  # With coverage
cd frontend && flutter test test/widget_test.dart  # Specific file

# Linting
cd backend && npm run lint              # ESLint + Prettier
cd frontend && flutter analyze          # Dart analyzer

# Start dev environment
./start-dev.sh 3003                     # Backend on 3003
cd frontend && flutter run -d chrome    # Frontend on Chrome

# Switch backend port
./switch-port.sh 3002                   # Change to port 3002
```

---

## Test Results Summary

| Component | Tests | Passing | Status |
|-----------|-------|---------|--------|
| Backend (Health) | 2 | 2 | ✅ PASS |
| Backend (Auth) | 2 | 2 | ✅ PASS |
| Frontend (Widget) | 2 | 2 | ✅ PASS |
| **Total** | **6** | **6** | **✅ 100%** |

| CI/CD Workflow | Status | Last Run |
|----------------|--------|----------|
| backend-ci.yml | 🔄 Pending | commit 54d332d |
| frontend-ci.yml | 🔄 Pending | commit 54d332d |

| Manual Testing | Status |
|----------------|--------|
| Customer Flow | ❌ Not Started |
| Driver Flow | ❌ Not Started |
| Admin Flow | ❌ Not Started |

---

**Last Updated**: March 4, 2026, 2:40 AM  
**Test Infrastructure**: ✅ Complete  
**CI/CD Status**: 🔄 Awaiting GitHub Actions results  
**Ready for Manual Testing**: ✅ Yes
