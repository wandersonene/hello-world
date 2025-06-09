import 'package:get_it/get_it.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'services/google_auth_service.dart'; // Added GoogleAuthService

final GetIt sl = GetIt.instance; // sl is short for Service Locator

void setupServiceLocator() {
  // Services
  sl.registerLazySingleton<DatabaseService>(() => DatabaseService());
  sl.registerLazySingleton<AuthService>(() => AuthService(sl<DatabaseService>()));
  sl.registerLazySingleton<GoogleAuthService>(() => GoogleAuthService()); // Added GoogleAuthService

  // You can also register ViewModels or BLoCs here if you use them
  // e.g. sl.registerFactory(() => LoginViewModel(authService: sl()));
}
