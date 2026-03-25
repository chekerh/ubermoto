## User flows

### Onboarding (customer)
1. Install/open app → select language
2. Register/login
3. Set region + first saved address
4. Browse catalog → add to cart → checkout → create order/delivery

### Onboarding (driver)
1. Register as driver
2. Submit documents (4 types) → status: pending/approved/rejected
3. Wait for admin verification → become available
4. Accept jobs → update status → complete → rating

### Recurring usage (customer retention loop)
1. Push/email notification for order status
2. Order history → reorder
3. Favorites → quick add to cart
4. Promotions (merchant-funded) → drive return orders

### Merchant paid flow (subscription)
1. Merchant signs up (admin invites or self-serve) → creates merchant profile
2. Choose plan → start trial → checkout (Stripe)
3. Use dashboard: catalog, promos, analytics, operations settings
4. Renew monthly; downgrade/upgrade in Stripe portal; plan gates enforced in API + UI

### Support flow
1. User submits ticket with reference (order/delivery)
2. Support/admin views queue → updates status/resolution
3. User notified; ticket closes; CSAT captured

### Admin/operator flow
1. Admin login (MFA later) → dashboard metrics
2. Review queues: drivers/documents
3. Manage dynamic content: pricing cards, FAQs, announcements, feature flags
4. Investigate issues: audit log, user debug tools, webhook events

