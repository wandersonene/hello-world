import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen_web.dart';
import 'screens/dashboard_screen_web.dart';
import 'services/google_auth_service_web.dart';
import 'providers/admin_provider.dart';
import 'service_locator_web.dart';

void main() {
  setupServiceLocatorWeb(); // Initialize GetIt for web services
  runApp(const AdminWebApp());
}

class AdminWebApp extends StatelessWidget {
  const AdminWebApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => slWeb<GoogleAuthServiceWeb>()),
        ChangeNotifierProvider(
          create: (context) => AdminProvider(
            slWeb<GoogleAuthServiceWeb>(),
            // DriveServiceWeb will be created inside AdminProvider when user is logged in
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Admin Area - Field Engineer App',
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blueGrey,
            brightness: Brightness.light,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.blueGrey[700],
            foregroundColor: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
          ),
        ),
        initialRoute: LoginScreenWeb.routeName,
        routes: {
          LoginScreenWeb.routeName: (context) => const LoginScreenWeb(),
          DashboardScreenWeb.routeName: (context) => const DashboardScreenWeb(),
          // Add other routes here if needed
        },
        // Simple home logic based on auth state
        home: Consumer<GoogleAuthServiceWeb>(
          builder: (context, authService, _) {
            if (authService.isSignedIn) {
              return const DashboardScreenWeb();
            } else {
              return const LoginScreenWeb();
            }
          },
        ),
      ),
    );
  }
}
