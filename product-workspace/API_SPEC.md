## API spec (paid-grade additions)

### Conventions
- **Auth**: `Authorization: Bearer <JWT>`
- **Errors**: JSON body with `message` and (where relevant) `code`, `details`
- **RBAC**: server-enforced; admin routes require admin roles

---

## Existing (high level)
See `project-architecture/API_MAP.md` for the current implemented map.

---

## New endpoints to implement (billing/entitlements/content)

### Catalog (merchant inventory)
#### GET `/catalog/merchant/products`
- **Auth**: JWT + **MERCHANT** or **ADMIN**
- **Query**: optional `merchantId` — merchants default to their first membership; **ADMIN** must pass `merchantId`
- **Response**: array of products for that merchant (**includes** `isActive: false`), sorted by `updatedAt` desc

### Entitlements
#### GET `/users/me/entitlements`
- **Auth**: JWT (any) — returns effective user + merchant payload

#### GET `/billing/me/entitlements`
- **Auth**: JWT (any), optional `merchantId` query to scope membership
- **Response**:
  - `user`: `{ role, features, limits }`
  - `merchant`: optional `{ merchantId, planKey, status, features, limits }`

### Billing (merchant)
#### POST `/billing/merchant/checkout-session`
- **Auth**: JWT + MERCHANT or ADMIN
- **Body**: `{ merchantId, planKey, successUrl, cancelUrl }`
- **Response**: `{ url }`

#### POST `/billing/merchant/me/checkout-session`
- **Auth**: JWT + MERCHANT or ADMIN
- **Body**: `{ planKey, successUrl, cancelUrl, merchantId? }` — optional `merchantId` scopes checkout to a membership when the user has several merchants
- **Stripe**: for merchants without a Stripe customer yet, Checkout **`customer_email`** is prefilled from the **authenticated user’s email** when the JWT includes it

#### POST `/billing/merchant/me/portal-session`
- **Auth**: JWT + MERCHANT or ADMIN
- **Body**: `{ returnUrl, merchantId? }`

#### GET `/billing/merchant/me/summary`
- **Auth**: JWT + MERCHANT or ADMIN
- **Query**: optional `merchantId`

#### GET `/billing/merchant/me/usage`
- **Auth**: JWT + MERCHANT or ADMIN
- **Query**: optional `merchantId`
- **Response**: `{ merchantId, products: { used, max, remaining } }` — `max`/`remaining` are `null` when the plan has no product cap

#### POST `/billing/webhooks/stripe`
- **Auth**: none (Stripe signature verification)
- **Behavior**: store `WebhookEvent`, process idempotently, update `Subscription` + `Entitlement`

#### POST `/billing/merchant/portal-session`
- **Auth**: JWT + MERCHANT or ADMIN
- **Body**: `{ merchantId, returnUrl }`
- **Response**: `{ url }` (Stripe customer portal)

### Plans (admin)
#### GET `/billing/plans`
- Auth: Public
#### POST `/billing/admin/plans/upsert`
- Auth: ADMIN

### Merchant membership (admin)
#### POST `/billing/admin/merchant-membership`
- Auth: ADMIN
- Body: `{ merchantId, userId, role }`

### Dynamic content/settings (admin)
#### GET `/content/:key`
- Public or JWT depending on key; returns published version
#### GET `/admin/content/:key`
- Admin roles; returns draft+published
#### PUT `/admin/content/:key`
- Admin roles; validates schema; writes draft or publish

### Audit log (admin)
#### GET `/admin/audit`
- Admin; paginated filter by actor/action/target

