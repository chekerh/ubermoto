## Product spec — UberMoto (Tunisia)

### Product summary
UberMoto is a motorcycle delivery marketplace for Tunisia that makes **local delivery fast and trustworthy** via verified drivers, real-time tracking, predictable pricing, and merchant tooling.

### Target audience
- **Customers (B2C)**: People ordering from local merchants and needing same-day delivery.
- **Drivers (supply)**: Motorcycle couriers who want steady work, clear payouts, and safety/verification.
- **Merchants (B2B paid)**: Small/medium merchants (grocery, pharmacy, restaurants, specialty) who want delivery sales without building logistics.
- **Operators (internal)**: Admin/support/ops roles to run the platform.

### Core problem
Customers and merchants can’t reliably get **fast, trackable local delivery** with consistent pricing and trust. Drivers need a stable pipeline and a verification path that increases earnings and safety.

### Value proposition (why it wins)
- **Trust**: verified drivers + document workflows + status transparency.
- **Speed**: driver matching + realtime location + operational controls (surge, promo, dispatch).
- **Merchant growth**: catalog + promos + analytics + customer retention tooling.

### Goals
- Repeat usage: ordering becomes a habit.
- Merchant retention: merchants see ROI from subscription.
- Operational manageability: admins can update pricing/content/settings without deploys.
- Production readiness: observability, security, and billing-grade correctness.

### Non-goals (for v1)
- Full multi-country expansion.
- In-house map tile hosting.
- Custom payment processor (use Stripe first).

### Scope

#### “MVP that still feels paid-grade” (launchable)
- Auth (customer/driver/admin), profiles, saved addresses
- Catalog browse + cart + order create
- Delivery create + status lifecycle + realtime tracking
- Driver onboarding + document verification
- Admin dashboard: queue review + ops settings + catalog management
- Support: tickets + public FAQs
- Observability: health/version endpoints, structured errors, basic audit logging

#### Paid/premium scope (must exist for monetization)
- Merchant subscription plans with feature gating:
  - **Basic**: catalog management, order management, payouts summary
  - **Pro**: promos, surge participation rules, advanced analytics, priority support, configurable storefront blocks
- Admin-managed **pricing table**, announcements, feature flags, help content.

#### Production scope (hardening)
- Stripe webhooks + idempotency
- Abuse controls (rate limits, upload constraints)
- Audit trails for admin actions
- Data migrations strategy
- Backups + incident runbooks

