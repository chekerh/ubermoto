# Regression checklist (after this pass)

Re-run after merging QA changes:

| Check | Command / step | Expected |
|-------|----------------|----------|
| Backend unit | `cd backend && npm test` | All pass |
| Backend e2e | `cd backend && npm run test:e2e` | 5/5 pass |
| Backend build | `cd backend && npm run build` | Success |
| Backend lint | `cd backend && npm run lint` | 0 errors |
| Flutter unit | `cd frontend && flutter test` | All pass |
| Flutter analyze | `cd frontend && flutter analyze lib` | Per project policy |
| Manual smoke | Start Mongo + API + Flutter; open splash → login path on **device** | No red screen |

**Verified after fixes in this session:** `npm test`, `npm run test:e2e`, `flutter test` — all **pass**.
