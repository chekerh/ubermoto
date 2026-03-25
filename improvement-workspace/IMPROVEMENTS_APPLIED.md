# Improvements applied

## 1. Health endpoint behavior (`backend/src/health/`)

- **Before:** `@nestjs/terminus` `HealthCheck` could surface as **500** with opaque text when Mongo failed.
- **After:** Direct Mongoose `readyState` + `db.admin().command({ ping: 1 })`; failures throw **`ServiceUnavailableException`** → **503** with structured JSON payload.
- **Impact:** Load balancers and operators can distinguish DB outage from random 500s; aligns with prior QA finding (B2).

## 2. Admin catalog product create (`frontend/.../admin_provider.dart` + API)

- **Before:** Hardcoded `merchantId`, empty `categoryIds`, arbitrary `regions`.
- **After:** `GET /catalog/merchants` (admin JWT) for first active merchant `id` + `region`; `GET /catalog/categories` to match `product.category` to category `_id`s.
- **Impact:** Creating products targets real seeded data (`seed:catalog`) without editing Dart constants.

## 3. Document stats & upload (`frontend/.../document_provider.dart`, `documents_service.dart`)

- **Before:** Mock delays and fake stats; upload stub.
- **After:** `GET /documents/stats` via existing `DocumentsService`; multipart upload to `POST /documents/upload` (driver role required server-side). File path read isolated in **`document_path_io.dart`** / **`document_path_stub.dart`** for web-safe builds.
- **Impact:** Driver document flows can use real API on mobile/desktop; web gets clear unsupported path for filesystem uploads.

## 4. Catalog API surface (`backend/src/catalog/`)

- New **admin** endpoint: `GET /catalog/merchants` → `[{ id, name, region }]`.

## 5. Documentation

- `project-architecture/API_MAP.md` updated for merchants route.

## 6. Dependency cleanup (`backend/package.json`)

- **Removed:** `@nestjs/terminus` — no longer referenced after the custom Mongoose health check.
- **Impact:** Smaller install surface and no misleading “health via Terminus” expectation in `package.json`.

## 7. Document delete + disk cleanup (`backend/src/documents/`)

- **Before:** Controller duplicated unlink logic; service had a **TODO** and could leave behavior split across layers.
- **After:** **`DocumentsService.tryRemoveStoredFile`** resolves paths under **`uploads/`** only (blocks `..` and paths outside uploads), then **`unlinkSync`**; failures logged, DB row still removed. **`DocumentsController.remove`** only authorizes + calls **`delete`**.
- **Tests:** `documents.service.spec.ts` (3 cases for **`delete`**).
- **Impact:** Single place for delete semantics; fewer orphan files; safer than blind `path.join(cwd, filePath)`.

## 8. Admin category matching (`frontend/.../admin_provider.dart`)

- **Before:** Substring **`contains`** could return multiple or wrong categories when labels overlapped.
- **After:** Prefer **exact** name/slug matches; use substring only if no exact hit. **`addProduct`** throws a clear error if **`categoryIds`** is empty.
- **Impact:** Fewer wrong **`categoryIds`** on create; clearer operator feedback when seed data does not match the label (empty match blocks the API call).
