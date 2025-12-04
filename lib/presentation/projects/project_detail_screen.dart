import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'project_provider.dart';

class ProjectDetailScreen extends StatefulWidget {
  final int projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProjectProvider>(context, listen: false)
          .loadProject(widget.projectId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du Projet'),
      ),
      body: Consumer<ProjectProvider>(
        builder: (context, projectProvider, _) {
          if (projectProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final project = projectProvider.selectedProject;
          if (project == null) {
            return const Center(
              child: Text('Projet non trouvé'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                project.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(project.status)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                project.statusLabel,
                                style: TextStyle(
                                  color: _getStatusColor(project.status),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (project.description != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            project.description!,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: project.progress / 100,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getStatusColor(project.status),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Avancement: ${project.progress}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Informations
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informations',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _InfoRow(
                          icon: Icons.currency_exchange,
                          label: 'Budget',
                          value: '${project.budget.toStringAsFixed(0)} FCFA',
                        ),
                        if (project.clientName != null)
                          _InfoRow(
                            icon: Icons.person,
                            label: 'Client',
                            value: project.clientName!,
                          ),
                        if (project.address != null)
                          _InfoRow(
                            icon: Icons.location_on,
                            label: 'Adresse',
                            value: project.address!,
                          ),
                        if (project.startDate != null)
                          _InfoRow(
                            icon: Icons.calendar_today,
                            label: 'Date de début',
                            value: project.startDate!,
                          ),
                        if (project.endDate != null)
                          _InfoRow(
                            icon: Icons.event,
                            label: 'Date de fin',
                            value: project.endDate!,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'en_cours':
        return Colors.blue;
      case 'termine':
        return Colors.green;
      case 'bloque':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

