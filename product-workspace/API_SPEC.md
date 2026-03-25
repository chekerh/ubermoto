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

### Entitlements
#### GET `/me/entitlements`
- **Auth**: JWT (any)
- **Response**:
  - `user`: `{ role, features, limits }`
  - `merchant`: optional `{ merchantId, planKey, status, features, limits }`

### Billing (merchant)
#### POST `/billing/merchant/checkout-session`
- **Auth**: JWT (merchant admin user; v1 we may map merchant ownership via admin)
- **Body**: `{ planKey, successUrl, cancelUrl }`
- **Response**: `{ url }`

#### POST `/billing/webhooks/stripe`
- **Auth**: none (Stripe signature verification)
- **Behavior**: store `WebhookEvent`, process idempotently, update `Subscription` + `Entitlement`

#### GET `/billing/merchant/portal`
- **Auth**: JWT
- **Response**: `{ url }` (Stripe customer portal)

### Plans (admin)
#### GET `/admin/plans`
- Auth: ADMIN/CONTENT_MANAGER (read)
#### POST `/admin/plans`
- Auth: ADMIN/SUPER_ADMIN (write)
#### PATCH `/admin/plans/:key`
- Auth: ADMIN/SUPER_ADMIN

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

