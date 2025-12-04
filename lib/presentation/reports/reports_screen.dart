import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'report_provider.dart';
import '../../data/models/report_model.dart';
import '../../data/models/project_model.dart';
import '../projects/project_provider.dart';
import 'generate_report_screen.dart';
import '../../config/api_config.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
      final reportProvider = Provider.of<ReportProvider>(context, listen: false);
      
      if (projectProvider.projects.isEmpty) {
        projectProvider.loadProjects();
      }
      
      if (reportProvider.selectedProjectId != null) {
        reportProvider.loadReports();
      }
    });
  }

  Future<void> _downloadReport(ReportModel report) async {
    if (report.filePath == null) return;

    final url = report.filePath!.startsWith('http')
        ? report.filePath!
        : '${ApiConfig.baseUrl.replaceAll('/api', '')}/storage/${report.filePath}';

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'ouverture: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapports'),
        actions: [
          Consumer<ReportProvider>(
            builder: (context, reportProvider, _) {
              if (reportProvider.selectedProjectId == null) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => GenerateReportScreen(
                        projectId: reportProvider.selectedProjectId!,
                      ),
                    ),
                  ).then((_) {
                    reportProvider.loadReports();
                  });
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Sélection du projet
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFB41839).withAlpha((255 * 0.1).round()),
                  const Color(0xFF3F1B3D).withAlpha((255 * 0.1).round()),
                ],
              ),
            ),
            child: Consumer<ProjectProvider>(
              builder: (context, projectProvider, _) {
                return Consumer<ReportProvider>(
                  builder: (context, reportProvider, _) {
                    if (projectProvider.projects.isEmpty) {
                      return const Text('Aucun projet disponible');
                    }

                    return DropdownButtonFormField<ProjectModel>(
                      value: projectProvider.projects.firstWhere(
                        (p) => p.id == reportProvider.selectedProjectId,
                        orElse: () => projectProvider.projects.first,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Sélectionner un projet',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: projectProvider.projects.map((project) {
                        return DropdownMenuItem<ProjectModel>(
                          value: project,
                          child: Text(project.name),
                        );
                      }).toList(),
                      onChanged: (project) {
                        reportProvider.setSelectedProject(project?.id);
                        reportProvider.loadReports();
                      },
                    );
                  },
                );
              },
            ),
          ),

          // Liste des rapports
          Expanded(
            child: Consumer<ReportProvider>(
              builder: (context, reportProvider, _) {
                if (reportProvider.selectedProjectId == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.description, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Sélectionnez un projet pour voir les rapports',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (reportProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (reportProvider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          reportProvider.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            reportProvider.clearError();
                            reportProvider.loadReports();
                          },
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }

                if (reportProvider.reports.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.description_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text(
                          'Aucun rapport généré',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => GenerateReportScreen(
                                  projectId: reportProvider.selectedProjectId!,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Générer un rapport'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => reportProvider.loadReports(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: reportProvider.reports.length,
                    itemBuilder: (context, index) {
                      final report = reportProvider.reports[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.indigo.withAlpha((255 * 0.1).round()),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.description,
                              color: Colors.indigo,
                            ),
                          ),
                          title: Text(
                            report.typeLabel,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Date: ${_formatDate(report.reportDate)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (report.endDate != null)
                                Text(
                                  'Jusqu\'au: ${_formatDate(report.endDate!)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              if (report.creator != null)
                                Text(
                                  'Par ${report.creator!.name}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                  ),
                                ),
                            ],
                          ),
                          trailing: report.filePath != null
                              ? IconButton(
                                  icon: const Icon(Icons.download),
                                  onPressed: () => _downloadReport(report),
                                )
                              : const Icon(Icons.file_download_outlined, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}


