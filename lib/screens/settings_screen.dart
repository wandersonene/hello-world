import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/google_auth_service.dart';

class SettingsScreen extends StatelessWidget {
  static const String routeName = '/settings';

  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<GoogleAuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Conta Google',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            authService.isSignedIn
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Logado como: ${authService.currentUser?.displayName ?? authService.currentUser?.email ?? 'Usuário Desconhecido'}'),
                      if (authService.currentUser?.email != null)
                        Text('Email: ${authService.currentUser!.email}'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            await authService.signOut();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Logout realizado com sucesso!')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erro ao fazer logout: $e')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                        child: const Text('Logout do Google'),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Você não está logado com uma conta Google.'),
                      const SizedBox(height: 10),
                      Text(
                        'Faça login para sincronizar seus projetos com o Google Drive.',
                         style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            final user = await authService.signIn();
                            if (user != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Login com Google bem-sucedido como ${user.displayName ?? user.email}!')),
                              );
                            } else {
                               ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Login com Google cancelado ou falhou.')),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erro durante o login: $e')),
                            );
                          }
                        },
                        child: const Text('Login com Google'),
                      ),
                    ],
                  ),
            const SizedBox(height: 30),
            // Placeholder for other settings
            // Text(
            //   'Outras Configurações',
            //   style: Theme.of(context).textTheme.titleLarge,
            // ),
            // ListTile(
            //   title: Text('Configuração X'),
            //   subtitle: Text('Detalhe da configuração X'),
            //   onTap: () {},
            // ),
          ],
        ),
      ),
    );
  }
}
