## Dynamic content and settings (admin-editable)

### What is configurable (v1)
- **Pricing table content**: plan names, feature bullet points, price display, CTA text
- **Announcements/banners**: in-app and web
- **FAQ/help center**: categories, ordering
- **Feature flags**: enable/disable beta modules (e.g. promos UI)
- **Operational thresholds**:
  - max upload size (server-side cap remains enforced)
  - support SLA text
  - surge preview defaults

### What is NOT configurable
- Auth/roles logic, JWT validation
- Stripe secrets / webhook signing secrets
- Core pricing math invariants (surge algorithm code), only parameters editable

### Content model
Keys (examples):
- `pricing_table`
- `home_announcement_banner`
- `support_faq`
- `feature_flags`

Each key:
- has a **schemaVersion**
- supports **draft/published**
- updates create **AuditLog** entries

### Validation rules
- Strict JSON schema per key
- Required fields, max lengths, safe markdown/HTML handling (sanitize)
- Permission checks by admin role

