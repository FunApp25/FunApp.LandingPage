import 'package:fun_app_landing_page/application/user_registration/founding_friend_registration_form_bloc/founding_friend_registration_form_bloc.dart';
import 'package:fun_app_landing_page/application/user_registration/here_and_now_registration_form_bloc/here_and_now_registration_form_bloc.dart';
import 'package:fun_app_landing_page/core/config/app_environment.dart';
import 'package:fun_app_landing_page/core/config/hubspot_registration_forms_config.dart';
import 'package:fun_app_landing_page/core/injection/injection.config.dart';
import 'package:fun_app_landing_page/data/user_registration/data_sources/hubspot_user_registration_data_source.dart';
import 'package:fun_app_landing_page/data/user_registration/data_sources/user_registration_data_source_interface.dart';
import 'package:fun_app_landing_page/data/user_registration/deferred_founding_friend_registration_repository.dart';
import 'package:fun_app_landing_page/data/user_registration/deferred_here_and_now_registration_repository.dart';
import 'package:fun_app_landing_page/data/user_registration/founding_friend_registration_repository.dart';
import 'package:fun_app_landing_page/data/user_registration/here_and_now_registration_repository.dart';
import 'package:fun_app_landing_page/data/venue/data_sources/development_venue_lead_data_source.dart';
import 'package:fun_app_landing_page/data/venue/data_sources/production_venue_lead_data_source.dart';
import 'package:fun_app_landing_page/data/venue/data_sources/venue_lead_data_source_interface.dart';
import 'package:fun_app_landing_page/domain/user_registration/founding_friend_registration_repository_interface.dart';
import 'package:fun_app_landing_page/domain/user_registration/here_and_now_registration_repository_interface.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

/// Shared dependency container configured once during application bootstrap.
final GetIt getIt = GetIt.instance;

/// Registers dependencies for the selected [environment].
///
/// Production overrides support deterministic composition tests without
/// changing the application transport used by the browser.
@InjectableInit(
  preferRelativeImports: true,
  ignoreUnregisteredTypes: [
    VenueLeadDataSourceInterface,
    HereAndNowRegistrationRepositoryInterface,
    FoundingFriendRegistrationRepositoryInterface,
  ],
)
void configureDependencies(
  AppEnvironment environment, {
  http.Client? productionHttpClient,
  http.Client? developmentRegistrationHttpClient,
  HubSpotRegistrationFormsConfig? developmentHubSpotConfig,
}) {
  if (environment == AppEnvironment.development) {
    getIt.registerLazySingleton<VenueLeadDataSourceInterface>(
      DevelopmentVenueLeadDataSource.new,
    );
    final hubSpotConfig =
        developmentHubSpotConfig ??
        HubSpotRegistrationFormsConfig.fromEnvironment();

    if (hubSpotConfig == null) {
      _registerDeferredUserRegistrationRepositories();
    } else {
      getIt
        ..registerLazySingleton<http.Client>(
          () => developmentRegistrationHttpClient ?? http.Client(),
          dispose: (client) => client.close(),
        )
        ..registerLazySingleton<UserRegistrationDataSourceInterface>(
          () => HubSpotUserRegistrationDataSource(
            client: getIt<http.Client>(),
            config: hubSpotConfig,
          ),
        )
        ..registerLazySingleton<HereAndNowRegistrationRepositoryInterface>(
          () => HereAndNowRegistrationRepository(
            getIt<UserRegistrationDataSourceInterface>(),
          ),
        )
        ..registerLazySingleton<FoundingFriendRegistrationRepositoryInterface>(
          () => FoundingFriendRegistrationRepository(
            getIt<UserRegistrationDataSourceInterface>(),
          ),
        );
    }
  } else {
    getIt
      ..registerLazySingleton<http.Client>(
        () => productionHttpClient ?? http.Client(),
        dispose: (client) => client.close(),
      )
      ..registerLazySingleton<VenueLeadDataSourceInterface>(
        () => ProductionVenueLeadDataSource(
          client: getIt<http.Client>(),
        ),
      );
    _registerDeferredUserRegistrationRepositories();
  }

  getIt.init();
}

void _registerDeferredUserRegistrationRepositories() {
  getIt
    ..registerLazySingleton<HereAndNowRegistrationRepositoryInterface>(
      DeferredHereAndNowRegistrationRepository.new,
    )
    ..registerLazySingleton<FoundingFriendRegistrationRepositoryInterface>(
      DeferredFoundingFriendRegistrationRepository.new,
    );
}

/// Resolves the configured Here & Now BLoC or a fail-closed widget-test graph.
HereAndNowRegistrationFormBloc createDefaultHereAndNowRegistrationFormBloc() {
  if (getIt.isRegistered<HereAndNowRegistrationFormBloc>()) {
    return getIt<HereAndNowRegistrationFormBloc>();
  } else {
    return HereAndNowRegistrationFormBloc(
      DeferredHereAndNowRegistrationRepository(),
    );
  }
}

/// Resolves the configured Founding Friend BLoC or a fail-closed test graph.
FoundingFriendRegistrationFormBloc
createDefaultFoundingFriendRegistrationFormBloc() {
  if (getIt.isRegistered<FoundingFriendRegistrationFormBloc>()) {
    return getIt<FoundingFriendRegistrationFormBloc>();
  } else {
    return FoundingFriendRegistrationFormBloc(
      DeferredFoundingFriendRegistrationRepository(),
    );
  }
}
