## AI / Agent instructions (product build)

### Non-negotiables
- Never commit `.env` or secrets.
- Keep billing + entitlements **server-enforced**.
- All admin writes must be **audited**.
- Prefer incremental changes + tests; avoid large rewrites.

### Validation checklist before merging
- Backend: `npm test`, `npm run test:e2e`, `npm run build`
- Frontend: `flutter test`, `dart analyze`
- Security: verify guards on new endpoints, webhook signature verification
- Ops: update `/product-workspace/ACTIONS_LOG.md` and relevant specs
- Do **not** claim production launch complete without `PRODUCTION_READINESS.md`-class criteria (Stripe live, hosting, legal, etc.).

### Repo constraints
- Backend code stays under `backend/`
- Frontend code stays under `frontend/`
- Keep docs in `/product-workspace` as the product source of truth

