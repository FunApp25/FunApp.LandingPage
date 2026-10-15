import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/data/user_registration/deferred_founding_friend_registration_repository.dart';
import 'package:fun_app_landing_page/data/user_registration/deferred_here_and_now_registration_repository.dart';
import 'package:fun_app_landing_page/domain/core/failures/app_failure.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/age.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/email_address.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/non_empty_single_line_text.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/personal_name.dart';
import 'package:fun_app_landing_page/domain/user_registration/entities/founding_friend_registration.dart';
import 'package:fun_app_landing_page/domain/user_registration/entities/here_and_now_registration.dart';

void main() {
  test('Here & Now stays fail-closed before Stage 3', () async {
    final result = await DeferredHereAndNowRegistrationRepository()
        .submitHereAndNowRegistration(
          HereAndNowRegistration(
            firstName: PersonalName('Alex'),
            lastName: PersonalName('Morgan'),
            email: EmailAddress('alex@example.com'),
            age: Age('29'),
            gender: none(),
            usageReason: none(),
            marketingConsent: false,
          ),
        );

    expect(
      result,
      left<AppFailure, Unit>(const AppFailure.serviceUnavailable()),
    );
  });

  test('Founding Friend stays fail-closed before Stage 3', () async {
    final result = await DeferredFoundingFriendRegistrationRepository()
        .submitFoundingFriendRegistration(
          FoundingFriendRegistration(
            firstName: PersonalName('Taylor'),
            lastName: PersonalName('Jones'),
            email: EmailAddress('taylor@example.com'),
            age: Age('31'),
            country: NonEmptySingleLineText('Afghanistan'),
            gender: none(),
            usageReason: none(),
            marketingConsent: true,
          ),
        );

    expect(
      result,
      left<AppFailure, Unit>(const AppFailure.serviceUnavailable()),
    );
  });
}
