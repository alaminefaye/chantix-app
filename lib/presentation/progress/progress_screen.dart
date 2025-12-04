import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/project_model.dart';
import '../projects/project_provider.dart';
import 'progress_provider.dart';
import 'create_progress_update_screen.dart';
import 'progress_gallery_screen.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  ProjectModel? _selectedProject;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProjects();
    });
  }

  Future<void> _loadProjects() async {
    final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
    if (projectProvider.projects.isEmpty) {
      await projectProvider.loadProjects();
    }
  }

  Future<void> _loadProgressUpdates() async {
    if (_selectedProject == null) return;

    final progressProvider =
        Provider.of<ProgressProvider>(context, listen: false);
    await progressProvider.loadProgressUpdates(_selectedProject!.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avancement'),
        actions: [
          if (_selectedProject != null)
            IconButton(
              icon: const Icon(Icons.photo_library),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProgressGalleryScreen(
                      projectId: _selectedProject!.id,
                    ),
                  ),
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
                if (projectProvider.isLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (projectProvider.projects.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Aucun projet disponible',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return DropdownButtonFormField<ProjectModel>(
                  value: _selectedProject,
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
                    setState(() {
                      _selectedProject = project;
                    });
                    if (project != null) {
                      _loadProgressUpdates();
                    }
                  },
                );
              },
            ),
          ),

          // Liste des mises à jour
          Expanded(
            child: _selectedProject == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.trending_up,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Sélectionnez un projet pour voir les mises à jour',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : Consumer<ProgressProvider>(
                    builder: (context, progressProvider, _) {
                      if (progressProvider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (progressProvider.errorMessage != null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                progressProvider.errorMessage!,
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  progressProvider.clearError();
                                  _loadProgressUpdates();
                                },
                                child: const Text('Réessayer'),
                              ),
                            ],
                          ),
                        );
                      }

                      final updates = progressProvider.progressUpdates;

                      if (updates.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.assignment_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Aucune mise à jour pour ce projet',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: _loadProgressUpdates,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: updates.length,
                          itemBuilder: (context, index) {
                            final update = updates[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${update.progress}%',
                                                style: const TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFFB41839),
                                                ),
                                              ),
                                              if (update.user != null)
                                                Text(
                                                  'Par ${update.user!.name}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        if (update.createdAt != null)
                                          Text(
                                            _formatDate(update.createdAt!),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    if (update.description != null &&
                                        update.description!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: Text(
                                          update.description!,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    // Barre de progression
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: update.progress / 100,
                                        minHeight: 8,
                                        backgroundColor: Colors.grey[200],
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                          Color(0xFFB41839),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    // Médias
                                    Row(
                                      children: [
                                        if (update.photos != null &&
                                            update.photos!.isNotEmpty)
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.photo,
                                                size: 16,
                                                color: Colors.blue,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${update.photos!.length} photo(s)',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                            ],
                                          ),
                                        if (update.videos != null &&
                                            update.videos!.isNotEmpty) ...[
                                          const SizedBox(width: 16),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.videocam,
                                                size: 16,
                                                color: Colors.red,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${update.videos!.length} vidéo(s)',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                        if (update.audioReport != null &&
                                            update.audioReport!.isNotEmpty) ...[
                                          const SizedBox(width: 16),
                                          const Row(
                                            children: [
                                              Icon(
                                                Icons.mic,
                                                size: 16,
                                                color: Colors.green,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                'Audio',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.green,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
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
      floatingActionButton: _selectedProject != null
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CreateProgressUpdateScreen(
                      projectId: _selectedProject!.id,
                    ),
                  ),
                ).then((_) {
                  _loadProgressUpdates();
                });
              },
              backgroundColor: const Color(0xFFB41839),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Nouvelle mise à jour',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          if (difference.inMinutes == 0) {
            return 'À l\'instant';
          }
          return 'Il y a ${difference.inMinutes} min';
        }
        return 'Il y a ${difference.inHours} h';
      } else if (difference.inDays == 1) {
        return 'Hier';
      } else if (difference.inDays < 7) {
        return 'Il y a ${difference.inDays} jours';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }
}

