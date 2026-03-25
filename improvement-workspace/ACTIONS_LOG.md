# Actions log (improvement / remediation)

| Step | Detail |
|------|--------|
| 1 | Read `full-app-qa-workspace/BUG_REPORT.md`, `FINAL_CONCLUSION.md`, continuation/runtime notes. |
| 2 | Implemented **health** overhaul: `InjectConnection` + `ping`, `ServiceUnavailableException` (503) on failure; removed `TerminusModule` from `HealthModule`. |
| 3 | Rewrote `health.controller.spec.ts` (connection mock + 503 cases). |
| 4 | Added `CatalogService.listActiveMerchants` + `Merchant` model inject; `GET /catalog/merchants` (ADMIN) in `catalog.controller.ts`. |
| 5 | Extended `catalog.service.spec.ts` (merchant mock + `listActiveMerchants` test). |
| 6 | `DocumentsService.uploadDocument` multipart POST to `/documents/upload`. |
| 7 | `DocumentNotifier`: real `getDocumentStats`, upload via service; conditional `document_path_io` / `document_path_stub`; `copyWith(clearError:)`. |
| 8 | `AdminStateNotifier`: `_resolveMerchantForProduct`, `_categoryIdsForLabel`; `addProduct` uses API-derived merchant + categories. |
| 9 | Updated `project-architecture/API_MAP.md` for `/catalog/merchants`. |
| 10 | Ran `npm test`, `npm run test:e2e`, `npm run build`, `flutter test`, `dart analyze` on touched Dart files — all **pass**. |
| 11 | Removed unused **`@nestjs/terminus`** (`npm uninstall @nestjs/terminus`); re-ran **`npm test`** — **105** pass. |
| 12 | **`DocumentsService.delete`:** local file removal under `uploads/` with traversal guard; **`Logger`** on failures; controller **`remove`** delegates (no duplicate unlink). |
| 13 | **`documents.service.spec.ts`:** delete — not found, unlink when file exists, skip `..` paths. |
| 14 | **`admin_provider`:** category resolution prefers **exact** name/slug over substring; **`addProduct`** fails fast with clear message if no category match. |
| 15 | Re-ran **`npm test`** (**109**), **`npm run build`**, **`npm run test:e2e`**, **`flutter test`**, **`dart analyze`** on `admin_provider.dart` — all **pass**. |
