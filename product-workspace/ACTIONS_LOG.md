## Actions log — Product build

This folder (`/product-workspace`) is the source of truth for building **UberMoto (Tunisia)** into a **production-grade paid product**.

### 2026-03-25

- Created `/product-workspace/` and began documentation-first planning.
- Confirmed existing stack: **NestJS + MongoDB (backend)**, **Flutter (frontend)**, **Socket.IO** realtime, multi-role auth (**CUSTOMER/DRIVER/ADMIN**).
- Confirmed current repo has no billing/subscription implementation yet; this workspace defines how we will add it safely.

### Decisions (so far)

- **Business model**: B2B + B2C marketplace; **customers** can use the app free; **merchants** pay subscription for growth + ops tools; **drivers** may have optional paid “Pro” features later.
- **Billing provider**: Stripe (Subscriptions + Customer Portal + Webhooks). If Stripe is not viable in Tunisia deployment context, plan includes a provider-abstraction seam.
- **Dynamic content**: Pricing table, announcements, FAQs/help, surge rules, promo campaigns, and selected ops settings are admin-editable (audited).

### Open items

- Confirm whether UberMoto targets **multi-merchant** from day one (affects admin UX and catalog/product ownership).
- Choose production hosting defaults (Fly.io/Render/AWS) and managed Mongo (Atlas) vs self-hosted.

