import 'package:fun_app_landing_page/application/founding_friend_payment/founding_friend_checkout_bloc.dart';
import 'package:fun_app_landing_page/application/founding_friend_payment/founding_friend_payment_status_bloc.dart';
import 'package:fun_app_landing_page/application/user_registration/founding_friend_registration_form_bloc/founding_friend_registration_form_bloc.dart';
import 'package:fun_app_landing_page/application/user_registration/here_and_now_registration_form_bloc/here_and_now_registration_form_bloc.dart';
import 'package:fun_app_landing_page/core/config/app_environment.dart';
import 'package:fun_app_landing_page/core/config/development_registration_transport.dart';
import 'package:fun_app_landing_page/core/config/founding_friend_payment_config.dart';
import 'package:fun_app_landing_page/core/config/hubspot_registration_forms_config.dart';
import 'package:fun_app_landing_page/core/injection/injection.config.dart';
import 'package:fun_app_landing_page/data/founding_friend_payment/data_sources/founding_friend_payment_data_source_interface.dart';
import 'package:fun_app_landing_page/data/founding_friend_payment/data_sources/worker_founding_friend_payment_data_source.dart';
import 'package:fun_app_landing_page/data/founding_friend_payment/deferred_founding_friend_payment_repository.dart';
import 'package:fun_app_landing_page/data/founding_friend_payment/founding_friend_payment_repository.dart';
import 'package:fun_app_landing_page/data/founding_friend_payment/session_pending_founding_friend_payment_store.dart';
import 'package:fun_app_landing_page/data/user_registration/data_sources/hubspot_user_registration_data_source.dart';
import 'package:fun_app_landing_page/data/user_registration/data_sources/user_registration_data_source_interface.dart';
import 'package:fun_app_landing_page/data/user_registration/data_sources/worker_user_registration_data_source.dart';
import 'package:fun_app_landing_page/data/user_registration/deferred_founding_friend_registration_repository.dart';
import 'package:fun_app_landing_page/data/user_registration/deferred_here_and_now_registration_repository.dart';
import 'package:fun_app_landing_page/data/user_registration/founding_friend_registration_repository.dart';
import 'package:fun_app_landing_page/data/user_registration/here_and_now_registration_repository.dart';
import 'package:fun_app_landing_page/data/venue/data_sources/development_venue_lead_data_source.dart';
import 'package:fun_app_landing_page/data/venue/data_sources/production_venue_lead_data_source.dart';
import 'package:fun_app_landing_page/data/venue/data_sources/venue_lead_data_source_interface.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/founding_friend_payment_repository_interface.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/pending_founding_friend_payment_store_interface.dart';
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
    FoundingFriendPaymentRepositoryInterface,
    PendingFoundingFriendPaymentStoreInterface,
  ],
)
void configureDependencies(
  AppEnvironment environment, {
  http.Client? productionHttpClient,
  http.Client? developmentRegistrationHttpClient,
  DevelopmentRegistrationTransport? developmentRegistrationTransport,
  HubSpotRegistrationFormsConfig? developmentHubSpotConfig,
  LocalRegistrationWorkerConfig? developmentWorkerConfig,
  DevelopmentPaymentTransport? developmentPaymentTransport,
  FoundingFriendPaymentConfig? developmentPaymentConfig,
  FoundingFriendPaymentConfig? productionPaymentConfig,
}) {
  if (environment == AppEnvironment.development) {
    getIt.registerLazySingleton<VenueLeadDataSourceInterface>(
      DevelopmentVenueLeadDataSource.new,
    );
    final registrationTransport =
        developmentRegistrationTransport ??
        DevelopmentRegistrationTransport.fromEnvironment();

    if (registrationTransport == DevelopmentRegistrationTransport.deferred) {
      _registerDeferredUserRegistrationRepositories();
    } else if (registrationTransport ==
        DevelopmentRegistrationTransport.directHubSpot) {
      final hubSpotConfig =
          developmentHubSpotConfig ??
          HubSpotRegistrationFormsConfig.fromEnvironment();

      if (hubSpotConfig == null) {
        throw StateError(
          'Direct HubSpot registration requires complete configuration.',
        );
      }

      _registerDevelopmentRegistrationDataSource(
        dataSource: (client) => HubSpotUserRegistrationDataSource(
          client: client,
          config: hubSpotConfig,
        ),
        httpClient: developmentRegistrationHttpClient,
      );
    } else {
      final workerConfig =
          developmentWorkerConfig ??
          LocalRegistrationWorkerConfig.fromEnvironment();
      _registerDevelopmentRegistrationDataSource(
        dataSource: (client) => WorkerUserRegistrationDataSource(
          client: client,
          config: workerConfig,
        ),
        httpClient: developmentRegistrationHttpClient,
      );
    }

    final paymentTransport =
        developmentPaymentTransport ??
        DevelopmentPaymentTransport.fromEnvironment();
    if (paymentTransport == DevelopmentPaymentTransport.localWorker) {
      _registerWorkerPaymentRepository(
        developmentPaymentConfig ??
            FoundingFriendPaymentConfig.localFromEnvironment(),
        httpClient: developmentRegistrationHttpClient,
      );
    } else {
      _registerDeferredPaymentRepository();
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
    _registerWorkerPaymentRepository(
      productionPaymentConfig ?? FoundingFriendPaymentConfig.production(),
    );
  }

  getIt
    ..registerLazySingleton<PendingFoundingFriendPaymentStoreInterface>(
      SessionPendingFoundingFriendPaymentStore.new,
    )
    ..init();
}

void _registerDevelopmentRegistrationDataSource({
  required UserRegistrationDataSourceInterface Function(http.Client client)
  dataSource,
  required http.Client? httpClient,
}) {
  _ensureHttpClient(httpClient);
  getIt
    ..registerLazySingleton<UserRegistrationDataSourceInterface>(
      () => dataSource(getIt<http.Client>()),
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

void _registerWorkerPaymentRepository(
  FoundingFriendPaymentConfig config, {
  http.Client? httpClient,
}) {
  _ensureHttpClient(httpClient);
  getIt
    ..registerLazySingleton<FoundingFriendPaymentDataSourceInterface>(
      () => WorkerFoundingFriendPaymentDataSource(
        client: getIt<http.Client>(),
        config: config,
      ),
    )
    ..registerLazySingleton<FoundingFriendPaymentRepositoryInterface>(
      () => FoundingFriendPaymentRepository(
        getIt<FoundingFriendPaymentDataSourceInterface>(),
      ),
    );
}

void _registerDeferredPaymentRepository() {
  getIt.registerLazySingleton<FoundingFriendPaymentRepositoryInterface>(
    DeferredFoundingFriendPaymentRepository.new,
  );
}

void _ensureHttpClient(http.Client? httpClient) {
  if (!getIt.isRegistered<http.Client>()) {
    getIt.registerLazySingleton<http.Client>(
      () => httpClient ?? http.Client(),
      dispose: (client) => client.close(),
    );
  }
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

/// Resolves a Checkout BLoC with fail-closed defaults for widget tests.
FoundingFriendCheckoutBloc createDefaultFoundingFriendCheckoutBloc() =>
    FoundingFriendCheckoutBloc(
      repository: getIt.isRegistered<FoundingFriendPaymentRepositoryInterface>()
          ? getIt<FoundingFriendPaymentRepositoryInterface>()
          : DeferredFoundingFriendPaymentRepository(),
      pendingStore:
          getIt.isRegistered<PendingFoundingFriendPaymentStoreInterface>()
          ? getIt<PendingFoundingFriendPaymentStoreInterface>()
          : const SessionPendingFoundingFriendPaymentStore(),
    );

/// Resolves a return-page verification BLoC with fail-closed defaults.
FoundingFriendPaymentStatusBloc
createDefaultFoundingFriendPaymentStatusBloc() =>
    FoundingFriendPaymentStatusBloc(
      repository: getIt.isRegistered<FoundingFriendPaymentRepositoryInterface>()
          ? getIt<FoundingFriendPaymentRepositoryInterface>()
          : DeferredFoundingFriendPaymentRepository(),
      pendingStore:
          getIt.isRegistered<PendingFoundingFriendPaymentStoreInterface>()
          ? getIt<PendingFoundingFriendPaymentStoreInterface>()
          : const SessionPendingFoundingFriendPaymentStore(),
    );
