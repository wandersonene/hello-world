import 'package:get_it/get_it.dart';
import 'services/google_auth_service_web.dart';
// DriveServiceWeb is not registered as a singleton here because its lifecycle
// is tied to the GoogleAuthServiceWeb's current user.
// AdminProvider will create it when needed.

final GetIt slWeb = GetIt.instance;

void setupServiceLocatorWeb() {
  // Services
  slWeb.registerLazySingleton<GoogleAuthServiceWeb>(() => GoogleAuthServiceWeb());

  // Providers can also be registered if not using Provider package at root,
  // but for this setup, AdminProvider is created by MultiProvider in main.dart.
  // slWeb.registerLazySingleton<AdminProvider>(() => AdminProvider(slWeb<GoogleAuthServiceWeb>()));
}
