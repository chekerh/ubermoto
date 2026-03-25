## Actions log — Product build

This folder (`/product-workspace`) is the source of truth for building **UberMoto (Tunisia)** into a **production-grade paid product**.

### 2026-03-25

- Created `/product-workspace/` and began documentation-first planning.
- Confirmed existing stack: **NestJS + MongoDB (backend)**, **Flutter (frontend)**, **Socket.IO** realtime, multi-role auth (**CUSTOMER/DRIVER/ADMIN**).
- Confirmed current repo has no billing/subscription implementation yet; this workspace defines how we will add it safely.

### Decisions (so far)

- **Business model**: B2B + B2C marketplace; **customers** can use the app free; **merchants** pay subscription for growth + ops tools; **drivers** may have optional paid “Pro” features later.
- **Billing provider**: Stripe (Subscriptions + Customer Portal + Webhooks). If Stripe is not viable in Tunisia deployment context, plan includes a provider-abstraction seam.
- **Dynamic content**: Pricing table, announcements, FAQs/help, surge rules, promo campaigns, and selected ops settings are admin-editable (audited).

### Open items

- Confirm whether UberMoto targets **multi-merchant** from day one (affects admin UX and catalog/product ownership).
- Choose production hosting defaults (Fly.io/Render/AWS) and managed Mongo (Atlas) vs self-hosted.

### 2026-03-25 — Implementation progress beyond planning

- Added backend **billing foundation** with Stripe webhook route:
  - raw-body signature verification in `main.ts`
  - idempotent webhook event storage (`StripeWebhookEvent`)
- Added subscription system schemas:
  - `Plan`, `Subscription`, `Entitlement`, `MerchantMember`
- Added billing APIs:
  - `GET /billing/plans`
  - `POST /billing/admin/plans/upsert`
  - `POST /billing/merchant/checkout-session`
  - `POST /billing/merchant/portal-session`
  - `POST /billing/admin/merchant-membership`
  - `GET /billing/me/entitlements`
- Updated `GET /users/me/entitlements` to return computed data from billing service instead of static placeholder.
- Added `seed:plans` script with `merchant_basic` and `merchant_pro` defaults for fast staging/dev setup.
- Introduced `UserRole.MERCHANT` and merchant onboarding:
  - `POST /auth/register/merchant` creates merchant owner user + Merchant + MerchantMember
- Enforced paid entitlements server-side for merchant catalog writes:
  - `@RequireFeature('merchant.catalog.write')` + `FeatureGuard` on catalog product CRUD
- Added merchant ownership enforcement in `CatalogService`:
  - merchant users can only create against merchants they belong to
  - merchant users cannot transfer product ownership on update
  - merchant users can update/delete only products under their merchant membership
- Added merchant self-service billing endpoints:
  - `POST /billing/merchant/me/checkout-session`
  - `POST /billing/merchant/me/portal-session`
  (derive merchant context from active membership)
- Added merchant billing summary endpoint:
  - `GET /billing/merchant/me/summary` (merchant profile + membership + subscription + entitlements)
- Added frontend consumption scaffolding:
  - `ContentService` (`/content/:key`)
  - `MerchantBillingProvider` (plans + current entitlements)
  - `AnnouncementProvider` for admin-managed `home_announcement_banner`
- Added content listing/admin management support:
  - `GET /content` (published keys)
  - `GET /admin/content` (admin listing)
- Added `seed:content` script to bootstrap:
  - `pricing_table`
  - `home_announcement_banner`
  - `feature_flags`
- Added `PricingContentProvider` for dynamic pricing card consumption in frontend.
- Added multi-merchant billing readiness:
  - `GET /billing/me/memberships`
  - frontend merchant billing state now tracks memberships + selected merchant
  - entitlements now request `/billing/me/entitlements` with optional `merchantId`
- Fixed merchant summary scoping mismatch for multi-merchant users:
  - `GET /billing/merchant/me/summary` now accepts optional `merchantId`
  - frontend merchant selection now refreshes both entitlements and merchant summary for selected merchant
- Added server-side paid limit enforcement:
  - merchant product create now enforces `merchant.products.max` from entitlements
  - added catalog unit test coverage for limit breach behavior
- Added dynamic content module in backend:
  - `GET /content/:key` (public published content)
  - `GET/PUT /admin/content/:key` (admin view + upsert/publish)
  - wired audit actions: `CONTENT_UPSERT`, `CONTENT_PUBLISH`
- Added schema-aware validation for dynamic content keys:
  - `pricing_table` (`plans[]` with required fields)
  - `home_announcement_banner` (`message`, optional `enabled`)
  - `feature_flags` (`flags` object with boolean values)
- Frontend entitlement plumbing:
  - `EntitlementsService`
  - Riverpod `entitlementsProvider`
  - refresh entitlements automatically after successful auth profile refresh
- Frontend billing plumbing:
  - `BillingService` methods for plans, checkout session URL, and billing portal URL
- Validation:
  - backend tests: **111 passed**
  - backend build: **pass**
  - flutter tests: previously pass during this build cycle; entitlement additions compile clean

### 2026-03-25 (continued)

- **FeatureGuard**: `ADMIN` bypasses merchant feature checks (admin catalog was incorrectly blocked); `merchantId` resolved from **query or body** for entitlement checks (PATCH/DELETE catalog with `?merchantId=`).
- **Billing**: `GET /billing/merchant/me/usage` returns product count vs `merchant.products.max` for upgrade UX; optional `merchantId` on `POST /billing/merchant/me/checkout-session` and `POST /billing/merchant/me/portal-session` for multi-merchant users.
- **Frontend**: `BillingService.getMerchantUsageForMe`; `MerchantBillingState.merchantUsage` loaded on billing refresh / merchant switch.
- **Docs**: `API_SPEC.md` billing section aligned with implemented routes (portal-session POST, me/* routes, usage).

### 2026-03-25 — Merchant shell UI

- **Routing**: `MERCHANT` role opens a native **`MerchantHomeScreen`** from `_AuthGate`; named route `/merchant/home`; Stitch login/register `_routeForRole` includes `MERCHANT`.
- **Billing UX**: screen loads plans, summary, **catalog usage** (`used` / `max`), multi-store dropdown, **Subscribe** (Stripe Checkout via `url_launcher`) with **selected `merchantId`**, and **Portal** when subscription status allows.
- **Dependency**: `url_launcher` for external Stripe URLs (placeholder `https://example.com/...` return URLs until deep links are configured).

### 2026-03-25 — Merchant self-registration (app)

- **API**: `AppConfig.merchantRegisterEndpoint` → `POST /auth/register/merchant`; `AuthService.registerMerchant` + `AuthNotifier.registerMerchant` (owner + store + region).
- **Stitch**: registration bridge sends `merchantName` / `region`; `_submitRegistration` handles role `merchant` and navigates to `/merchant/home` via existing `_routeForRole`.
- **HTML**: both `user_registration_role_selection_1` and `_2` include store/region fields and a **Marchand** role option.

### 2026-03-25 — Merchant product management

- **Backend**: `GET /catalog/merchant/products` (JWT MERCHANT/ADMIN) lists **all** products for a merchant; access enforced via `BillingService`; `BillingService.resolveMerchantIdForUser` is public for reuse.
- **Flutter**: `CatalogService` authenticated list/create/patch/delete; **`MerchantProductsScreen`** (`/merchant/products`) with add/edit/delete, **`merchant.catalog.write`** errors surfaced via SnackBar; billing usage refresh after mutations; **`ProductModel.isActive`** + safer category parsing.
- **Merchant home**: **Manage products** opens the inventory screen.

### 2026-03-25 — Stripe email + merchant billing on auth

- **Billing**: first-time Checkout `customer_email` uses the **JWT user email** when present (falls back to synthetic `store@merchant.local`); `BillingController` types include `user.email`.
- **Flutter**: after profile load, **`onAuthenticated(UserModel)`** runs entitlements refresh and, for **MERCHANT**, **`merchantBillingProvider.refresh()`** (avoids Riverpod self-read cycle).
- **Tests**: `CatalogService.listMerchantScopedProducts` coverage (merchant default/explicit id, admin rules).

### 2026-03-25 — Entitlements scoped to selected merchant

- **`EntitlementsNotifier.refresh({merchantId})`** calls `/billing/me/entitlements` with optional query.
- **`MerchantBillingNotifier`** after successful **refresh** / **selectMerchant**, syncs **`entitlementsProvider`** to the active **`selectedMerchantId`** so app-wide entitlement reads match the store switcher.
- **Auth**: **MERCHANT** login only runs **`merchantBillingProvider.refresh()`** (which triggers the sync); non-merchants still call **`entitlementsProvider.refresh()`** without `merchantId`.

### 2026-03-25 — Logout reset + catalog entitlement UX

- **Logout / clearInvalidAuth**: clears **`entitlementsProvider`** and resets **`merchantBillingProvider`** so the next session does not flash another user’s billing state.
- **Merchant home**: warning when **`merchant.catalog.write`** is false; **Manage products** disabled until the plan grants catalog access.

### 2026-03-25 — Hardening review (no launch claim)

- **Automated validation run**: backend `npm test` (116), `npm run build`, `npm run test:e2e` (5); frontend `flutter test` (pass); `dart analyze` — **0 errors** (legacy **info**-level lints remain in Stitch/widgets).
- **Git hygiene**: working tree clean; no tracked `node_modules`, `.env`, or `dist`/`build` outputs; `.gitignore` includes `.env`, certs, `backend/uploads/`, Flutter tooling noise.
- **Docs**: added **`PRODUCTION_READINESS.md`** (explicit gaps: live Stripe, hosting, security depth, E2E for paid flows, ops/legal); rewrote **`NEXT_STEPS.md`** to match implemented vs remaining work.
- **Code**: single shared **`entitlementsServiceProvider`** (removed duplicate from `merchant_billing_provider.dart`) so Riverpod resolves one `EntitlementsService` instance.
- **Conclusion**: product is **materially stronger** but **not** asserted production-launch-complete; see **`PRODUCTION_READINESS.md`**.

### 2026-03-25 — Merchant path e2e

- **`test/app.e2e-spec.ts`**: `GET /catalog/merchant/products` **401** without JWT; **`POST /auth/register/merchant`** then **`GET /billing/me/memberships`**, **`GET /billing/me/entitlements?merchantId=`**, and **`GET /catalog/merchant/products`** (with and without explicit `merchantId`).
- **`npm run test:e2e`**: **7** tests passing (in-memory Mongo).

