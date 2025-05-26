import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/google_auth_service_web.dart';
import 'dashboard_screen_web.dart';

class LoginScreenWeb extends StatelessWidget {
  static const String routeName = '/login';

  const LoginScreenWeb({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<GoogleAuthServiceWeb>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Login - Field Engineer App'),
      ),
      body: Center(
        child: authService.isSignedIn
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Logado como: ${authService.currentUser?.displayName ?? authService.currentUser?.email}'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed(DashboardScreenWeb.routeName);
                    },
                    child: const Text('Ir para o Dashboard'),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () async {
                      try {
                        await authService.signOut();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Logout realizado.')),
                        );
                      } catch (e) {
                         ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erro no logout: $e')),
                        );
                      }
                    },
                    child: const Text('Logout'),
                  ),
                ],
              )
            : ElevatedButton.icon(
                icon: const Icon(Icons.login), // Placeholder, ideally a Google icon
                label: const Text('Login com Google'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: () async {
                  try {
                    final user = await authService.signIn();
                    if (user != null && context.mounted) {
                      Navigator.of(context).pushReplacementNamed(DashboardScreenWeb.routeName);
                    } else if (context.mounted) {
                       ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Login cancelado ou falhou.')),
                      );
                    }
                  } catch (e) {
                     if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erro durante o login: $e')),
                        );
                     }
                  }
                },
              ),
      ),
    );
  }
}
