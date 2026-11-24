export const productionAppOrigin = 'https://funapp.world';

/** Returns only the name of the first invalid binding, never its value. */
export function invalidProductionPaymentBinding(env: {
  STRIPE_EXPECTED_LIVEMODE?: string;
  STRIPE_SECRET_KEY?: string;
  PUBLIC_APP_ORIGIN?: string;
  STRIPE_PRICE_ID?: string;
  STRIPE_AUTOMATIC_TAX_ENABLED?: string;
  PURCHASE_REFERENCE_SECRET?: string;
}): string | null {
  if (env.STRIPE_EXPECTED_LIVEMODE !== 'true') {
    return 'STRIPE_EXPECTED_LIVEMODE';
  } else if (!/^rk_live_[A-Za-z0-9]+$/.test(env.STRIPE_SECRET_KEY ?? '')) {
    return 'STRIPE_SECRET_KEY';
  } else if (env.PUBLIC_APP_ORIGIN !== productionAppOrigin) {
    return 'PUBLIC_APP_ORIGIN';
  } else if (!/^price_[A-Za-z0-9]+$/.test(env.STRIPE_PRICE_ID ?? '')) {
    return 'STRIPE_PRICE_ID';
  } else if (
    env.STRIPE_AUTOMATIC_TAX_ENABLED !== 'true' &&
    env.STRIPE_AUTOMATIC_TAX_ENABLED !== 'false'
  ) {
    return 'STRIPE_AUTOMATIC_TAX_ENABLED';
  }

  const secret = env.PURCHASE_REFERENCE_SECRET;
  if (
    typeof secret !== 'string' ||
    secret.length < 32 ||
    secret !== secret.trim() ||
    /[\r\n\u0000]/.test(secret) ||
    secret === 'local-development-only-reference-secret'
  ) {
    return 'PURCHASE_REFERENCE_SECRET';
  }
  return null;
}
