## Next steps (after docs)

### Immediate build steps (implementation)
1. Add `billing/` module in backend:
   - Stripe client, webhook controller, event store, subscription + entitlement models
2. Add entitlements guard/decorator and apply to merchant write endpoints
3. Add admin dynamic content module (pricing table + announcements first)
4. Add Flutter providers/services:
   - entitlements fetch + caching
   - upgrade prompts + billing portal open

### Product growth steps
- Merchant acquisition funnel (landing page, in-app referrals)
- Merchant analytics and promo ROI reporting
- Customer loyalty / credits (merchant-funded)

### Quality steps
- Expand e2e tests for paid flows
- Add admin MFA
- Move document storage to S3 with signed URLs

