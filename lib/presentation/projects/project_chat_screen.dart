import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../comments/comment_provider.dart';
import '../comments/create_comment_screen.dart';
import '../../data/models/comment_model.dart';

class ProjectChatScreen extends StatefulWidget {
  final int projectId;

  const ProjectChatScreen({super.key, required this.projectId});

  @override
  State<ProjectChatScreen> createState() => _ProjectChatScreenState();
}

class _ProjectChatScreenState extends State<ProjectChatScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final commentProvider = Provider.of<CommentProvider>(context, listen: false);
      commentProvider.setSelectedProject(widget.projectId);
      commentProvider.loadComments();

      // Rafraîchir automatiquement toutes les 10 secondes pour voir les nouvelles réponses
      _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
        if (mounted) {
          commentProvider.loadComments();
        }
      });
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
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
                Color(0xFFB41839),
                Color(0xFF3F1B3D),
              ],
            ),
          ),
        ),
        title: const Text(
          'Chat',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment),
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CreateCommentScreen(
                    projectId: widget.projectId,
                  ),
                ),
              );
              if (result == true && mounted) {
                Provider.of<CommentProvider>(context, listen: false)
                    .loadComments();
              }
            },
          ),
        ],
      ),
      body: Consumer<CommentProvider>(
        builder: (context, commentProvider, _) {
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
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
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
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun message',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
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
                return _buildCommentCard(comment, commentProvider);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CreateCommentScreen(
                projectId: widget.projectId,
              ),
            ),
          );
          if (result == true && mounted) {
            Provider.of<CommentProvider>(context, listen: false)
                .loadComments();
          }
        },
        backgroundColor: const Color(0xFFB41839),
        child: const Icon(Icons.add_comment, color: Colors.white),
      ),
    );
  }

  Widget _buildCommentCard(CommentModel comment, CommentProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFB41839),
                  child: Text(
                    comment.user?.name[0].toUpperCase() ?? 'U',
                    style: const TextStyle(color: Colors.white),
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
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (comment.createdAt != null)
                        Text(
                          _formatDate(comment.createdAt!),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(comment.content),
            
            // Réponses
            if (comment.replies != null && comment.replies!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                margin: const EdgeInsets.only(left: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
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
                            backgroundColor: const Color(0xFF4CAF50),
                            child: Text(
                              reply.user?.name[0].toUpperCase() ?? 'U',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
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
                                if (reply.createdAt != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      _formatDate(reply.createdAt!),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[500],
                                      ),
                                    ),
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
            ],
            
            // Bouton répondre
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CreateCommentScreen(
                      projectId: widget.projectId,
                      parentId: comment.id,
                    ),
                  ),
                );
                if (result == true && mounted) {
                  provider.loadComments();
                }
              },
              icon: const Icon(Icons.reply, size: 16),
              label: const Text('Répondre'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

