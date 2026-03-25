# Technical debt (remaining)

## High impact

| Item | Detail |
|------|--------|
| WebSocket subscribe authorization | `DeliveryGateway` should reject subscriptions to deliveries the user is not party to |
| ESLint errors | `firebase.service.ts` — replace `require` or scoped eslint-disable |
| npm audit | Many reported vulnerabilities — schedule dependency upgrades |
| Flutter production config | No `--dart-define` / flavors for API base URL |

## Medium impact

| Item | Detail |
|------|--------|
| `VerifiedDriverGuard` unused | Either wire to driver delivery endpoints or remove |
| Duplicate order routes | `GET /orders` vs `GET /orders/history` identical |
| `delivery-matching` / admin analytics | Verify business logic vs stubs |
| Jest open-handle warning | Tests may leak timers — run `--detectOpenHandles` |

## Low impact / quick wins

| Item | Detail |
|------|--------|
| Return types on controllers | ESLint warnings across codebase |
| Root `package.json` | Only `firebase-admin` — clarify or remove |
| `nest build` ENOTEMPTY | Document `rm -rf dist` workaround or fix CLI/cache |
