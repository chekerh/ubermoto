# Actions log

Record of analysis and documentation generation for the **ubermoto** monorepo (Nassib / UberMoto delivery platform).

## Scope inspected

| Area | Paths / artifacts |
|------|-------------------|
| Root | `package.json` (minimal `firebase-admin` dep only), `.github/workflows/` |
| Backend | `backend/package.json`, `backend/src/main.ts`, `backend/src/app.module.ts`, all `*.controller.ts`, `backend/src/auth/**`, `backend/src/websocket/**`, Mongoose schemas under `backend/src/**/schemas/`, `backend/src/**/dto/` |
| Frontend | `frontend/pubspec.yaml`, `frontend/lib/main.dart`, `frontend/lib/config/app_config.dart`, `frontend/lib/services/*.dart`, `frontend/lib/features/**` |
| Design prototypes | `frontend/stitch/**/code.html` (referenced from `main.dart`) |
| CI | `.github/workflows/backend-ci.yml`, `frontend-ci.yml` |
| Existing security note | `SECURITY_AUDIT.md` (root; not rewritten) |

## Tools / methods

- Repository tree listing and targeted reads of modules listed above.
- `grep` for Nest decorators (`@Controller`, `@Get`, `@UseGuards`, `@Roles`) and WebSocket usage.

## Architecture decisions (documentation only)

- Chose **`/project-architecture`** at repo root because **`/docs` did not exist** and the brief allowed either root or `docs/project-architecture`.
- Terminology: product strings mix **Nassib** (backend package name, Swagger title, Flutter app title) and **ubertaxi_frontend** / **UberMoto** in `pubspec` / folder name — documented as-is.

## Assumptions (explicit)

- **Production deployment topology** (hosting, MongoDB Atlas vs self-hosted, reverse proxy) is **not defined in code reviewed**; `DEPLOYMENT_README.md` under frontend may add detail — marked *needs verification* in `ARCHITECTURE.md`.
- **Whether FAQ list is intended to be public** is unclear: `SupportController` applies `JwtAuthGuard` at class level, so `GET /faqs` requires a valid JWT — *inferred*: possible oversight or intentional (authenticated-only help).

## Unresolved uncertainties

- **Nest route matching for `/drivers/leaderboard`**: Documented as **likely shadowed** by `GET :id` based on handler order in `drivers.controller.ts` (framework behavior); confirm with a live HTTP request in your environment.

- **JWT default secret**: `JWT_SECRET` falls back to `'default-secret'` in `auth.module.ts` and `jwt.strategy.ts` if unset — high risk in undeclared envs.
- **WebSocket CORS**: `DeliveryGateway` uses `origin: '*'` — production hardening *needs verification*.
- **Authorization gaps**: Several delivery and document routes use `JwtAuthGuard` + `RolesGuard` but **no `@Roles`**, so any authenticated role may hit them (e.g. `GET /deliveries/:id`, `POST /deliveries/:id/cancel`, `GET /documents/:id`) — document in `AUTH_AND_SECURITY.md`.
- **`VerifiedDriverGuard`**: Registered in `AuthModule` but **not referenced on controllers** in the scanned codebase — guard exists but is unused for HTTP routes.

## Documentation files generated

All under **`/project-architecture/`**:

1. `ACTIONS_LOG.md` (this file)
2. `ARCHITECTURE.md`
3. `FEATURE_INVENTORY.md`
4. `TEST_PLAN.md`
5. `FOLDER_STRUCTURE.md`
6. `DATA_FLOW.md`
7. `API_MAP.md`
8. `AUTH_AND_SECURITY.md`
9. `TECH_DEBT_AND_RECOMMENDATIONS.md`
10. `NEXT_STEPS.md`
11. `AGENTS.md`

No application source files were modified for this task.
