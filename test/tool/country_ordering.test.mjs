import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { test } from 'node:test';

for (const locale of ['en', 'es', 'cy', 'be']) {
  test(`${locale}: country catalogs use full locale collation`, () => {
    const catalog = JSON.parse(readFileSync(new URL(`../../lib/l10n/app_${locale}.arb`, import.meta.url), 'utf8'));
    const countries = catalog.userSignUpCountryOptionsSource.split('\n').map((row) => row.split('\t'));
    const collator = new Intl.Collator(locale);
    // Browsers may omit Welsh/Belarusian collation data and fall back to English.
    assert.equal(collator.resolvedOptions().locale, locale, 'Use the full-ICU Node.js toolchain');
    assert.equal(countries.length, 254);
    assert.equal(new Set(countries.map(([value]) => value)).size, 254);
    for (let index = 1; index < countries.length; index++) {
      const before = countries[index - 1][1];
      const after = countries[index][1];
      assert.ok(collator.compare(before, after) <= 0, `${before} must precede ${after} in ${locale}`);
    }
    const position = (value) => countries.findIndex(([identifier]) => identifier === value);
    if (locale === 'en') assert.ok(position('Åland Islands') < position('Albania'));
    if (locale === 'es') assert.ok(position('Belgium') < position('Belarus'));
    if (locale === 'cy') {
      assert.ok(position('Angola') < position('Albania')); // Welsh ng is one letter, before l.
      assert.ok(position("Cote d'Ivoire") < position('Chile')); // c precedes ch.
    }
    if (locale === 'be') assert.ok(position('Spain') < position('Kazakhstan')); // І precedes К.
  });
}
