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
- Added frontend consumption scaffolding:
  - `ContentService` (`/content/:key`)
  - `MerchantBillingProvider` (plans + current entitlements)
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

