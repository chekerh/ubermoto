# Bug report

| ID | Severity | Issue | Reproduction | Root cause | Status |
|----|----------|--------|--------------|------------|--------|
| B1 | **High** (local dev) | Flutter `backendPort` was **3003** while backend defaults / `.env.example` use **3001** | Run API on 3001, run app → API calls miss | Config drift | **Fixed** (`app_config.dart` → 3001) |
| B2 | **Medium** (ops) | `nest build` can fail with `ENOTEMPTY` on `dist/catalog` | Repeated builds on some environments | nest-cli / fs race | **Documented** (clean `dist/`); not code-patched |
| B3 | **Medium** (CI) | `npm run lint` failed with **2 errors** on `require('firebase-admin')` / `require('fs')` | `npm run lint` | ESLint `no-var-requires` | **Fixed** (ESM-style imports in `firebase.service.ts`) |
| B4 | **Low** (env) | API start on `PORT=3001` hit **EADDRINUSE** | Another service bound 3001 | Local machine state | **Not fixed** (operational); use free `PORT` |

## Needs verification (not reproduced here)

- Full **order checkout** with catalog products (DB had no categories/products seeded).
- **Driver** registration + delivery accept flow end-to-end.
- **WebSocket** client against `/delivery` with JWT.
- **Production** `NODE_ENV=production` + strict `JWT_SECRET` validation.
