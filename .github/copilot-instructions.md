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
- **Frontend UI = 30 HTML screens** in `frontend/stitch/**/code.html` loaded into Flutter WebView
- **JavaScript Bridge**: HTML uses `window.StitchBridge.postMessage(JSON.stringify({ action: 'navigate_home', payload: {...} }))` to communicate with Dart
- **Dart Bridge Handler**: `stitch_viewer.dart` listens via `JavascriptChannel('StitchBridge')` and calls `_handleBridgeMessage()`
- **Adding a new screen**:
  1. Create `frontend/stitch/my_new_screen/code.html` with StitchBridge postMessage calls
  2. Add route to `frontend/lib/main.dart` in `stitchScreens` map
  3. Add injection method in `stitch_viewer.dart`: `_injectMyNewScreenBindings()`
  4. Add case in `_installRouteBindings()` switch statement
  5. Add action handlers in `_handleBridgeMessage()` switch

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
- **Error Handling**: Backend uses `AllExceptionsFilter`; frontend shows SnackBar via `_showSnackbar()`
- **File Naming**: Backend = `kebab-case.ts`, Frontend Dart = `snake_case.dart`, Stitch = `code.html`
- **API Responses**: Always `{ success: boolean, data?: any, message?: string }`
- **Driver Actions**: Must check `isAvailable` state before accepting deliveries

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

## Recent Major Changes (Context for Debugging)

- ✅ Stitch viewer completely rewritten with 30 screen bindings (Mar 2026)
- ✅ Language provider + translation injection system added
- ✅ All 7 unreachable routes fixed via text-matching bindings
- ✅ WebSocket event names standardized (`delivery:assigned`, `delivery:updated`, `location:updated`)
- ✅ Delivery-driver matching service fixed to use `userId` → `driverId` resolution
- ✅ Root-level stale backend duplicates removed (src/, dist/, node_modules/, config files, stitch/)
