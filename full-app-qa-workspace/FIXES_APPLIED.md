# Fixes applied (this QA pass)

| Fix | Why | Files |
|-----|-----|--------|
| E2E: customer **POST /deliveries** + **GET /deliveries/:id** | Core business flow had no HTTP-level regression test | `backend/test/app.e2e-spec.ts` |
| README testing claim | Avoid misleading “89%/87% coverage” without CI proof | `README.md` |

## Impact

- **E2E:** 4 → **5** tests; validates auth + create + read-by-id for deliveries (customer JWT).  
- **README:** Aligns marketing text with measurable commands (`npm test`, `npm run test:e2e`, `flutter test`).  

## Not changed (scope / risk)

- Live Mongo health on developer machine  
- Stitch web postMessage bridge  
- Admin/document provider TODOs  
- ESLint warning burn-down  
