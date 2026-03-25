# Actions log (chronological)

1. **Repo discovery** — Confirmed NestJS backend (`backend/`), Flutter frontend (`frontend/`), MongoDB via Mongoose, no `docker-compose` in repo.
2. **`npm test` (backend)** — Ran from `backend/` → **8 suites, 93 tests passed**.
3. **`npm run build` (backend)** — After `rm -rf dist` → **success** (avoids occasional `ENOTEMPTY` on `dist/`).
4. **MongoDB** — `nc -z localhost 27017` → **open** on this machine.
5. **First API launch** — `node dist/main.js` with `PORT=3001` → **failed**: `EADDRINUSE` (another process already bound `:3001`).
6. **Second API launch** — `PORT=3010`, `MONGODB_URI=mongodb://127.0.0.1:27017/nassib_runtime_test`, `JWT_SECRET=...`, `NODE_ENV=development` → **success**; process left running for HTTP checks.
7. **HTTP smoke** — `GET http://127.0.0.1:3010/health` → **200**, Mongo **up**. `GET /faqs` → **200**, body `[]`.
8. **Auth + profile** — `POST /auth/register/customer` → JWT; `GET /users/me` with Bearer → **200** with user JSON (no password field).
9. **Catalog** — `GET /catalog/categories` → **200**, `[]` (empty DB).
10. **Delivery** — `POST /deliveries` as customer → **201**, delivery document with `status: pending`.
11. **`npm run lint` (backend)** — Initially **2 errors** (`no-var-requires` in `firebase.service.ts`). After fix → **0 errors**, 373 warnings.
12. **`flutter test` (frontend)** — **24 tests passed**.
13. **Code fixes applied during validation** — See `FIXES_APPLIED.md`.
14. **Not run** — `flutter run` / iOS Simulator / Android Emulator (no device session in this environment). Browser MCP not used for Stitch WebView flows.

## Follow-up (user request: risks + MCP testing)

15. **WebSocket hardening** — `DeliveryGateway`: `subscribeToDelivery` / `updateLocation` authorized via DB; `emitDeliveryAssigned` and driver leg of `emitDeliveryStatusUpdate` emit to **user rooms by User id** (`websocket.module.ts` + `delivery.gateway.ts`).
16. **Catalog seed** — `backend/scripts/seed-dev-catalog.ts`, `npm run seed:catalog`; executed successfully against `nassib_runtime_test` (merchant + 3 categories + 3 products).
17. **MCP QA docs** — `runtime-validation/BROWSER_MCP_QA_PLAYBOOK.md`; `RUN_GUIDE.md` updated; Cursor rule `.cursor/rules/ubermoto-browser-qa.mdc`.
18. **Re-verify** — `npm run build` + `npm test` → **pass** after gateway changes.
