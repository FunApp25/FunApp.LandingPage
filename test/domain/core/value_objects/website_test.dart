import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/domain/core/failures/value_failure.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/website.dart';

void main() {
  test('accepts domains and HTTPS forms without rewriting input', () {
    for (final input in [
      'example.com',
      'www.example.com',
      'venue.co.uk',
      'example.com/path?source=test',
      'test.com',
      'https://fun.example/venues',
    ]) {
      expect(
        Website(input).value,
        right<ValueFailure<String>, String>(input),
      );
    }
  });

  test('reports empty input before URL format', () {
    expect(
      Website('').value,
      left<ValueFailure<String>, String>(
        const ValueFailure.emptyString(failedValue: ''),
      ),
    );
  });

  test('reports multiline input before URL format', () {
    const input = 'https://example.com\n/path';

    expect(
      Website(input).value,
      left<ValueFailure<String>, String>(
        const ValueFailure.multiLineString(failedValue: input),
      ),
    );
  });

  test('rejects an address without a plausible domain', () {
    const input = 'example';

    expect(
      Website(input).value,
      left<ValueFailure<String>, String>(
        const ValueFailure.invalidUrl(failedValue: input),
      ),
    );
  });

  test('does not silently rewrite or trim a URL', () {
    const input = ' https://example.com ';

    expect(
      Website(input).value,
      left<ValueFailure<String>, String>(
        const ValueFailure.invalidUrl(failedValue: input),
      ),
    );
  });
}
