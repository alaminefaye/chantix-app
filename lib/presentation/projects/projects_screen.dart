import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'project_provider.dart';
import '../../data/models/project_model.dart';
import 'project_detail_screen.dart';
import 'create_project_screen.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProjectProvider>(context, listen: false).loadProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CreateProjectScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ProjectProvider>(
        builder: (context, projectProvider, _) {
          if (projectProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (projectProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    projectProvider.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      projectProvider.loadProjects();
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (projectProvider.projects.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.construction, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucun projet trouvé',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CreateProjectScreen(),
                        ),
                      );
                    },
                    child: const Text('Créer un projet'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => projectProvider.loadProjects(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: projectProvider.projects.length,
              itemBuilder: (context, index) {
                final project = projectProvider.projects[index];
                return _ProjectCard(project: project);
              },
            ),
          );
        },
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ProjectModel project;

  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProjectDetailScreen(projectId: project.id),
            ),
          );
        },
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _StatusBadge(status: project.status),
                ],
              ),
              if (project.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  project.description!,
                  style: const TextStyle(color: Colors.grey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _InfoItem(
                      icon: Icons.currency_exchange,
                      label: 'Budget',
                      value: '${project.budget.toStringAsFixed(0)} FCFA',
                    ),
                  ),
                  Expanded(
                    child: _InfoItem(
                      icon: Icons.trending_up,
                      label: 'Avancement',
                      value: '${project.progress}%',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: project.progress / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getStatusColor(project.status),
                ),
              ),
            ],
          ),
        ),
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

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final project = ProjectModel(
      id: 0,
      name: '',
      budget: 0,
      status: status,
      progress: 0,
      companyId: 0,
      createdBy: 0,
    );

    Color color;
    switch (status) {
      case 'en_cours':
        color = Colors.blue;
        break;
      case 'termine':
        color = Colors.green;
        break;
      case 'bloque':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        project.statusLabel,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

