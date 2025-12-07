import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/project_model.dart';
import '../projects/project_provider.dart';
import '../auth/auth_provider.dart';
import 'progress_provider.dart';
import 'create_progress_update_screen.dart';
import 'progress_gallery_screen.dart';
import 'progress_update_detail_screen.dart';

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
    final projectProvider = Provider.of<ProjectProvider>(
      context,
      listen: false,
    );
    if (projectProvider.projects.isEmpty) {
      await projectProvider.loadProjects();
    }

    // Auto-sélectionner un projet si aucun n'est sélectionné
    if (_selectedProject == null && projectProvider.projects.isNotEmpty) {
      _autoSelectProject(projectProvider.projects);
    }
  }

  void _autoSelectProject(List<ProjectModel> projects) {
    if (projects.isEmpty) return;

    // Si un seul projet, le sélectionner automatiquement
    if (projects.length == 1) {
      setState(() {
        _selectedProject = projects.first;
      });
      _loadProgressUpdates();
      return;
    }

    // Si plusieurs projets, chercher le premier projet "en_cours" (en cours)
    final inProgressProjects = projects
        .where((p) => p.status == 'en_cours')
        .toList();

    if (inProgressProjects.isNotEmpty) {
      // Sélectionner le premier projet en cours
      setState(() {
        _selectedProject = inProgressProjects.first;
      });
      _loadProgressUpdates();
      return;
    }

    // Si aucun projet en cours, sélectionner le premier projet disponible
    setState(() {
      _selectedProject = projects.first;
    });
    _loadProgressUpdates();
  }

  Future<void> _loadProgressUpdates() async {
    if (_selectedProject == null) return;

    final progressProvider = Provider.of<ProgressProvider>(
      context,
      listen: false,
    );
    await progressProvider.loadProgressUpdates(_selectedProject!.id);
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
          'Avancement',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_selectedProject != null)
            IconButton(
              icon: const Icon(Icons.photo_library),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        ProgressGalleryScreen(projectId: _selectedProject!.id),
                  ),
                );
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Sélection du projet
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
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

                  // Auto-sélectionner un projet si aucun n'est sélectionné
                  if (_selectedProject == null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _autoSelectProject(projectProvider.projects);
                    });
                  }

                  // Trouver le projet sélectionné dans la liste pour s'assurer d'utiliser la même instance
                  final selectedProjectInList = _selectedProject != null
                      ? projectProvider.projects.firstWhere(
                          (p) => p.id == _selectedProject!.id,
                          orElse: () => _selectedProject!,
                        )
                      : null;

                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: DropdownButtonFormField<ProjectModel>(
                      value: selectedProjectInList,
                      decoration: InputDecoration(
                        labelText: 'Sélectionner un projet',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFB41839), Color(0xFF3F1B3D)],
                            ),
                          ),
                          child: const Icon(
                            Icons.construction,
                            color: Colors.white,
                            size: 20,
                          ),
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
                    ),
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
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
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
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.06,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.04,
                                      ),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            ProgressUpdateDetailScreen(
                                              update: update,
                                              projectId: _selectedProject!.id,
                                            ),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                            padding: const EdgeInsets.only(
                                              bottom: 8,
                                            ),
                                            child: Text(
                                              update.description!,
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        // Barre de progression
                                        Container(
                                          height: 12,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            color: Colors.grey[200],
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.05,
                                                ),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            child: LinearProgressIndicator(
                                              value: update.progress / 100,
                                              minHeight: 12,
                                              backgroundColor:
                                                  Colors.transparent,
                                              valueColor:
                                                  const AlwaysStoppedAnimation<
                                                    Color
                                                  >(Color(0xFFB41839)),
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
                                                update
                                                    .audioReport!
                                                    .isNotEmpty) ...[
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
                                        const SizedBox(height: 12),
                                        // Boutons d'action (uniquement si l'utilisateur est le créateur)
                                        Consumer<AuthProvider>(
                                          builder: (context, authProvider, _) {
                                            final currentUser =
                                                authProvider.user;
                                            final canEdit =
                                                currentUser != null &&
                                                (currentUser.id ==
                                                        update.userId ||
                                                    currentUser.isSuperAdmin);

                                            if (!canEdit) {
                                              return const SizedBox.shrink();
                                            }

                                            return Consumer<ProgressProvider>(
                                              builder: (context, progressProvider, _) {
                                                return Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    TextButton.icon(
                                                      onPressed:
                                                          progressProvider
                                                              .isLoading
                                                          ? null
                                                          : () {
                                                              Navigator.of(
                                                                    context,
                                                                  )
                                                                  .push(
                                                                    MaterialPageRoute(
                                                                      builder: (_) => CreateProgressUpdateScreen(
                                                                        projectId:
                                                                            _selectedProject!.id,
                                                                        update:
                                                                            update,
                                                                      ),
                                                                    ),
                                                                  )
                                                                  .then((_) {
                                                                    // Recharger les données après modification
                                                                    _loadProgressUpdates();
                                                                  });
                                                            },
                                                      icon: const Icon(
                                                        Icons.edit,
                                                        size: 18,
                                                        color: Color(
                                                          0xFFB41839,
                                                        ),
                                                      ),
                                                      label: const Text(
                                                        'Modifier',
                                                        style: TextStyle(
                                                          color: Color(
                                                            0xFFB41839,
                                                          ),
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    TextButton.icon(
                                                      onPressed:
                                                          progressProvider
                                                              .isLoading
                                                          ? null
                                                          : () async {
                                                              final confirm = await showDialog<bool>(
                                                                context:
                                                                    context,
                                                                builder: (context) => AlertDialog(
                                                                  title: const Text(
                                                                    'Confirmer la suppression',
                                                                  ),
                                                                  content:
                                                                      const Text(
                                                                        'Êtes-vous sûr de vouloir supprimer cette mise à jour ? Cette action est irréversible.',
                                                                      ),
                                                                  actions: [
                                                                    TextButton(
                                                                      onPressed: () =>
                                                                          Navigator.of(
                                                                            context,
                                                                          ).pop(
                                                                            false,
                                                                          ),
                                                                      child: const Text(
                                                                        'Annuler',
                                                                      ),
                                                                    ),
                                                                    TextButton(
                                                                      onPressed: () =>
                                                                          Navigator.of(
                                                                            context,
                                                                          ).pop(
                                                                            true,
                                                                          ),
                                                                      style: TextButton.styleFrom(
                                                                        foregroundColor:
                                                                            Colors.red,
                                                                      ),
                                                                      child: const Text(
                                                                        'Supprimer',
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              );

                                                              if (confirm ==
                                                                      true &&
                                                                  context
                                                                      .mounted) {
                                                                final success = await progressProvider
                                                                    .deleteProgressUpdate(
                                                                      _selectedProject!
                                                                          .id,
                                                                      update.id,
                                                                    );

                                                                if (context
                                                                    .mounted) {
                                                                  if (success) {
                                                                    ScaffoldMessenger.of(
                                                                      context,
                                                                    ).showSnackBar(
                                                                      const SnackBar(
                                                                        content:
                                                                            Text(
                                                                              'Mise à jour supprimée avec succès',
                                                                            ),
                                                                        backgroundColor:
                                                                            Colors.green,
                                                                      ),
                                                                    );
                                                                  } else {
                                                                    ScaffoldMessenger.of(
                                                                      context,
                                                                    ).showSnackBar(
                                                                      const SnackBar(
                                                                        content:
                                                                            Text(
                                                                              'Erreur lors de la suppression',
                                                                            ),
                                                                        backgroundColor:
                                                                            Colors.red,
                                                                      ),
                                                                    );
                                                                  }
                                                                }
                                                              }
                                                            },
                                                      icon: const Icon(
                                                        Icons.delete,
                                                        size: 18,
                                                        color: Colors.red,
                                                      ),
                                                      label: const Text(
                                                        'Supprimer',
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
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
      ),
      floatingActionButton: _selectedProject != null
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFB41839), Color(0xFF3F1B3D)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFB41839).withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (_) => CreateProgressUpdateScreen(
                            projectId: _selectedProject!.id,
                          ),
                        ),
                      )
                      .then((_) {
                        _loadProgressUpdates();
                      });
                },
                backgroundColor: Colors.transparent,
                elevation: 0,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Nouvelle mise à jour',
                  style: TextStyle(color: Colors.white),
                ),
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
