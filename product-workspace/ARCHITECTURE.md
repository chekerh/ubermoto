## Architecture (production-grade target)

### Overview
UberMoto is a multi-role marketplace:
- **Customers** place orders and create deliveries
- **Drivers** accept/fulfill deliveries (with verification)
- **Merchants** manage catalog/promos and pay subscription (B2B)
- **Admins/Ops/Support** manage the platform, content, and settings

Current repo stack:
- **Backend**: NestJS 10 + MongoDB (Mongoose) + Socket.IO
- **Frontend**: Flutter + Riverpod; “Stitch” HTML-in-WebView screens for much UI

### North-star principles
- **Server-enforced entitlements**: UI gates are helpful; API must be authoritative.
- **Dynamic business content**: pricing cards, FAQs, announcements, feature flags editable by admins.
- **Auditability**: admin actions and billing webhook effects are logged and replay-safe.
- **Operational safety**: idempotent webhooks, rate limits, safe uploads, health/version endpoints.

---

## System diagram (logical)

```mermaid
flowchart LR
  subgraph Clients
    CUST[Customer app (Flutter)]
    DRV[Driver app (Flutter)]
    MERCH[Merchant dashboard (Flutter/Web)]
    ADM[Admin dashboard (Flutter/Web)]
  end

  subgraph API[NestJS API]
    AUTH[Auth + RBAC]
    CAT[Catalog]
    ORD[Orders]
    DEL[Deliveries]
    DOC[Documents]
    SUP[Support + FAQ]
    NOTIF[Notifications inbox + FCM]
    SURGE[Surge rules]
    PROMO[Promo codes]
    BILL[Billing + Entitlements]
    CFG[Dynamic content + Settings]
    AUDIT[Audit log]
    WS[Socket.IO /delivery]
  end

  subgraph Data[MongoDB]
    U[(Users)]
    M[(Merchants)]
    P[(Products)]
    O[(Orders)]
    D[(Deliveries)]
    DO[(Documents)]
    S[(Settings/Content)]
    A[(AuditLog)]
    SUB[(Subscriptions/Entitlements)]
  end

  subgraph External
    STRIPE[Stripe Billing]
    MAPS[Maps/Geo services]
    FCM[Firebase Cloud Messaging]
    SENTRY[Sentry]
  end

  Clients --> API
  API --> Data
  BILL <--> STRIPE
  NOTIF <--> FCM
  API --> SENTRY
  API --> MAPS
  WS <--> Clients
```

---

## Key backend modules (target)

### Billing + entitlements (new module)
- **Stripe** customer + subscription lifecycle
- **Webhook ingestion**: verify signature, store events, idempotency keying
- **Entitlements**: computed from plan + add-ons + overrides; cached in DB
- **Feature gates**: helpers/guards to require entitlements on endpoints

### Dynamic content/settings (new module)
- Admin-editable:
  - pricing plans content (display), announcements, FAQ/help center
  - feature flags, operational thresholds, merchant-configurable storefront blocks
- Guarded by roles, validated, and audited

### Admin roles (evolve beyond ADMIN)
Target roles:
- `SUPER_ADMIN` (break-glass, manage admins, view secrets references)
- `ADMIN` (ops + settings + reviews)
- `SUPPORT` (tickets, limited user tools)
- `CONTENT_MANAGER` (FAQs, announcements, marketing copy)
- `ANALYST` (read-only dashboards)

Implementation approach: keep `UserRole` for app roles; introduce `AdminRole` claims for internal staff accounts.

---

## Frontend architecture (target)

- Continue using existing Flutter app but progressively move critical paid UX out of static Stitch HTML into Flutter widgets where needed for:
  - billing state, plan gating, upgrade prompts, and admin content editors
- A shared **EntitlementsProvider** loads current user/merchant entitlements.
- A shared **RemoteConfigProvider** loads dynamic content/settings (announcements, pricing cards).

---

## Background jobs (target)

Start with in-process cron (Nest schedule) + move to queue later:
- nightly metrics rollups
- stale delivery cleanup
- webhook retry processing
- notification fanout retries

Queue upgrade path: BullMQ/Redis.

