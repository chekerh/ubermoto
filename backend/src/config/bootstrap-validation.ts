/**
 * Fail fast in production when critical secrets/config are missing or unsafe.
 * Call from main.ts before NestFactory.create.
 */
export function validateProductionEnvironment(): void {
  if (process.env.NODE_ENV !== 'production') {
    return;
  }

  const secret = process.env.JWT_SECRET?.trim();
  if (!secret || secret === 'default-secret') {
    throw new Error('Production requires JWT_SECRET to be set to a strong, non-default value.');
  }

  if (!process.env.MONGODB_URI?.trim()) {
    throw new Error('Production requires MONGODB_URI.');
  }
}
