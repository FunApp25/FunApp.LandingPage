import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/domain/core/failures/value_failure.dart';
import 'package:fun_app_landing_page/domain/core/validators/value_validators.dart';

void main() {
  group('validateRequiredString', () {
    test('accepts non-empty input without rewriting it', () {
      const input = '  Fun Venue  ';

      expect(
        validateRequiredString(input),
        right<ValueFailure<String>, String>(input),
      );
    });

    test('rejects empty input', () {
      expect(
        validateRequiredString(''),
        left<ValueFailure<String>, String>(
          const ValueFailure.emptyString(failedValue: ''),
        ),
      );
    });

    test('rejects whitespace-only input and retains it', () {
      const input = ' \t ';

      expect(
        validateRequiredString(input),
        left<ValueFailure<String>, String>(
          const ValueFailure.emptyString(failedValue: input),
        ),
      );
    });
  });

  group('validateSingleLine', () {
    test('accepts a single line', () {
      expect(
        validateSingleLine('one line'),
        right<ValueFailure<String>, String>('one line'),
      );
    });

    test('rejects newline and carriage-return input', () {
      for (final input in ['first\nsecond', 'first\rsecond']) {
        expect(
          validateSingleLine(input),
          left<ValueFailure<String>, String>(
            ValueFailure.multiLineString(failedValue: input),
          ),
        );
      }
    });
  });

  group('validateEmail', () {
    test('accepts a representative email address', () {
      const input = 'contact@example.com';

      expect(
        validateEmail(input),
        right<ValueFailure<String>, String>(input),
      );
    });

    test('rejects invalid email formats', () {
      for (final input in ['contact', 'a@b', 'a..b@example.com']) {
        expect(
          validateEmail(input),
          left<ValueFailure<String>, String>(
            ValueFailure.invalidEmail(failedValue: input),
          ),
        );
      }
    });
  });

  group('validateWebsiteUrl', () {
    test('accepts HTTP and HTTPS URLs with hosts', () {
      for (final input in [
        'http://example.com',
        'https://venues.example.com/path?source=fun',
      ]) {
        expect(
          validateWebsiteUrl(input),
          right<ValueFailure<String>, String>(input),
        );
      }
    });

    test('rejects unsupported, hostless, and whitespace-containing URLs', () {
      for (final input in [
        'ftp://example.com',
        'https:///path',
        'https://example.com/a path',
      ]) {
        expect(
          validateWebsiteUrl(input),
          left<ValueFailure<String>, String>(
            ValueFailure.invalidUrl(failedValue: input),
          ),
        );
      }
    });
  });

  group('validateNumericString', () {
    test('accepts digits and preserves leading zeroes', () {
      const input = '0012345';

      expect(
        validateNumericString(input),
        right<ValueFailure<String>, String>(input),
      );
    });

    test('rejects punctuation, signs, and whitespace', () {
      for (final input in ['+123', '12 34', '12-34', ' 123 ']) {
        expect(
          validateNumericString(input),
          left<ValueFailure<String>, String>(
            ValueFailure.invalidNumericInput(failedValue: input),
          ),
        );
      }
    });
  });

  group('validateInteger', () {
    test('parses positive, zero, and negative integral text', () {
      expect(validateInteger('12'), right<ValueFailure<int>, int>(12));
      expect(validateInteger('0'), right<ValueFailure<int>, int>(0));
      expect(validateInteger('-2'), right<ValueFailure<int>, int>(-2));
    });

    test(
      'rejects decimal, signed-positive, whitespace, and overflow input',
      () {
        for (final input in [
          '1.5',
          '+2',
          ' 2 ',
          '999999999999999999999999999999999999',
        ]) {
          expect(
            validateInteger(input),
            left<ValueFailure<int>, int>(
              ValueFailure.invalidNumericInput(failedValue: input),
            ),
          );
        }
      },
    );
  });

  group('validatePositiveInteger', () {
    test('accepts a positive integer', () {
      expect(
        validatePositiveInteger(1),
        right<ValueFailure<int>, int>(1),
      );
    });

    test('rejects zero and negative integers', () {
      for (final input in [0, -1]) {
        expect(
          validatePositiveInteger(input),
          left<ValueFailure<int>, int>(
            ValueFailure.belowMinimum(failedValue: input, minimum: 1),
          ),
        );
      }
    });
  });
}
