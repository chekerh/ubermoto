# Fixes applied (during runtime validation)

## 1. Align Flutter API port with backend default

- **File:** `frontend/lib/config/app_config.dart`
- **Change:** `backendPort` **3003 → 3001** to match `backend/.env.example` and default `PORT` in `main.ts`.
- **Why:** Without this, a typical local run (API on 3001) fails all HTTP calls from the app.
- **Impact:** Local integration works when both use defaults; if you use another `PORT`, update this constant or future `--dart-define` wiring.

## 2. Remove ESLint-breaking `require` in Firebase service

- **File:** `backend/src/firebase/firebase.service.ts`
- **Change:** `import * as admin from 'firebase-admin'` and `import { readFileSync } from 'fs'`; removed `require(...)` for those.
- **Why:** `npm run lint` reported **2 errors** (`@typescript-eslint/no-var-requires`), blocking a clean lint gate.
- **Impact:** Behavior unchanged; `npm run lint` exits **0 errors** (warnings remain).

## Verification after fixes

- `npm run build` — **pass**
- `npm run lint` — **0 errors**
- `flutter test` — **pass** (port change does not affect unit tests)
