## Subscription and entitlements

### Plan definitions (canonical)
Feature keys (examples):
- `merchant.catalog.write`
- `merchant.promos.write`
- `merchant.analytics.basic`
- `merchant.analytics.advanced`
- `merchant.storefront.blocks.write`

Limits (examples):
- `merchant.products.max`
- `merchant.promos.per_month`

Plans:
- **merchant_basic**
  - features: catalog.write, analytics.basic
  - limits: products.max=200, promos.per_month=0
- **merchant_pro**
  - features: catalog.write, promos.write, analytics.advanced, storefront.blocks.write
  - limits: products.max=2000, promos.per_month=20

### Entitlement evaluation rules
1. Determine `owner` (merchant) for the request.
2. Read `Subscription` status:
   - `active|trialing` → full plan entitlements
   - `past_due` → grace: keep core but disable write-heavy premium features after threshold
   - `canceled|unpaid|incomplete` → restrict to free/readonly merchant state
3. Apply admin overrides (time-bound) last.

### API enforcement pattern
- Add a reusable guard/decorator:
  - `@RequireEntitlement('merchant.promos.write')`
  - `@RequireLimit('merchant.promos.per_month')`
- Log entitlement denials (rate-limited) for growth insights.

### Client behavior
- Fetch entitlements at login and on app resume.
- Use entitlements to:
  - hide/disable UI controls
  - show upgrade prompts
  - explain “why blocked” with plan comparison link

