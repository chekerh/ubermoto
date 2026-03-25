# Issues consolidated (from prior QA / audits)

Sources: `full-app-qa-workspace/BUG_REPORT.md`, `full-app-qa-workspace/FINAL_CONCLUSION.md`, `runtime-validation/FINAL_CONCLUSION.md`, `continuation-workspace/CURRENT_STATE.md`, grep TODO/FIXME.

**Remediation status (latest pass):** **H1–H3**, **M2**, **L3**; **`@nestjs/terminus`** removed; **document delete** now removes local files safely in **`DocumentsService`**; **admin** category resolution prefers exact matches + empty-category guard. **M1**, **L1**, **L2** remain open / deferred.

## Critical

| ID | Issue | Source | Feasible now | Action |
|----|-------|--------|--------------|--------|
| — | (none open requiring immediate code fix this pass) | — | — | — |

## High

| ID | Issue | Source | Feasible now | Action |
|----|-------|--------|--------------|--------|
| H1 | `/health` returned **500** plaintext when Mongo unhealthy | QA probe + BUG B2 | **Yes** | Replace Terminus check with explicit ping + **503** JSON (`health.controller.ts`) |
| H2 | Document provider used **mock** stats/upload | BUG B5, `document_provider.dart` | **Yes** | Wire `DocumentsService` + real `/documents/stats` and multipart upload |
| H3 | Admin catalog create used **hardcoded** merchant + empty categories | BUG B6, `admin_provider.dart` | **Yes** | Add `GET /catalog/merchants` (admin) + resolve category IDs from `GET /catalog/categories` |

## Medium

| ID | Issue | Source | Feasible now | Action |
|----|-------|--------|--------------|--------|
| M1 | Stitch web vs mobile bridge parity | Prior MCP / B4 | **No** (large) | Remains documented; iframe path retained |
| M2 | `dart:io` in shared Flutter code breaks web | Engineering | **Yes** | Conditional imports `document_path_io` / `document_path_stub` |
| M3 | Document **delete** left files / TODO in service | `documents.service.ts` | **Yes** | Centralize unlink under `uploads/` + path guard; tests in `documents.service.spec.ts` |
| M4 | Admin **categoryIds** fuzzy match could mis-assign | `admin_provider.dart` | **Yes** | Exact name/slug first; validate non-empty `categoryIds` before POST |

## Low

| ID | Issue | Source | Feasible now | Action |
|----|-------|--------|--------------|--------|
| L1 | 376 ESLint warnings | QA | **Deferred** | No batch fix this pass |
| L2 | Flutter analyze infos | QA | **Deferred** | — |
| L3 | API_MAP stale | AGENTS.md policy | **Yes** | Document `GET /catalog/merchants` |
