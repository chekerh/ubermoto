## Billing and monetization (merchant-first)

### Pricing structure (initial)
All prices are examples; final pricing is editable via admin dynamic content.

- **Customer**: Free
- **Driver**: Free (future: Driver Pro)
- **Merchant Basic**: monthly subscription
  - Catalog + order management
  - Basic analytics
- **Merchant Pro**: monthly subscription
  - Promos + advanced analytics + storefront blocks
  - Priority support

### What users pay for
Merchants pay for **measurable ROI**:
- more orders (promos, discovery)
- fewer cancellations (tracking + ops controls)
- lower support time (ticketing + templates)
- better decisions (analytics)

### Billing lifecycle (Stripe)
- Trial (optional): 7–14 days
- Active → Past due (grace period) → Suspended (feature-limited)
- Cancel at period end → downgrade to free/limited merchant state

### Enforcement
- Server computes entitlements from subscription status.
- UI displays plan + upgrade prompts but does not decide access.

### Upgrade prompts
- When merchant hits limits (e.g. products count, promos/month)
- When accessing Pro-only analytics
- In settings “Billing” page with clear plan comparison

### Invoice history
- Via Stripe Customer Portal (v1) + optional in-app listing later

