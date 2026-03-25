# Remaining issues

| Item | Severity | Why not fixed now | Next step |
|------|----------|-------------------|-----------|
| Stitch **full** parity on Flutter **web** (StitchBridge / JS inject) | High (for web) | Requires major `postMessage` bridge or different renderer | Product decision; keep mobile as source of truth |
| Backend ESLint **376** warnings | Low | Batch cleanup is noisy / risk of unrelated diffs | Gradual rule fixes or scoped `--max-warnings` in CI |
| Flutter style **infos** (trailing commas, etc.) | Low | Cosmetic | `dart fix --apply` in dedicated PR |
| **Orders / drivers / promo** full HTTP e2e | Medium | Time scope | Add Supertest flows incrementally |
| **Documents** on **S3** (or non-local storage) | Medium | Current API assumes disk under **`uploads/`** | Add storage adapter when moving off local files |
| **Biometric / FCM / maps** | Medium | Device + keys | Manual QA checklist |

## Risks after this pass

- `addProduct` uses **first** merchant returned by API — correct for single-merchant demos; multi-merchant admin may need a picker UI.
- If no category has an **exact** name/slug match, **substring** fallback can still match multiple IDs — prefer aligning UI labels with seeded category names.
