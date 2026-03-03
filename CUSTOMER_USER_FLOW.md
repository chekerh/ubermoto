# Customer User Flow (Phase 1)

## Goal
Define a clear, implementable customer journey based on current interfaces, with working **email authentication** as the first hard requirement.

## What Exists Today (As-Is)
- Frontend currently starts in Stitch prototype mode via `frontend/lib/main.dart`.
- Navigation between prototype screens is controlled by `StitchViewer` double-tap + `nextRoute`, not real form submissions.
- Email auth APIs are implemented and usable in backend:
  - `POST /auth/login`
  - `POST /auth/register/customer`
- Frontend auth/data services exist (`AuthService`, `AuthNotifier`, `UserService`, `CatalogService`, `OrdersService`) but are not wired to real customer screens.

## Customer Interface Inventory (from Stitch screens)
- Launch / language: `frontend/stitch/ubermoto_splash_and_language_select_1/code.html`
- Login / role selection: `frontend/stitch/login_and_role_selection_1/code.html`, `frontend/stitch/login_and_role_selection_2/code.html`
- Registration / role selection: `frontend/stitch/user_registration_role_selection_1/code.html`, `frontend/stitch/user_registration_role_selection_2/code.html`
- Customer home: `frontend/stitch/customer_home_dashboard/code.html`
- Product details: `frontend/stitch/product_details_harissa/code.html`
- Filters & recommendations: `frontend/stitch/advanced_filters_recommendations/code.html`
- Cart / checkout: `frontend/stitch/cart_and_checkout/code.html`
- Checkout with promo: `frontend/stitch/enhanced_checkout_promo_codes/code.html`
- Order confirmation: `frontend/stitch/order_confirmation_cancel/code.html`
- Live tracking: `frontend/stitch/live_order_tracking/code.html`
- Notifications / reorder settings: `frontend/stitch/notification_and_reorder_settings/code.html`
- Optional AI ordering: `frontend/stitch/ai_smart_ordering_derja/code.html`, `frontend/stitch/ai_voice_command_personalization/code.html`

## Target Customer Flow (Logical To-Be)

### 0. App Launch + Language
- Open app -> choose language (EN/AR/Derja behavior as needed) -> continue to auth entry.

### 1. Authentication Entry
- Show role selector, but for this phase route **Customer** only.
- Primary auth method: **Email + Password**.
- Secondary options (phone, biometrics) stay optional and do not block email path.

### 2. Customer Login (Required)
- Inputs: email, password.
- Action: call `POST /auth/login`.
- On success:
  - Store JWT token.
  - Fetch profile with `GET /users/me`.
  - Verify `role == CUSTOMER`.
  - Route to customer home.
- On failure:
  - Show server error (invalid credentials, validation, network).
  - Keep user on login screen with entered email preserved.

### 3. Customer Registration (If no account)
- Inputs: name, email, password.
- Action: call `POST /auth/register/customer`.
- On success: same post-login path (token -> profile -> customer home).
- On duplicate email: show clear error and CTA back to login.

### 4. Home + Discovery
- Load catalog categories/products:
  - `GET /catalog/categories`
  - `GET /catalog/products`
- Allow search/filter from home.
- Open product details.

### 5. Product Detail -> Cart
- Product details:
  - `GET /catalog/products/:id`
  - `GET /catalog/products/:id/related`
- Select quantity and add to cart (local state).

### 6. Checkout
- Review cart, address, payment (COD first).
- Place order:
  - `POST /orders` with items, address, region, type=`MARKET`, paymentMethod=`COD`.
- On success: show order confirmation with order number.

### 7. Post-Order
- View order list/details:
  - `GET /orders`
  - `GET /orders/:id`
- If delivery tracking is enabled for market orders, open live tracking screen.

### 8. Settings + Reorder
- Notification preferences:
  - `GET /notification-preferences`
  - `POST /notification-preferences`
- Quick reorder from previous orders.

## Email Login Acceptance Criteria (Phase 1 Gate)
- User can sign in with valid email/password and reach customer home.
- Invalid email/password returns clear message and no navigation.
- Token is persisted and attached to authenticated requests.
- App startup checks token and restores customer session via `GET /users/me`.
- Logout clears token and returns to auth entry.

## Gaps To Fix Before Flow Is Truly Functional
- App entry still uses Stitch WebView prototypes, not real Flutter auth/catalog/order screens.
- Login UI in prototypes is phone-first and not connected to backend auth calls.
- Auth provider exists but is not wired into app navigation.
- Delivery client has contract mismatches (response shape + HTTP verb), which will affect later customer tracking flows.
- Some legacy docs/tests reference removed routes/screens and should be aligned after wiring real flow.

## Suggested Execution Order (Customer Phase)
1. Wire real auth entry/login/register screens with email-first path.
2. Add auth-based route guard (unauthenticated -> login, authenticated customer -> home).
3. Connect home/product/cart/checkout to existing catalog/orders services.
4. Validate happy-path + failure-path flow end-to-end.
5. Freeze customer flow, then start driver flow, then admin flow.
