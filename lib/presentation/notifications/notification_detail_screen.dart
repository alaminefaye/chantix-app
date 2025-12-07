import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'notification_provider.dart';
import '../../data/models/notification_model.dart';
import '../materials/material_detail_screen.dart';
import '../materials/materials_screen.dart';
import '../projects/project_detail_screen.dart';
import '../projects/projects_screen.dart';
import '../projects/project_chat_screen.dart';

class NotificationDetailScreen extends StatefulWidget {
  final NotificationModel notification;

  const NotificationDetailScreen({super.key, required this.notification});

  @override
  State<NotificationDetailScreen> createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  bool _isRead = false;
  bool _isMarkingAsRead = false;

  @override
  void initState() {
    super.initState();
    // Initialiser l'état local avec la valeur de la notification
    _isRead = widget.notification.isRead;

    // Marquer comme lue automatiquement à l'ouverture si pas déjà lue
    if (!_isRead) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _markAsReadAutomatically();
      });
    }
  }

  Future<void> _markAsReadAutomatically() async {
    if (_isMarkingAsRead || _isRead) return;

    setState(() {
      _isMarkingAsRead = true;
    });

    try {
      final provider = Provider.of<NotificationProvider>(
        context,
        listen: false,
      );
      final success = await provider.markAsRead(widget.notification.id);

      if (success && mounted) {
        setState(() {
          _isRead = true;
          _isMarkingAsRead = false;
        });
      } else if (mounted) {
        setState(() {
          _isMarkingAsRead = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isMarkingAsRead = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
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
      final months = [
        'Jan',
        'Fév',
        'Mar',
        'Avr',
        'Mai',
        'Jun',
        'Jul',
        'Aoû',
        'Sep',
        'Oct',
        'Nov',
        'Déc',
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }
  }

  void _navigateToRelatedItem(BuildContext context) {
    final data = widget.notification.data;

    switch (widget.notification.type) {
      case 'material_added':
      case 'material_removed':
        // Pour les matériaux ajoutés/retirés d'un projet, naviguer vers le projet concerné
        if (widget.notification.projectId != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProjectDetailScreen(
                projectId: widget.notification.projectId!,
              ),
            ),
          );
        } else if (data != null && data['project_id'] != null) {
          // Fallback: utiliser project_id depuis les données
          final projectId = data['project_id'] is int
              ? data['project_id']
              : int.tryParse(data['project_id'].toString());
          if (projectId != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProjectDetailScreen(projectId: projectId),
              ),
            );
            return;
          }
        }
        // Si pas de projectId, naviguer vers la liste des projets
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ProjectsScreen()));
        break;

      case 'material_created':
      case 'material_updated':
      case 'material_stock_increased':
      case 'material_stock_decreased':
      case 'material_low_stock':
      case 'material_deleted':
        if (data != null && data['material_id'] != null) {
          final materialId = data['material_id'] is int
              ? data['material_id']
              : int.tryParse(data['material_id'].toString());
          if (materialId != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MaterialDetailScreen(materialId: materialId),
              ),
            );
            return;
          }
        }
        // Si pas d'ID, naviguer vers la liste
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const MaterialsScreen()));
        break;

      case 'project_created':
      case 'project_updated':
        if (widget.notification.projectId != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProjectDetailScreen(
                projectId: widget.notification.projectId!,
              ),
            ),
          );
        } else {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const ProjectsScreen()));
        }
        break;

      case 'comment':
      case 'mention':
        // Pour les commentaires, naviguer vers l'écran de chat du projet
        if (widget.notification.projectId != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  ProjectChatScreen(projectId: widget.notification.projectId!),
            ),
          );
        } else {
          // Si pas de projectId, naviguer vers la liste des projets
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const ProjectsScreen()));
        }
        break;

      default:
        // Pour les autres types, essayer de naviguer vers le projet si disponible
        if (widget.notification.projectId != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProjectDetailScreen(
                projectId: widget.notification.projectId!,
              ),
            ),
          );
        }
        break;
    }
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
          'Détails de la notification',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.notification.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!_isRead)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withAlpha((255 * 0.1).round()),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Non lue',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Type: ${widget.notification.type}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Section Message
            _buildSectionTitle('Message'),
            _buildInfoCard([
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.notification.message,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 12),

            // Section Informations générales
            _buildSectionTitle('Informations générales'),
            _buildInfoCard([
              _buildInfoRow('Titre', widget.notification.title),
              _buildInfoRow('Date', _formatDate(widget.notification.createdAt)),
              _buildInfoRow('Statut', _isRead ? 'Lue' : 'Non lue'),
              _buildInfoRow('Type', widget.notification.type),
            ]),

            // Informations supplémentaires depuis data
            if (widget.notification.data != null &&
                widget.notification.data!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildSectionTitle('Informations supplémentaires'),
              _buildInfoCard(
                widget.notification.data!.entries.map((entry) {
                  String label = entry.key.replaceAll('_', ' ');
                  // Capitaliser chaque mot (y compris "Id" au lieu de "id")
                  label = label
                      .split(' ')
                      .map((word) {
                        if (word.isEmpty) return '';
                        // Cas spéciaux
                        if (word.toLowerCase() == 'id') return 'Id';
                        return word[0].toUpperCase() +
                            word.substring(1).toLowerCase();
                      })
                      .join(' ');
                  return _buildInfoRow(label, entry.value.toString());
                }).toList(),
              ),
            ],
            const SizedBox(height: 16),
            // Bouton pour voir l'élément concerné
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _navigateToRelatedItem(context),
                icon: const Icon(
                  Icons.visibility,
                  color: Colors.white,
                  size: 18,
                ),
                label: const Text(
                  'Voir l\'élément concerné',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB41839),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Bouton pour marquer comme lu (si pas déjà lu)
            if (!_isRead)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isMarkingAsRead
                      ? null
                      : () async {
                          final provider = Provider.of<NotificationProvider>(
                            context,
                            listen: false,
                          );
                          final success = await provider.markAsRead(
                            widget.notification.id,
                          );
                          if (success && mounted) {
                            setState(() {
                              _isRead = true;
                              _isMarkingAsRead = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Notification marquée comme lue'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                  icon: _isMarkingAsRead
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.grey,
                          ),
                        )
                      : const Icon(Icons.done, color: Colors.grey, size: 18),
                  label: Text(
                    _isMarkingAsRead
                        ? 'Marquage en cours...'
                        : 'Marquer comme lue',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
