## Analytics and retention

### North-star metrics
- **Merchant retention**: % merchants active at day 30/60/90
- **Orders per active customer** (weekly)
- **On-time delivery rate**
- **Repeat purchase rate**

### Product KPIs
Customer:
- checkout conversion, reorder usage, promo redemption

Driver:
- acceptance rate, completion rate, time-to-pickup, rating

Merchant:
- revenue, cancellations, AOV, promo ROI

Ops:
- ticket volume + resolution time, document review SLA

### Instrumentation plan
- Server-side events for core actions (authoritative)
- Client-side UI funnel events (optional, privacy-aware)
- Error/perf via Sentry

### Retention loops (v1)
- Reorder prompts in order history
- Merchant-funded promos with expiration reminders
- In-app announcements (dynamic content)
- Support follow-ups with CSAT

