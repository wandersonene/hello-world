import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'service_locator.dart';
import 'services/database_service.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/project_list_screen.dart';
import 'screens/new_edit_project_screen.dart';
import 'screens/settings_screen.dart'; // Added SettingsScreen
import 'providers/project_provider.dart';
import 'services/google_auth_service.dart'; // Added GoogleAuthService


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  await sl<DatabaseService>().database; // Ensure database is initialized

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @super
  Widget build(BuildContext context) {
    return MultiProvider( // Changed to MultiProvider
      providers: [
        ChangeNotifierProvider(create: (context) => ProjectProvider()),
        ChangeNotifierProvider(create: (context) => GoogleAuthService()), // Added GoogleAuthService
      ],
      child: MaterialApp(
        title: 'Field Engineer App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo), // Changed seed color
          useMaterial3: true,
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            // filled: true, // Decided against default fill for cleaner look
            // fillColor: Colors.grey[150],
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              // minimumSize: const Size(double.infinity, 48), // Removed for more flexible button sizes
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0), // Adjusted padding
              backgroundColor: Colors.indigo, // Button color
              foregroundColor: Colors.white, // Text color on buttons
            ),
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.indigoAccent,
             foregroundColor: Colors.white,
          )
        ),
        initialRoute: LoginScreen.routeName,
        routes: {
          LoginScreen.routeName: (context) => const LoginScreen(),
          RegistrationScreen.routeName: (context) => const RegistrationScreen(),
          ProjectListScreen.routeName: (context) {
            final String? userName = ModalRoute.of(context)?.settings.arguments as String? ?? "User";
            return ProjectListScreen(userName: userName);
          },
          NewEditProjectScreen.routeNameAdd: (context) => const NewEditProjectScreen(),
          SettingsScreen.routeName: (context) => const SettingsScreen(), // Added SettingsScreen route
        },
        onGenerateRoute: (settings) {
          if (settings.name == ProjectListScreen.routeName) {
            final String userName = settings.arguments as String? ?? 'User';
            return MaterialPageRoute(
              builder: (context) {
                return ProjectListScreen(userName: userName);
              },
            );
          }
          if (settings.name == NewEditProjectScreen.routeNameEdit) {
            final projectToEdit = settings.arguments as Project?; // Ensure Project model is imported if not already
            return MaterialPageRoute(
              builder: (context) {
                return NewEditProjectScreen(projectToEdit: projectToEdit);
              },
            );
          }
          // Fallback for other routes or unhandled named routes
          // assert(false, 'Need to implement ${settings.name}');
          return MaterialPageRoute(builder: (_) => const LoginScreen()); // Default fallback
        },
      ),
    );
  }
}
