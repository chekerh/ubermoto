## Admin dashboard (internal tool)

### Roles
- **SUPER_ADMIN**: manage admins, billing overrides, emergency actions
- **ADMIN**: ops (drivers/documents), catalog moderation, settings
- **SUPPORT**: tickets, limited user tooling
- **CONTENT_MANAGER**: FAQs, announcements, pricing copy
- **ANALYST**: read-only dashboards

### Capabilities (minimum)
- **Users**: search, view account state, disable/enable (audited)
- **Drivers**: pending queue, verify/reject, document review
- **Merchants**: status, subscription state, plan, limits, overrides
- **Dynamic content/settings**: pricing table, announcements, FAQs, feature flags
- **Support**: ticket queue, status updates, templates/macros
- **Billing**: webhook event viewer, subscription timeline
- **Audit log**: filter by actor/action/target

### UX requirements
- Fast search and filtering
- Clear “why” and “what happens” for irreversible actions
- Confirmations + audit trails on sensitive actions

