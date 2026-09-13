import 'package:fun_app_landing_page/core/config/app_environment.dart';
import 'package:fun_app_landing_page/core/config/hubspot_forms_config.dart';
import 'package:fun_app_landing_page/core/injection/injection.config.dart';
import 'package:fun_app_landing_page/data/venue/data_sources/hubspot_venue_lead_data_source.dart';
import 'package:fun_app_landing_page/data/venue/data_sources/venue_lead_data_source_interface.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

/// Shared dependency container configured once during application bootstrap.
final GetIt getIt = GetIt.instance;

/// Registers dependencies for the selected [environment].
///
/// Production overrides support deterministic composition tests without
/// changing the compile-time configuration used by the application.
@InjectableInit(
  preferRelativeImports: true,
)
void configureDependencies(
  AppEnvironment environment, {
  HubSpotFormsConfig? productionHubSpotConfig,
  http.Client? productionHttpClient,
}) {
  if (environment == AppEnvironment.production) {
    final hubSpotConfig =
        productionHubSpotConfig ?? HubSpotFormsConfig.fromEnvironment();

    getIt
      ..registerSingleton<HubSpotFormsConfig>(hubSpotConfig)
      ..registerLazySingleton<http.Client>(
        () => productionHttpClient ?? http.Client(),
        dispose: (client) => client.close(),
      )
      ..registerLazySingleton<VenueLeadDataSourceInterface>(
        () => HubSpotVenueLeadDataSource(
          getIt<http.Client>(),
          getIt<HubSpotFormsConfig>(),
        ),
      );
  }

  getIt.init(environment: environment.name);
}
