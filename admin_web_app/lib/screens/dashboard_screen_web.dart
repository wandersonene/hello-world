import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; // For opening links
import 'package:intl/intl.dart'; // For date formatting

import '../providers/admin_provider.dart';
import '../models/drive_project_model.dart';
import '../services/google_auth_service_web.dart';
import 'login_screen_web.dart';

class DashboardScreenWeb extends StatefulWidget {
  static const String routeName = '/dashboard';

  const DashboardScreenWeb({Key? key}) : super(key: key);

  @override
  State<DashboardScreenWeb> createState() => _DashboardScreenWebState();
}

class _DashboardScreenWebState extends State<DashboardScreenWeb> {
  @override
  void initState() {
    super.initState();
    // Fetch projects when the screen loads, if user is signed in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = Provider.of<GoogleAuthServiceWeb>(context, listen: false);
      if (authService.isSignedIn) {
        Provider.of<AdminProvider>(context, listen: false).fetchProjectsFromDrive();
      }
    });
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, webOnlyWindowName: '_blank')) {
      throw Exception('Could not launch $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<GoogleAuthServiceWeb>(context);
    final adminProvider = Provider.of<AdminProvider>(context);

    if (!authService.isSignedIn) {
      // This should ideally be handled by the router in main.dart,
      // but as a fallback:
      return const LoginScreenWeb(); 
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard - Projetos no Drive'),
        actions: [
          if (authService.currentUser != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Chip(
                avatar: CircleAvatar(
                  backgroundImage: NetworkImage(authService.currentUser!.photoUrl ?? ''),
                  onBackgroundImageError: (_, __) {}, // Handle error loading image
                ),
                label: Text(authService.currentUser!.displayName ?? authService.currentUser!.email.split('@').first),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await authService.signOut();
              // Navigator.of(context).pushReplacementNamed(LoginScreenWeb.routeName); // Handled by Consumer in main.dart
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => adminProvider.fetchProjectsFromDrive(),
        child: _buildProjectList(context, adminProvider),
      ),
    );
  }

  Widget _buildProjectList(BuildContext context, AdminProvider adminProvider) {
    if (adminProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (adminProvider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Erro ao carregar projetos: ${adminProvider.errorMessage}', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => adminProvider.fetchProjectsFromDrive(),
              child: const Text('Tentar Novamente'),
            )
          ],
        ),
      );
    }

    if (adminProvider.driveProjects.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum projeto encontrado na pasta "AplicativoDeComissionamento" do Google Drive.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    // Simple sort by name for now
    // adminProvider.driveProjects.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
    // Or by modifiedTime (more recent first)
    adminProvider.driveProjects.sort((a, b) {
        if (a.modifiedTime == null && b.modifiedTime == null) return 0;
        if (a.modifiedTime == null) return 1; // Nulls last
        if (b.modifiedTime == null) return -1; // Nulls last
        return b.modifiedTime!.compareTo(a.modifiedTime!); // Descending
    });


    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: adminProvider.driveProjects.length,
      itemBuilder: (context, index) {
        final project = adminProvider.driveProjects[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (project.modifiedTime != null)
                  Text(
                    'Última Modificação (Drive): ${DateFormat('dd/MM/yyyy HH:mm').format(project.modifiedTime!.toLocal())}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                const SizedBox(height: 8),
                 if (project.reportPdf != null && project.reportPdf!.webViewLink != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: Text(project.reportPdf!.name ?? 'Abrir Relatório'),
                      onPressed: () => _launchUrl(project.reportPdf!.webViewLink!),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(fontSize: 14),
                      ),
                    ),
                  )
                else
                  const Text('Relatório PDF principal não encontrado ou link indisponível.', style: TextStyle(fontStyle: FontStyle.italic)),
                
                if (project.photoCount > 0) ...[
                  const SizedBox(height: 8),
                  Text('Fotos Sincronizadas: ${project.photoCount}', style: Theme.of(context).textTheme.bodyMedium),
                ],
                // Optional: Button to view more details or list photos (for later enhancement)
                // if (project.webViewLink != null)
                //   Align(
                //     alignment: Alignment.centerRight,
                //     child: TextButton.icon(
                //       icon: const Icon(Icons.folder_open_outlined),
                //       label: const Text('Abrir Pasta do Projeto'),
                //       onPressed: () => _launchUrl(project.webViewLink!),
                //     ),
                //   )
              ],
            ),
          ),
        );
      },
    );
  }
}
