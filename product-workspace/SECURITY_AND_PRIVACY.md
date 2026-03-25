## Security and privacy (baseline)

### Auth
- JWT access tokens for API + Socket.IO auth
- Role-based guards server-side
- Plan to add admin MFA (phase 2)

### Authorization
- Principle of least privilege for admin roles
- Entitlements enforced server-side (not just UI)
- WebSocket room access restricted to owner/driver/admin (already improved)

### Uploads (documents)
- Validate MIME and size caps
- Store metadata in DB; store files in `uploads/` for dev
- Path traversal protection on delete (already improved)
- Plan: move to S3 (signed URLs) in production

### Billing webhooks
- Verify Stripe signature
- Store raw event id + hash
- Idempotent processing and safe retries

### Rate limiting / abuse prevention
- Use Nest throttler for auth and write-heavy endpoints
- Add per-IP/per-user limits for login attempts and document uploads

### Privacy
- Data minimization in logs
- Audit logs store safe diffs (no secrets, no tokens)
- Support exports follow least privilege

### Secrets
- Never commit `.env`
- Production env validation requires non-default JWT secret and MONGODB_URI (already present)

