import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'comment_provider.dart';
import '../../data/models/comment_model.dart';
import '../../data/models/project_model.dart';
import '../projects/project_provider.dart';
import 'create_comment_screen.dart';
import '../../config/api_config.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({super.key});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
      final commentProvider = Provider.of<CommentProvider>(context, listen: false);
      
      if (projectProvider.projects.isEmpty) {
        projectProvider.loadProjects();
      }
      
      if (commentProvider.selectedProjectId != null) {
        commentProvider.loadComments();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Commentaires'),
        actions: [
          Consumer<CommentProvider>(
            builder: (context, commentProvider, _) {
              if (commentProvider.selectedProjectId == null) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.add_comment),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CreateCommentScreen(
                        projectId: commentProvider.selectedProjectId!,
                      ),
                    ),
                  ).then((_) {
                    commentProvider.loadComments();
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
                return Consumer<CommentProvider>(
                  builder: (context, commentProvider, _) {
                    if (projectProvider.projects.isEmpty) {
                      return const Text('Aucun projet disponible');
                    }

                    return DropdownButtonFormField<ProjectModel>(
                      value: projectProvider.projects.firstWhere(
                        (p) => p.id == commentProvider.selectedProjectId,
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
                        commentProvider.setSelectedProject(project?.id);
                        commentProvider.loadComments();
                      },
                    );
                  },
                );
              },
            ),
          ),

          // Liste des commentaires
          Expanded(
            child: Consumer<CommentProvider>(
              builder: (context, commentProvider, _) {
                if (commentProvider.selectedProjectId == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.comment, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Sélectionnez un projet pour voir les commentaires',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (commentProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (commentProvider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          commentProvider.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            commentProvider.clearError();
                            commentProvider.loadComments();
                          },
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }

                if (commentProvider.comments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.comment_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text(
                          'Aucun commentaire',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CreateCommentScreen(
                                  projectId: commentProvider.selectedProjectId!,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_comment),
                          label: const Text('Ajouter un commentaire'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => commentProvider.loadComments(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: commentProvider.comments.length,
                    itemBuilder: (context, index) {
                      final comment = commentProvider.comments[index];
                      return _buildCommentCard(context, comment, commentProvider);
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

  Widget _buildCommentCard(
    BuildContext context,
    CommentModel comment,
    CommentProvider commentProvider,
  ) {
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
            // En-tête du commentaire
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue.withAlpha((255 * 0.2).round()),
                  child: Text(
                    comment.user?.name[0].toUpperCase() ?? 'U',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.user?.name ?? 'Utilisateur',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (comment.createdAt != null)
                        Text(
                          _formatDate(comment.createdAt!),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Contenu
            Text(
              comment.content,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),

            // Pièces jointes
            if (comment.attachments != null && comment.attachments!.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: comment.attachments!.map((attachment) {
                  final path = attachment['path'] as String?;
                  final name = attachment['name'] as String? ?? 'Fichier';
                  final type = attachment['type'] as String? ?? '';
                  
                  if (path == null) return const SizedBox.shrink();

                  final fullUrl = path.startsWith('http')
                      ? path
                      : '${ApiConfig.baseUrl.replaceAll('/api', '')}/storage/$path';

                  final isImage = type.startsWith('image/');

                  return GestureDetector(
                    onTap: () {
                      // TODO: Ouvrir la pièce jointe
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[200],
                      ),
                      child: isImage
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: fullUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) => const Icon(Icons.error),
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.insert_drive_file, size: 32),
                                Text(
                                  name.length > 10 ? '${name.substring(0, 10)}...' : name,
                                  style: const TextStyle(fontSize: 10),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],

            // Réponses
            if (comment.replies != null && comment.replies!.isNotEmpty) ...[
              Container(
                margin: const EdgeInsets.only(left: 32, top: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: comment.replies!.map((reply) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.green.withAlpha((255 * 0.2).round()),
                            child: Text(
                              reply.user?.name[0].toUpperCase() ?? 'U',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  reply.user?.name ?? 'Utilisateur',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  reply.content,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Bouton répondre
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CreateCommentScreen(
                      projectId: comment.projectId,
                      parentId: comment.id,
                    ),
                  ),
                ).then((_) {
                  commentProvider.loadComments();
                });
              },
              icon: const Icon(Icons.reply, size: 16),
              label: const Text('Répondre'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ],
        ),
      ),
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


