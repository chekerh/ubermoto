# Next steps (best actions after this session)

## Immediate

1. ~~**Nest e2e smoke**~~ — Done: `backend/test/app.e2e-spec.ts` + `test/jest-e2e.json`, `mongodb-memory-server` + `supertest`; `npm run test:e2e`. Extend with delivery create/visibility when needed.
2. **Execute Browser MCP** — Backend + `seed:catalog` + `flutter run -d web-server --web-port 8080`; follow `runtime-validation/BROWSER_MCP_QA_PLAYBOOK.md` with `--dart-define=BACKEND_PORT=<PORT>` if API not on 3001.
3. **Flutter document provider** — Wire `document_provider.dart` TODOs to `documents` API or narrow scope with explicit “not implemented” UI.

## Short term

- **Stitch route map** — Table: HTML file → expected API calls; fix missing integrations.
- **`VerifiedDriverGuard`** on driver operational routes (product decision).
- **Refresh `project-architecture/API_MAP.md`** if routes/DTOs drifted.
- **`npm audit fix`** on a branch with full test run.

## References

- Prior audit: `delivery-workspace/SECURITY_REVIEW.md`, `PRODUCTION_READINESS_AUDIT.md`
- Agents: `project-architecture/AGENTS.md`, `delivery-workspace/AGENTS.md`
- Runtime: `runtime-validation/RUN_GUIDE.md`, `FINAL_CONCLUSION.md`
