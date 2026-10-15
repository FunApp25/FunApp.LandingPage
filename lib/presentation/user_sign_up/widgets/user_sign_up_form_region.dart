import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fun_app_landing_page/application/user_registration/founding_friend_registration_form_bloc/founding_friend_registration_form_bloc.dart';
import 'package:fun_app_landing_page/application/user_registration/here_and_now_registration_form_bloc/here_and_now_registration_form_bloc.dart';
import 'package:fun_app_landing_page/domain/core/failures/app_failure.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/non_empty_single_line_text.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/models/user_sign_up.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/widgets/user_sign_up_form.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/widgets/user_sign_up_validation_message.dart';

/// Connects the shared form surface to its distinct application workflow.
final class UserSignUpFormRegion extends StatelessWidget {
  /// Creates a form region for [experience].
  const UserSignUpFormRegion({required this.experience, super.key});

  /// Selects the Here & Now or Founding Friend workflow.
  final UserSignUpExperience experience;

  @override
  Widget build(BuildContext context) => switch (experience) {
    UserSignUpExperience.hereAndNow =>
      BlocBuilder<
        HereAndNowRegistrationFormBloc,
        HereAndNowRegistrationFormState
      >(
        builder: _buildHereAndNow,
      ),
    UserSignUpExperience.foundingFriend =>
      BlocBuilder<
        FoundingFriendRegistrationFormBloc,
        FoundingFriendRegistrationFormState
      >(
        builder: _buildFoundingFriend,
      ),
  };

  Widget _buildHereAndNow(
    BuildContext context,
    HereAndNowRegistrationFormState state,
  ) {
    final registration = state.registration;
    final result = _submissionFlags(state.submissionResult);
    final showErrors = state.hasAttemptedSubmit;

    return UserSignUpForm(
      experience: experience,
      gender: _optionalText(registration.gender),
      country: null,
      marketingConsent: registration.marketingConsent,
      isSubmitting: state.isSubmitting,
      submissionSucceeded: result.success,
      hasSubmissionFailure: result.failure,
      firstNameError: showErrors
          ? userSignUpValidationMessage(context.l10n, registration.firstName)
          : null,
      lastNameError: showErrors
          ? userSignUpValidationMessage(context.l10n, registration.lastName)
          : null,
      emailError: showErrors
          ? userSignUpValidationMessage(context.l10n, registration.email)
          : null,
      ageError: showErrors
          ? userSignUpValidationMessage(context.l10n, registration.age)
          : null,
      countryError: null,
      onFirstNameChanged: (value) => context
          .read<HereAndNowRegistrationFormBloc>()
          .add(HereAndNowRegistrationFormEvent.firstNameChanged(value)),
      onLastNameChanged: (value) => context
          .read<HereAndNowRegistrationFormBloc>()
          .add(HereAndNowRegistrationFormEvent.lastNameChanged(value)),
      onEmailChanged: (value) => context
          .read<HereAndNowRegistrationFormBloc>()
          .add(HereAndNowRegistrationFormEvent.emailChanged(value)),
      onAgeChanged: (value) => context
          .read<HereAndNowRegistrationFormBloc>()
          .add(HereAndNowRegistrationFormEvent.ageChanged(value)),
      onGenderChanged: (value) => context
          .read<HereAndNowRegistrationFormBloc>()
          .add(HereAndNowRegistrationFormEvent.genderChanged(value)),
      onCountryChanged: (_) {},
      onUsageReasonChanged: (value) => context
          .read<HereAndNowRegistrationFormBloc>()
          .add(HereAndNowRegistrationFormEvent.usageReasonChanged(value)),
      onMarketingConsentChanged: (value) =>
          context.read<HereAndNowRegistrationFormBloc>().add(
            HereAndNowRegistrationFormEvent.marketingConsentChanged(
              marketingConsent: value,
            ),
          ),
      onSubmit: () => context.read<HereAndNowRegistrationFormBloc>().add(
        const HereAndNowRegistrationFormEvent.submitted(),
      ),
    );
  }

  Widget _buildFoundingFriend(
    BuildContext context,
    FoundingFriendRegistrationFormState state,
  ) {
    final registration = state.registration;
    final result = _submissionFlags(state.submissionResult);
    final showErrors = state.hasAttemptedSubmit;

    return UserSignUpForm(
      experience: experience,
      gender: _optionalText(registration.gender),
      country: registration.country.value.fold((_) => null, (value) => value),
      marketingConsent: registration.marketingConsent,
      isSubmitting: state.isSubmitting,
      submissionSucceeded: result.success,
      hasSubmissionFailure: result.failure,
      firstNameError: showErrors
          ? userSignUpValidationMessage(context.l10n, registration.firstName)
          : null,
      lastNameError: showErrors
          ? userSignUpValidationMessage(context.l10n, registration.lastName)
          : null,
      emailError: showErrors
          ? userSignUpValidationMessage(context.l10n, registration.email)
          : null,
      ageError: showErrors
          ? userSignUpValidationMessage(context.l10n, registration.age)
          : null,
      countryError: showErrors
          ? userSignUpValidationMessage(context.l10n, registration.country)
          : null,
      onFirstNameChanged: (value) => context
          .read<FoundingFriendRegistrationFormBloc>()
          .add(FoundingFriendRegistrationFormEvent.firstNameChanged(value)),
      onLastNameChanged: (value) => context
          .read<FoundingFriendRegistrationFormBloc>()
          .add(FoundingFriendRegistrationFormEvent.lastNameChanged(value)),
      onEmailChanged: (value) => context
          .read<FoundingFriendRegistrationFormBloc>()
          .add(FoundingFriendRegistrationFormEvent.emailChanged(value)),
      onAgeChanged: (value) => context
          .read<FoundingFriendRegistrationFormBloc>()
          .add(FoundingFriendRegistrationFormEvent.ageChanged(value)),
      onGenderChanged: (value) => context
          .read<FoundingFriendRegistrationFormBloc>()
          .add(FoundingFriendRegistrationFormEvent.genderChanged(value)),
      onCountryChanged: (value) => context
          .read<FoundingFriendRegistrationFormBloc>()
          .add(FoundingFriendRegistrationFormEvent.countryChanged(value)),
      onUsageReasonChanged: (value) => context
          .read<FoundingFriendRegistrationFormBloc>()
          .add(FoundingFriendRegistrationFormEvent.usageReasonChanged(value)),
      onMarketingConsentChanged: (value) =>
          context.read<FoundingFriendRegistrationFormBloc>().add(
            FoundingFriendRegistrationFormEvent.marketingConsentChanged(
              marketingConsent: value,
            ),
          ),
      onSubmit: () => context.read<FoundingFriendRegistrationFormBloc>().add(
        const FoundingFriendRegistrationFormEvent.submitted(),
      ),
    );
  }

  String? _optionalText(Option<NonEmptySingleLineText> value) => value.fold(
    () => null,
    (text) => text.value.fold((_) => null, (valid) => valid),
  );

  ({bool success, bool failure}) _submissionFlags(
    Option<Either<AppFailure, Unit>> result,
  ) => result.fold(
    () => (success: false, failure: false),
    (settled) => settled.fold(
      (_) => (success: false, failure: true),
      (_) => (success: true, failure: false),
    ),
  );
}
