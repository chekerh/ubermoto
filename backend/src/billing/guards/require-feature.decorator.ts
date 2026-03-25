import { SetMetadata } from '@nestjs/common';

export const REQUIRE_FEATURE_KEY = 'require_feature';

export function RequireFeature(featureKey: string) {
  return SetMetadata(REQUIRE_FEATURE_KEY, featureKey);
}
