export const productionAppOrigin = 'https://funapp.world';
export const expectedCurrency = 'gbp';
export const expectedAmount = 24_900;
export const stripeApiVersion = '2026-08-26.dahlia';

export interface StripePrice {
  id?: unknown;
  object?: unknown;
  active?: unknown;
  currency?: unknown;
  livemode?: unknown;
  type?: unknown;
  unit_amount?: unknown;
  billing_scheme?: unknown;
  custom_unit_amount?: unknown;
  tax_behavior?: unknown;
}

export function matchesCheckoutPrice(
  price: StripePrice,
  priceId: string,
  expectedLivemode: boolean,
): boolean {
  return price.object === 'price' &&
    price.id === priceId &&
    price.active === true &&
    price.currency === expectedCurrency &&
    price.livemode === expectedLivemode &&
    price.type === 'one_time' &&
    price.unit_amount === expectedAmount &&
    price.billing_scheme === 'per_unit' &&
    price.tax_behavior === 'inclusive' &&
    (price.custom_unit_amount === null || price.custom_unit_amount === undefined);
}

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
