# Bug report (QA pass)

Issues found via code review, environment probes, or test gaps. Severity: **S0** crash/blocker, **S1** major flow, **S2** moderate, **S3** minor/doc.

| ID | Severity | Title | Repro / evidence | Expected | Actual | Root cause (if known) | Status |
|----|----------|-------|------------------|----------|--------|-------------------------|--------|
| B1 | S3 | Root README claimed fixed coverage % | README line | Honest test guidance | “89%/87%” unverified | Doc drift | **Fixed** — README updated |
| B2 | S2 | Live `/health` on :3010 returned 500 | `curl 127.0.0.1:3010/health` | 200 JSON health | Plaintext 500 | Likely Mongo down or Terminus failure | **Not fixed** — env |
| B3 | S2 | Flutter web not up during probe | `curl :8080` | HTTP 200 | Connection refused | Server not started | **Not fixed** — ops |
| B4 | S1 | Stitch on web: no `StitchBridge` / injected JS | `stitch_embed_web.md` + code | Parity with mobile | iframe only | `webview_flutter_web` API limits | **Documented** — by design for now |
| B5 | S2 | `document_provider.dart` TODOs | Grep TODO | Wired stats/upload | Stubs | Not implemented | **Not fixed** |
| B6 | S2 | Admin provider hardcoded merchant | `admin_provider.dart` | Config/API-driven | Placeholder ObjectId | TODO | **Not fixed** |
| B7 | S3 | Backend ESLint 376 warnings | `npm run lint` | Clean or tracked | Many warnings | Tech debt | **Open** |
| B8 | S3 | Flutter analyze infos (e.g. trailing commas) | `flutter analyze lib` | Zero infos | 45 infos | Style | **Open** |
| B9 | — | Prior session: double-tap splash blocked by iframe | Web QA | Advance splash | Needed FAB | Pointer hit iframe | **Partially fixed** — FAB/AppBar (earlier session) |

## Items explicitly **not** bugs (clarifications)

- **E2E uses in-memory Mongo** — intentional; does not validate your real Atlas/local replica set tuning.  
- **Port 3001 returned 404 for `/health`** — suggests a non-Nassib process or different API surface; not treated as app defect without confirming process.  
