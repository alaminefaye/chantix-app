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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFB41839), // Rouge
                Color(0xFF3F1B3D), // Violet foncé
              ],
            ),
          ),
        ),
        title: const Text(
          'Projets',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CreateProjectScreen(),
                  ),
                );
                // Recharger les projets après le retour
                if (mounted) {
                  Provider.of<ProjectProvider>(context, listen: false).loadProjects();
                }
              },
            ),
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
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icône avec design 3D
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.grey[300]!,
                            Colors.grey[400]!,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.construction,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Aucun projet trouvé',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Bouton avec design 3D
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFB41839),
                            Color(0xFF3F1B3D),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFB41839).withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const CreateProjectScreen(),
                            ),
                          );
                          // Recharger les projets après le retour
                          if (mounted) {
                            Provider.of<ProjectProvider>(context, listen: false).loadProjects();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Créer un projet',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
                return _ProjectCard3D(project: project);
              },
            ),
          );
        },
      ),
    );
  }
}

// Carte de projet avec design 3D
class _ProjectCard3D extends StatelessWidget {
  final ProjectModel project;

  const _ProjectCard3D({required this.project});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
        ),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProjectDetailScreen(projectId: project.id),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
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
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    _StatusBadge3D(status: project.status),
                  ],
                ),
                if (project.description != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    project.description!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _InfoItem3D(
                        icon: Icons.currency_exchange,
                        label: 'Budget',
                        value: '${project.budget.toStringAsFixed(0)} FCFA',
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFF39C12),
                            Color(0xFFE67E22),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _InfoItem3D(
                        icon: Icons.trending_up,
                        label: 'Avancement',
                        value: '${project.progress}%',
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF9B59B6),
                            Color(0xFF8E44AD),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _ProgressBar3D(
                  value: project.progress / 100,
                  gradient: _getStatusGradient(project.status),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Gradient _getStatusGradient(String status) {
    switch (status) {
      case 'en_cours':
        return const LinearGradient(
          colors: [
            Color(0xFF4A90E2),
            Color(0xFF357ABD),
          ],
        );
      case 'termine':
        return const LinearGradient(
          colors: [
            Color(0xFF2ECC71),
            Color(0xFF27AE60),
          ],
        );
      case 'bloque':
        return const LinearGradient(
          colors: [
            Color(0xFFE74C3C),
            Color(0xFFC0392B),
          ],
        );
      default:
        return LinearGradient(
          colors: [
            Colors.grey[400]!,
            Colors.grey[600]!,
          ],
        );
    }
  }
}

// Badge de statut avec design 3D
class _StatusBadge3D extends StatelessWidget {
  final String status;

  const _StatusBadge3D({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    
    switch (status) {
      case 'en_cours':
        color = const Color(0xFF4A90E2);
        label = 'En cours';
        break;
      case 'termine':
        color = const Color(0xFF2ECC71);
        label = 'Terminé';
        break;
      case 'bloque':
        color = const Color(0xFFE74C3C);
        label = 'Bloqué';
        break;
      default:
        color = Colors.grey;
        label = 'Inconnu';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// Item d'information avec design 3D
class _InfoItem3D extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Gradient gradient;

  const _InfoItem3D({
    required this.icon,
    required this.label,
    required this.value,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gradient.colors.first.withValues(alpha: 0.1),
            gradient.colors.last.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: gradient,
              boxShadow: [
                BoxShadow(
                  color: gradient.colors.first.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
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

// Barre de progression avec design 3D
class _ProgressBar3D extends StatelessWidget {
  final double value;
  final Gradient gradient;

  const _ProgressBar3D({
    required this.value,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[200],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            // Fond
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.grey[200],
            ),
            // Barre de progression avec dégradé
            FractionallySizedBox(
              widthFactor: value.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: gradient,
                  boxShadow: [
                    BoxShadow(
                      color: gradient.colors.first.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
