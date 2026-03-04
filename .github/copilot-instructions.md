# Nassib AI Agent Instructions

## Project Overview
Nassib is a motorcycle delivery platform with **three user types** (Customer, Driver, Admin). The unique architecture uses a **Stitch HTML-in-WebView system** for Flutter UI, where screens are HTML files with JavaScript-to-Dart bridge communication.

### Monorepo Structure
```
ubermoto/              # Root — docs, scripts, .gitignore only (NO backend code here)
├── backend/           # NestJS API (TypeScript) — all backend code lives here
├── frontend/          # Flutter app (Dart) — all frontend code lives here
│   └── stitch/        # 30 HTML screen files loaded as Flutter assets
├── scripts/           # Deployment & CI helper scripts
├── start-dev.sh       # Starts backend + frontend together
├── run-tests.sh       # Runs both test suites
└── switch-port.sh     # Changes backend port (3001-3004)
```
> ⚠️ **All backend code must be inside `backend/`.** Never create NestJS files, `package.json`, `tsconfig.json`, or `src/` at the repo root.

## Critical Architecture Patterns

### The Stitch Architecture (UNIQUE TO THIS PROJECT)
- **Frontend UI = 31 HTML screens** in `frontend/stitch/**/code.html` loaded into Flutter WebView
- **JavaScript Bridge**: HTML uses `window.StitchBridge.postMessage(JSON.stringify({ action: 'navigate_home', payload: {...} }))` to communicate with Dart
- **Dart Bridge Handler**: `stitch_viewer.dart` listens via `JavascriptChannel('StitchBridge')` and calls `_handleBridgeMessage()`
- **Element Binding**: **ALL interactive elements MUST have IDs** — use `document.getElementById()` only (text/icon matching removed Mar 2026)
- **Dynamic Data**: Injection methods (`_inject*Data()`) populate screens with real-time data from Riverpod providers
- **Adding a new screen**:
  1. Create `frontend/stitch/my_new_screen/code.html` with element IDs and StitchBridge postMessage calls
  2. Add route to `frontend/lib/main.dart` in `stitchScreens` map
  3. Add injection method in `stitch_viewer.dart`: `_injectMyNewScreenBindings()` using `getElementById`
  4. Add case in `_installRouteBindings()` switch statement
  5. Add action handlers in `_handleBridgeMessage()` switch
  6. Add dynamic data injection method if needed: `_injectMyNewScreenData()`

### Navigation Between Screens
- **DO**: Use `window.StitchBridge.postMessage(JSON.stringify({ action: 'navigate_to_home' }))`
- **DON'T**: Use Flutter Navigator directly from HTML
- **Pattern**: Every button needs a binding like `stitchBind('#login-btn', 'submit_login')`
- See `STITCH_SCREEN_PLAN.md` for complete navigation graph

### Multi-Language Support (4 Languages)
- **Languages**: English (default), French, Arabic, Tunisian Derja (with RTL for AR/Derja)
- **Translation system**: `language_provider.dart` manages state; `_injectTranslations()` in stitch_viewer translates text nodes
- **Add translations**: Update `uiTranslations` map in `language_provider.dart` with FR/AR/Derja keys
- Language selected on splash screen → stored in Riverpod `languageProvider`

## Backend (NestJS + MongoDB)

### Key Services & Their Roles
- **deliveries.service.ts**: Cost calculation via fuel consumption, delivery lifecycle, WebSocket notifications
- **delivery-matching.service.ts**: Auto-matches deliveries to available drivers based on proximity
- **surge.service.ts**: Dynamic pricing multipliers based on time/region
- **websocket/delivery.gateway.ts**: Socket.IO on `/delivery` namespace emits `delivery:assigned`, `delivery:updated`, `location:updated`

### Authentication Pattern
```typescript
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.DRIVER)  // Or CUSTOMER, ADMIN
```
- JWT in `Authorization: Bearer <token>` header
- Three roles enforced via decorator chain

### Database Schemas
- **User** → referenced by Driver (via `userId`), Delivery (via `customerId`)
- **Driver** → references User AND Motorcycle, has `isAvailable`, `currentLocation`, `verificationStatus`
- **Delivery** → references User (customer), Driver, Motorcycle; state machine: PENDING → MATCHED → PICKED_UP → DELIVERED → COMPLETED

## Development Commands

### Start Everything
```bash
./start-dev.sh 3003  # Backend on port 3003
# Then in another terminal:
cd frontend && flutter run -d chrome
```

### Backend Only
```bash
cd backend
npm run start:dev  # Auto-reload on port from .env or PORT env var
```

### Frontend Only
```bash
cd frontend
flutter pub get
flutter run -d chrome  # Or -d macos, -d web-server --web-port=8080
```

### Port Management
- Backend supports ports 3001-3004 via `./switch-port.sh 3002`
- Update `frontend/lib/config/app_config.dart` → `backendPort` to match

### Testing
```bash
cd backend && npm test          # Backend unit tests
cd frontend && flutter test     # Frontend tests
./run-tests.sh                  # Both (89% backend, 87% frontend coverage)
```

### Lint & Analysis
```bash
cd frontend && flutter analyze  # Static analysis (zero errors enforced)
cd backend && npm run lint      # ESLint + Prettier
```

**Current Status**: ✅ Zero compilation errors, 15 warnings (unused imports only — safe to ignore)

## Common Tasks

### Add a New Stitch Screen
1. Copy existing screen structure from `frontend/stitch/customer_home_dashboard/`
2. Create `code.html` with StitchBridge postMessage for all buttons
3. Register in `main.dart` → `stitchScreens['/my/route'] = StitchViewer(...)`
4. Add `_injectMyRouteBindings()` in stitch_viewer.dart using helper `stitchBind(selector, action)`
5. Handle action in `_handleBridgeMessage()` switch
6. Document in `STITCH_SCREEN_PLAN.md`

### Add a Backend Endpoint
- Follow existing controller patterns in `backend/src/{module}/{module}.controller.ts`
- Use DTOs with `class-validator` decorators
- Inject services via constructor DI
- Add `@ApiOperation()` Swagger docs
- See Postman collection: `backend/Nassib_API.postman_collection.json`

### WebSocket Real-Time Updates
- Client connects to `http://localhost:3003/delivery` namespace
- Emit from backend: `this.deliveryGateway.server.to(roomId).emit('delivery:updated', data)`
- Listen in Flutter: `websocket_service.dart` → `_socket.on('delivery:updated', callback)`

## Project-Specific Conventions

- **State Management**: Riverpod providers in `frontend/lib/features/{feature}/providers/`
  - `product_provider.dart` — Customer catalog, cart, favorites
  - `driver_provider.dart` — Driver profile, availability, deliveries
  - `admin_provider.dart` — Dashboard stats, driver verification, catalog CRUD
  - `auth_provider.dart` — JWT auth state, login/register
  - `language_provider.dart` — 4-language support (EN/FR/AR/Derja)
- **Error Handling**: Backend uses `AllExceptionsFilter`; frontend shows SnackBar via `_showSnackbar()`
- **File Naming**: Backend = `kebab-case.ts`, Frontend Dart = `snake_case.dart`, Stitch = `code.html`
- **API Responses**: Always `{ success: boolean, data?: any, message?: string }`
- **Driver Actions**: Must check `isAvailable` state before accepting deliveries
- **Security First**: All user input escaped, DTOs validated, JWT enforced, role-based access control

## Key Files to Reference

- `STITCH_SCREEN_PLAN.md` — Every screen, every button, every destination
- `PROJECT_ANALYSIS.md` — Architecture overview, 18 bugs fixed
- `frontend/lib/stitch/stitch_viewer.dart` — Complete bridge implementation (~1500 lines)
- `backend/src/deliveries/deliveries.service.ts` — Core business logic
- `backend/Nassib_API.postman_collection.json` — All API endpoints with examples

## What NOT to Do

- ❌ Don't use Flutter Navigator.push() for stitch screens → use StitchBridge.postMessage
- ❌ Don't create duplicate routes for login/register (login2, register2 already exist as fallbacks)
- ❌ Don't modify HTML screens without adding corresponding bindings in stitch_viewer.dart
- ❌ Don't forget to update STITCH_SCREEN_PLAN.md when adding navigation paths
- ❌ Don't add `nextRoute` to non-splash screens (only works on splash1-4 via double-tap)
- ❌ Don't break delivery state machine: PENDING→MATCHED→PICKED_UP→DELIVERED→COMPLETED is enforced
- ❌ Don't create backend files (`package.json`, `tsconfig.json`, `src/`, `nest-cli.json`) at the repo root — all backend code belongs in `backend/`
- ❌ Don't create a duplicate `stitch/` folder at root — stitch HTML lives only in `frontend/stitch/`

## State Management Providers

### Customer State (`product_provider.dart`)
- **Product** model (id, name, price, imageUrl, rating, tags, description)
- **CartItem** model (product, quantity, subtotal)
- **ProductCatalogState** with products, cart, selectedProduct, popularProducts, favorites
- **ProductCatalogNotifier** methods: addToCart(), updateCartQuantity(), toggleFavorite(), clearCart()

### Driver State (`driver_provider.dart`)
- **driverProfileProvider** — FutureProvider<UserModel>
- **driverAvailabilityProvider** — StateNotifier with toggleAvailability(), loadDriverProfile()
- **availableDeliveriesProvider**, **activeDeliveriesProvider** — FutureProviders

### Admin State (`admin_provider.dart`)
- **PendingDriver** model (id, name, licenseNumber, vehicleModel, submittedAgo, status)
- **AdminDashboardStats** model (dailyOrders, activeDrivers, pendingVerifications, totalRevenue, fraudAlerts, deliveryEfficiency)
- **AdminCatalogProduct** model (id, name, unit, category, stock, stockStatus, price)
- **AdminStateNotifier** methods: refreshDashboard(), verifyDriver(), rejectDriver(), addProduct(), updateProduct(), deleteProduct()

## Element Binding Pattern (CRITICAL)

**ALL stitch screens now use deterministic getElementById bindings:**

```javascript
// ✅ CORRECT: Use getElementById
stitchBind(document.getElementById('login-btn'), 'submit_login');

// ❌ WRONG: Don't use text/icon matching (removed March 2026)
stitchBind(stitchFindByText('button', ['login']), 'submit_login');
```

**Every interactive element in HTML must have an ID:**
- Customer screens: `home-*`, `product-*`, `cart-*`, `nav-*`
- Driver screens: `driver-*`, `job-*`, `docs-*`, `earnings-*`, `profile-*`, `sos-*`, `training-*`, `rating-*`, `moto-*`
- Admin screens: `admin-*`, `catalog-*`, `analytics-*`

**Dynamic data injection methods:**
- Customer: `_injectProductsGrid()`, `_injectProductDetails()`, `_injectCartData()`, `_injectCheckoutTotals()`
- Driver: `_injectDriverDashboardData()`, `_injectActiveJobData()`, `_injectDriverProfileData()`
- Admin: `_injectAdminDashboardData()`, `_injectAdminCatalogData()`, `_injectAdminAnalyticsData()`

## Security Best Practices

### Backend Security
- **JWT Authentication**: All protected routes use `@UseGuards(JwtAuthGuard, RolesGuard)`
- **Role-based Access Control**: `@Roles(UserRole.CUSTOMER | DRIVER | ADMIN)` enforced via decorators
- **Input Validation**: DTOs with `class-validator` decorators (`@IsString()`, `@IsEmail()`, `@IsNotEmpty()`)
- **Password Hashing**: bcrypt with 10 salt rounds in `auth.service.ts`
- **MongoDB Injection Prevention**: Mongoose schema validation + never trust raw query params
- **CORS**: Configured in `main.ts` to allow only frontend origin (port 8080/Chrome extension)
- **Rate Limiting**: Helmet middleware enabled for headers security
- **Environment Variables**: Sensitive data (`JWT_SECRET`, `MONGO_URI`) in `.env` — **NEVER commit .env**

### Frontend Security
- **XSS Prevention**: All user input escaped before injection into HTML (`replaceAll("'", "\\'")`)
- **No eval()**: WebView uses only `runJavaScript()` with sanitized strings, never `eval()`
- **Secure Storage**: Tokens stored via `flutter_secure_storage` (encrypted keychain/keystore)
- **HTTPS Only**: Production backend must use HTTPS (enforced in `app_config.dart`)
- **WebView CSP**: Content Security Policy headers to prevent script injection
- **Input Sanitization**: All form inputs validated client-side before sending to backend

### API Security Checklist
- ✅ All endpoints have `@ApiOperation()` Swagger docs
- ✅ DTOs validate all request bodies
- ✅ Responses never leak sensitive data (passwords, raw tokens, internal IDs)
- ✅ Delivery cost calculation server-side only (no client-side price manipulation)
- ✅ Driver location updates require authenticated WebSocket connection
- ✅ Admin endpoints check `UserRole.ADMIN` role
- ✅ File uploads validated (MIME type, size limit) in `documents.service.ts`

## Testing with Mobile MCP

**Tool Integration**: MCP server for mobile development and automation across iOS/Android.

### Installation (Global — Already Installed)
```bash
# Installed globally via npm
npm install -g @mobilenext/mobile-mcp@latest

# Verify installation
which mcp-server-mobile
# Output: /Users/mac/.nvm/versions/node/v20.20.0/bin/mcp-server-mobile
```

### Running the MCP Server
```bash
# Start in stdio mode (default for Claude Desktop/VS Code)
mcp-server-mobile --stdio

# Start as SSE server on port 3001
mcp-server-mobile --port 3001
```

### VS Code Integration
The server is MCP-compatible and can be used with:
- **Claude Desktop**: Add to `~/Library/Application Support/Claude/claude_desktop_config.json`
- **VS Code**: Install via [VS Code MCP extension](https://insiders.vscode.dev/redirect?url=vscode%3Amcp%2Finstall%3F%7B%22name%22%3A%22mobile-mcp%22%2C%22command%22%3A%22npx%22%2C%22args%22%3A%5B%22-y%22%2C%22%40mobilenext%2Fmobile-mcp%40latest%22%5D%7D)

### Usage with Nassib App
1. Start backend: `cd backend && npm run start:dev`
2. Start frontend: `cd frontend && flutter run -d chrome`
3. Start MCP server: `mcp-server-mobile --stdio`
4. Use MCP tools to interact with the running app (tap, swipe, accessibility snapshots)

### Test Coverage Requirements
- **Customer**: Login → Browse → Add to Cart → Checkout → Track Delivery
- **Driver**: Login → Go Online → Accept Delivery → Navigate → Complete → Rate
- **Admin**: Login → View Dashboard → Verify Driver → Manage Catalog → Analytics

## Recent Major Changes (Context for Debugging)

**Phase 1-4 (Jan-Feb 2026):**
- ✅ Stitch viewer completely rewritten with 30 screen bindings
- ✅ Language provider + translation injection system added
- ✅ All 7 unreachable routes fixed via text-matching bindings
- ✅ WebSocket event names standardized (`delivery:assigned`, `delivery:updated`, `location:updated`)
- ✅ Delivery-driver matching service fixed to use `userId` → `driverId` resolution
- ✅ Root-level stale backend duplicates removed (src/, dist/, node_modules/, config files, stitch/)
- ✅ Rebranding: UberMoto → Nassib across all 29 HTML screens, Dart files, backend

**Phase 5 (Mar 4, 2026 — Latest):**
- ✅ **Driver Side Complete**: 85+ element IDs added to 7 driver screens
- ✅ **New Screens**: `driver_earnings/code.html`, `driver_profile/code.html` created (~400 lines)
- ✅ **Admin Side Complete**: 28+ element IDs added to 3 admin screens
- ✅ **Admin State**: `admin_provider.dart` created (~290 lines) with dashboard stats, driver verification, catalog CRUD
- ✅ **Binding Migration**: All 11 driver+admin bindings rewritten from `stitchFindByText/Icon` → `getElementById`
- ✅ **Dynamic Injection**: 6 new methods inject real-time data into driver/admin screens
- ✅ **Interactive Features**: Star rating system, toggleable feedback tags, live catalog search, motorcycle card selection
- ✅ **Bridge Actions**: Added `admin_reject_driver`, `admin_add/edit/delete_product`
- ✅ **Security**: XSS prevention via string escaping in all dynamic injections
- ✅ **Zero Errors**: Flutter analyze shows 0 errors, 15 warnings (unused imports only)
