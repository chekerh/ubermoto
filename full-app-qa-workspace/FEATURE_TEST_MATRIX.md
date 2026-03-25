# Feature test matrix

Legend: **Auto** = automated test run this session; **Manual** = human/MCP/device; **N/A** = not applicable; **Block** = environment blocked.

## Backend modules (HTTP)

| Feature / module | Criticality | Test method | Result | Notes |
|------------------|-------------|-------------|--------|-------|
| Health + Mongo ping | P0 | Auto e2e `GET /health` | **Pass** | In-memory Mongo |
| Public FAQs | P1 | Auto e2e `GET /faqs` | **Pass** | Returns array |
| Auth register customer | P0 | Auto e2e | **Pass** | JWT returned |
| Auth login | P0 | Unit (`auth.service.spec`) | **Pass** | Not re-e2e’d this pass |
| Deliveries list (authz) | P0 | Auto e2e `GET /deliveries` 401/200 | **Pass** | |
| Deliveries create + read by id | P0 | Auto e2e | **Pass** | Added this QA pass |
| Deliveries driver/admin flows | P1 | Unit partial | **Partial** | Service specs; no full e2e matrix |
| Orders | P1 | Not executed | **Unverified** | No e2e this pass |
| Drivers / motorcycles | P1 | Unit / not full e2e | **Partial** | |
| Documents upload/metadata | P1 | Not executed | **Unverified** | Multer + storage TODOs in code |
| Catalog CRUD | P1 | Unit `catalog.service.spec` | **Pass** | No HTTP e2e |
| Admin verify / system | P2 | Unit `admin.service.spec` | **Pass** | |
| Support tickets / feedback | P2 | Unit `support.service.spec` | **Pass** | |
| Notifications inbox | P2 | Unit | **Pass** | |
| Promo codes | P2 | Not executed | **Unverified** | |
| Surge rules | P2 | Not executed | **Unverified** | |
| Firebase send-push | P2 | Not executed | **Unverified** | Admin-only; needs creds |
| WebSocket subscribe/location | P0 | Unit `delivery.gateway.spec` | **Pass** | No socket.io client e2e |
| Recommendations | P2 | Not executed | **Unverified** | |
| Users / addresses | P1 | Not executed | **Unverified** | |

## Frontend (Flutter)

| Area | Criticality | Test method | Result | Notes |
|------|-------------|-------------|--------|-------|
| Providers / models (catalog, language, product) | P1 | `flutter test` | **Pass** | 24 tests |
| `main.dart` / routing table | P1 | Code review | **N/A** | No widget e2e |
| Stitch splash / login / home (per role) | P0 | Manual / MCP prior | **Partial** | Web = iframe; bridge limited |
| Maps / OSRM / geolocation | P1 | Not executed | **Unverified** | Needs device + keys |
| Secure storage / auth persistence | P0 | Not executed | **Unverified** | Device/integration |
| WebSocket client + delivery UI | P1 | Not executed | **Unverified** | |
| Document provider TODOs | P2 | Code review | **Gap** | TODOs in `document_provider.dart` |
| Admin provider hardcoded merchant | P2 | Code review | **Gap** | TODO merchant id |

## Cross-cutting

| Concern | Test method | Result |
|---------|-------------|--------|
| Production JWT bootstrap | Code (`bootstrap-validation.ts`) | **Present**; not e2e |
| Rate limiting | Code review | **Present** |
| Role guards | Unit + partial e2e | **Partial** |
| Live API on host (3010) | `curl /health` | **Fail** (500 during probe) |
| Flutter web up (8080) | `curl` | **Block** (not running) |
