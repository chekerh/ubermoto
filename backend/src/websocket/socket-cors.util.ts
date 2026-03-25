/**
 * Socket.IO CORS: dev allows all; production requires explicit allowlist via env.
 * Set `WEBSOCKET_CORS_ORIGINS` or reuse `FRONTEND_ORIGINS` (comma-separated).
 */
export function resolveSocketIoCorsOrigin(): boolean | string[] {
  const isProd = process.env.NODE_ENV === 'production';
  const raw = (process.env.WEBSOCKET_CORS_ORIGINS ?? process.env.FRONTEND_ORIGINS ?? '')
    .split(',')
    .map((s) => s.trim())
    .filter((s) => s.length > 0);
  if (!isProd) {
    return true;
  }
  return raw.length > 0 ? raw : false;
}
