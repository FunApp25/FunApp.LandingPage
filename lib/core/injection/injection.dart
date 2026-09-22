import 'package:fun_app_landing_page/core/config/app_environment.dart';
import 'package:fun_app_landing_page/core/injection/injection.config.dart';
import 'package:fun_app_landing_page/data/venue/data_sources/development_venue_lead_data_source.dart';
import 'package:fun_app_landing_page/data/venue/data_sources/production_venue_lead_data_source.dart';
import 'package:fun_app_landing_page/data/venue/data_sources/venue_lead_data_source_interface.dart';
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
  ignoreUnregisteredTypes: [VenueLeadDataSourceInterface],
)
void configureDependencies(
  AppEnvironment environment, {
  http.Client? productionHttpClient,
}) {
  if (environment == AppEnvironment.development) {
    getIt.registerLazySingleton<VenueLeadDataSourceInterface>(
      DevelopmentVenueLeadDataSource.new,
    );
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
  }

  getIt.init();
}
