import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:just_audio/just_audio.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/models/progress_update_model.dart';
import '../../config/api_config.dart';
import '../../data/services/storage_service.dart';
import '../projects/project_provider.dart';
import '../auth/auth_provider.dart';
import 'progress_provider.dart';
import 'create_progress_update_screen.dart';

class ProgressUpdateDetailScreen extends StatelessWidget {
  final ProgressUpdateModel update;
  final int projectId;

  const ProgressUpdateDetailScreen({
    super.key,
    required this.update,
    required this.projectId,
  });

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
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

  String _getFullUrl(String url) {
    debugPrint('URL originale reçue: $url');

    // Si l'URL commence déjà par http, la retourner telle quelle
    if (url.startsWith('http://') || url.startsWith('https://')) {
      debugPrint('URL complète détectée: $url');
      return url;
    }

    // Si l'URL commence par /storage/, construire l'URL complète
    if (url.startsWith('/storage/')) {
      final fullUrl = '${ApiConfig.baseUrl.replaceAll('/api', '')}$url';
      debugPrint('URL construite depuis /storage/: $fullUrl');
      return fullUrl;
    }

    // Si l'URL est un chemin relatif (ex: progress/audio/file.m4a)
    // Laravel Storage::url() peut retourner soit /storage/... soit juste le chemin
    final baseUrl = ApiConfig.baseUrl.replaceAll('/api', '');
    final fullUrl = url.startsWith('/')
        ? '$baseUrl$url'
        : '$baseUrl/storage/$url';
    debugPrint('URL construite depuis chemin relatif: $fullUrl');
    return fullUrl;
  }

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(
      context,
      listen: false,
    );
    final project = projectProvider.projects.firstWhere(
      (p) => p.id == projectId,
      orElse: () => projectProvider.selectedProject!,
    );

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
          'Détails de la mise à jour',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec pourcentage
            Container(
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${update.progress}%',
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFB41839),
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (update.user != null)
                                Text(
                                  'Par ${update.user!.name}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              if (update.createdAt != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  _formatDate(update.createdAt!),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFB41839), Color(0xFF3F1B3D)],
                            ),
                          ),
                          child: const Icon(
                            Icons.trending_up,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Barre de progression
                    Container(
                      height: 16,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[200],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: update.progress / 100,
                          minHeight: 16,
                          backgroundColor: Colors.transparent,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFB41839),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Informations du projet
            Container(
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
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFB41839), Color(0xFF3F1B3D)],
                        ),
                      ),
                      child: const Icon(
                        Icons.construction,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Projet',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            project.name,
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
              ),
            ),
            const SizedBox(height: 16),

            // Description
            if (update.description != null && update.description!.isNotEmpty)
              Container(
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
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        update.description!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            if (update.description != null && update.description!.isNotEmpty)
              const SizedBox(height: 16),

            // Photos
            if (update.photos != null && update.photos!.isNotEmpty)
              Container(
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
                          const Icon(Icons.photo, color: Colors.blue, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'Photos (${update.photos!.length})',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                        itemCount: update.photos!.length,
                        itemBuilder: (context, index) {
                          final photoUrl = update.photos![index];
                          final fullUrl = _getFullUrl(photoUrl);

                          return GestureDetector(
                            onTap: () {
                              // TODO: Ouvrir la photo en plein écran
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: fullUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.error),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            if (update.photos != null && update.photos!.isNotEmpty)
              const SizedBox(height: 16),

            // Vidéos
            if (update.videos != null && update.videos!.isNotEmpty)
              Container(
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
                          const Icon(
                            Icons.videocam,
                            color: Colors.red,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Vidéos (${update.videos!.length})',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...update.videos!.map((videoUrl) {
                        final fullUrl = _getFullUrl(videoUrl);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.black,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: VideoPlayerWidget(videoUrl: fullUrl),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            if (update.videos != null && update.videos!.isNotEmpty)
              const SizedBox(height: 16),

            // Audio
            if (update.audioReport != null && update.audioReport!.isNotEmpty)
              Container(
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
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.green[50],
                        ),
                        child: const Icon(
                          Icons.mic,
                          color: Colors.green,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Rapport audio',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Audio disponible',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Builder(
                        builder: (context) {
                          // Utiliser l'endpoint API pour télécharger l'audio avec authentification
                          final audioUrl =
                              '${ApiConfig.baseUrl}/projects/$projectId/progress/${update.id}/audio';
                          debugPrint('URL audio API: $audioUrl');
                          return AudioPlayerWidget(
                            audioUrl: audioUrl,
                            requiresAuth: true,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            if (update.audioReport != null && update.audioReport!.isNotEmpty)
              const SizedBox(height: 16),

            // Localisation
            if (update.latitude != null && update.longitude != null)
              Container(
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
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.blue,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Localisation GPS',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Lat: ${update.latitude!.toStringAsFixed(6)}, Long: ${update.longitude!.toStringAsFixed(6)}',
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
                ),
              ),
            const SizedBox(height: 16),

            // Boutons d'action (uniquement si l'utilisateur est le créateur)
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                final currentUser = authProvider.user;
                final canEdit =
                    currentUser != null &&
                    (currentUser.id == update.userId ||
                        currentUser.isSuperAdmin);

                if (!canEdit) {
                  return const SizedBox.shrink();
                }

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
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Consumer<ProgressProvider>(
                      builder: (context, progressProvider, _) {
                        return Column(
                          children: [
                            // Bouton Modifier
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: progressProvider.isLoading
                                    ? null
                                    : () {
                                        Navigator.of(context)
                                            .push(
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    CreateProgressUpdateScreen(
                                                      projectId: projectId,
                                                      update: update,
                                                    ),
                                              ),
                                            )
                                            .then((_) {
                                              // Recharger les données après modification
                                              progressProvider
                                                  .loadProgressUpdates(
                                                    projectId,
                                                  );
                                            });
                                      },
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Modifier cette mise à jour',
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFB41839),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Bouton Supprimer
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: progressProvider.isLoading
                                    ? null
                                    : () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text(
                                              'Confirmer la suppression',
                                            ),
                                            content: const Text(
                                              'Êtes-vous sûr de vouloir supprimer cette mise à jour ? Cette action est irréversible.',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(
                                                  context,
                                                ).pop(false),
                                                child: const Text('Annuler'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.of(
                                                  context,
                                                ).pop(true),
                                                style: TextButton.styleFrom(
                                                  foregroundColor: Colors.red,
                                                ),
                                                child: const Text('Supprimer'),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirm == true) {
                                          final success = await progressProvider
                                              .deleteProgressUpdate(
                                                projectId,
                                                update.id,
                                              );

                                          if (context.mounted) {
                                            if (success) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Mise à jour supprimée avec succès',
                                                  ),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                              Navigator.of(context).pop();
                                            } else {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Erreur lors de la suppression',
                                                  ),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          }
                                        }
                                      },
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Supprimer cette mise à jour',
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// Widget pour lire les vidéos
class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  bool _hasError = false;
  double? _videoAspectRatio;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );

      await _videoPlayerController!.initialize();

      if (mounted) {
        // Calculer l'aspect ratio réel de la vidéo
        final videoSize = _videoPlayerController!.value.size;
        _videoAspectRatio = videoSize.width > 0 && videoSize.height > 0
            ? videoSize.width / videoSize.height
            : 16 / 9; // Fallback si les dimensions ne sont pas disponibles

        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController!,
          autoPlay: false,
          looping: false,
          aspectRatio: _videoAspectRatio!,
          showControls: true,
          materialProgressColors: ChewieProgressColors(
            playedColor: const Color(0xFFB41839),
            handleColor: const Color(0xFFB41839),
            backgroundColor: Colors.grey[300]!,
            bufferedColor: Colors.grey[200]!,
          ),
          placeholder: Container(
            color: Colors.grey[900],
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
          errorBuilder: (context, errorMessage) {
            return Container(
              color: Colors.grey[900],
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.white, size: 48),
                  SizedBox(height: 8),
                  Text(
                    'Erreur de chargement',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          },
        );

        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: Colors.grey[900],
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 48),
            SizedBox(height: 8),
            Text(
              'Erreur de chargement de la vidéo',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    if (!_isInitialized || _chewieController == null) {
      return Container(
        color: Colors.grey[900],
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    // Utiliser l'aspect ratio réel de la vidéo ou un ratio par défaut
    final aspectRatio = _videoAspectRatio ?? 16 / 9;

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Chewie(controller: _chewieController!),
    );
  }
}

// Widget pour lire l'audio
class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  final bool requiresAuth;

  const AudioPlayerWidget({
    super.key,
    required this.audioUrl,
    this.requiresAuth = false,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _hasError = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _localFilePath;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initializeAudio();
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
        });
      }
    });
    _audioPlayer.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });
    _audioPlayer.durationStream.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration ?? Duration.zero;
        });
      }
    });
  }

  Future<void> _initializeAudio() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      // Vérifier que l'URL est valide
      if (widget.audioUrl.isEmpty) {
        throw Exception('URL audio vide');
      }

      debugPrint('Chargement de l\'audio depuis: ${widget.audioUrl}');

      // Vérifier que l'URL est bien formée
      try {
        final uri = Uri.parse(widget.audioUrl);
        if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
          throw Exception('URL invalide: ${widget.audioUrl}');
        }
      } catch (e) {
        throw Exception('URL mal formée: ${widget.audioUrl}');
      }

      // Si requiresAuth est true, télécharger directement avec authentification
      // Sinon, essayer de charger directement depuis l'URL
      if (widget.requiresAuth) {
        debugPrint('Téléchargement avec authentification requis');
        await _downloadAndPlayAudio();
        return;
      }

      // Essayer d'abord de charger directement depuis l'URL
      try {
        await _audioPlayer
            .setUrl(widget.audioUrl)
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                throw TimeoutException(
                  'Tentative de chargement direct échouée',
                  const Duration(seconds: 10),
                );
              },
            );
        debugPrint('Audio chargé directement depuis l\'URL');
      } catch (e) {
        debugPrint(
          'Échec du chargement direct, tentative de téléchargement avec authentification: $e',
        );
        // Si le chargement direct échoue, télécharger le fichier avec authentification
        await _downloadAndPlayAudio();
        return;
      }

      // Attendre un peu pour que la durée soit disponible
      await Future.delayed(const Duration(milliseconds: 500));

      // Vérifier que la durée a été chargée
      final duration = _audioPlayer.duration;
      if (duration == null && _duration == Duration.zero) {
        // Attendre encore un peu
        await Future.delayed(const Duration(milliseconds: 1000));
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        debugPrint(
          'Audio chargé avec succès. Durée: ${_audioPlayer.duration ?? _duration}',
        );
      }
    } on TimeoutException catch (e) {
      debugPrint('Timeout lors du chargement de l\'audio: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Le chargement de l\'audio a pris trop de temps. Vérifiez votre connexion.',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Erreur lors de l\'initialisation de l\'audio: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('URL utilisée: ${widget.audioUrl}');

      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur lors du chargement de l\'audio. Vérifiez que le fichier existe.',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Réessayer',
              textColor: Colors.white,
              onPressed: () {
                _initializeAudio();
              },
            ),
          ),
        );
      }
    }
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }
    } catch (e) {
      debugPrint('Erreur lors de la lecture: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la lecture: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<void> _downloadAndPlayAudio() async {
    try {
      debugPrint('Téléchargement de l\'audio avec authentification...');

      // Obtenir le token d'authentification depuis StorageService
      final token = StorageService.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Token d\'authentification non disponible');
      }

      // Créer un client Dio avec le token
      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';
      dio.options.headers['Accept'] = 'application/json';

      // Télécharger le fichier dans le répertoire temporaire
      final directory = await getTemporaryDirectory();
      // Générer un nom de fichier unique avec extension
      // L'endpoint API ne retourne pas de nom de fichier dans l'URL, donc on utilise un nom par défaut
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/audio_$timestamp.m4a';

      debugPrint('Téléchargement depuis: ${widget.audioUrl}');
      debugPrint('Téléchargement vers: $filePath');

      // Télécharger avec Dio
      final response = await dio.download(
        widget.audioUrl,
        filePath,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (status) {
            // Accepter les codes 200-299 comme succès
            return status != null && status >= 200 && status < 300;
          },
          headers: {
            'Authorization': 'Bearer $token',
            'Accept':
                '*/*', // Accepter tous les types de contenu pour les fichiers
          },
        ),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            debugPrint(
              'Progression: ${(received / total * 100).toStringAsFixed(0)}%',
            );
          }
        },
      );

      debugPrint('Réponse du téléchargement: ${response.statusCode}');
      debugPrint('Content-Type: ${response.headers.value("content-type")}');
      debugPrint('Content-Length: ${response.headers.value("content-length")}');

      // Vérifier le code de statut (validateStatus devrait déjà gérer ça, mais on vérifie quand même)
      if (response.statusCode == null ||
          response.statusCode! < 200 ||
          response.statusCode! >= 300) {
        // Lire le contenu de la réponse pour voir si c'est une erreur JSON
        try {
          final file = File(filePath);
          if (await file.exists()) {
            final errorContent = await file.readAsString();
            debugPrint(
              'Réponse d\'erreur (premiers 500 caractères): ${errorContent.length > 500 ? errorContent.substring(0, 500) : errorContent}',
            );
            // Supprimer le fichier d'erreur
            await file.delete();
          }
        } catch (e) {
          debugPrint('Impossible de lire la réponse d\'erreur: $e');
        }
        throw Exception(
          'Erreur HTTP ${response.statusCode}: ${response.statusMessage ?? "Unknown error"}',
        );
      }

      // Vérifier que le Content-Type est bien un type audio
      final contentType = response.headers.value('content-type') ?? '';
      if (!contentType.startsWith('audio/') && !contentType.isEmpty) {
        debugPrint('Attention: Content-Type inattendu: $contentType');
      }

      // Vérifier que le fichier existe
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Le fichier téléchargé n\'existe pas');
      }

      final fileSize = await file.length();
      debugPrint('Fichier téléchargé avec succès: $fileSize bytes');

      // Vérifier que le fichier n'est pas vide
      if (fileSize == 0) {
        throw Exception('Le fichier téléchargé est vide');
      }

      // Vérifier le type de fichier en lisant les premiers bytes
      final bytes = await file.readAsBytes();
      debugPrint('Premiers bytes du fichier: ${bytes.take(20).toList()}');

      // Vérifier si c'est du JSON (commence par { ou [)
      if (bytes.isNotEmpty && (bytes[0] == 123 || bytes[0] == 91)) {
        final content = String.fromCharCodes(bytes);
        debugPrint(
          'Le fichier téléchargé semble être du JSON: ${content.substring(0, content.length > 200 ? 200 : content.length)}',
        );
        throw Exception(
          'Le serveur a retourné du JSON au lieu du fichier audio. Vérifiez l\'endpoint API.',
        );
      }

      // Vérifier les signatures de fichiers audio courants
      // M4A commence généralement par 00 00 00 XX ftyp
      // MP3 commence par FF FB ou FF F3
      bool isValidAudio = false;
      if (bytes.length >= 4) {
        // Vérifier M4A (commence souvent par ftyp)
        if (bytes.length >= 8 &&
            String.fromCharCodes(bytes.sublist(4, 8)) == 'ftyp') {
          isValidAudio = true;
          debugPrint('Format détecté: M4A/MP4');
        }
        // Vérifier MP3 (ID3 ou frame sync)
        else if ((bytes[0] == 0xFF && (bytes[1] & 0xE0) == 0xE0) ||
            (bytes[0] == 0x49 && bytes[1] == 0x44 && bytes[2] == 0x33)) {
          isValidAudio = true;
          debugPrint('Format détecté: MP3');
        }
        // Vérifier WAV (commence par RIFF)
        else if (bytes.length >= 4 &&
            String.fromCharCodes(bytes.sublist(0, 4)) == 'RIFF') {
          isValidAudio = true;
          debugPrint('Format détecté: WAV');
        }
      }

      if (!isValidAudio && bytes.length > 0) {
        debugPrint(
          'Attention: Format audio non reconnu. Premiers bytes: ${bytes.take(10).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}',
        );
      }

      // Charger le fichier local avec just_audio
      try {
        await _audioPlayer.setFilePath(filePath);
        _localFilePath = filePath;
        debugPrint('Audio chargé depuis le fichier local: $filePath');
      } catch (e) {
        debugPrint('Erreur lors du chargement du fichier avec just_audio: $e');
        // Essayer de déterminer le format réel du fichier
        throw Exception(
          'Impossible de charger le fichier audio. Vérifiez que le fichier est un format audio valide (M4A, MP3, WAV). Erreur: $e',
        );
      }

      // Attendre un peu pour que la durée soit disponible
      await Future.delayed(const Duration(milliseconds: 500));
      final duration = _audioPlayer.duration;
      if (duration == null && _duration == Duration.zero) {
        await Future.delayed(const Duration(milliseconds: 1000));
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        debugPrint(
          'Audio chargé avec succès. Durée: ${_audioPlayer.duration ?? _duration}',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Erreur lors du téléchargement: $e');
      debugPrint('Stack trace: $stackTrace');

      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur lors du téléchargement de l\'audio: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Réessayer',
              textColor: Colors.white,
              onPressed: () {
                _initializeAudio();
              },
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    // Nettoyer le fichier temporaire si nécessaire
    if (_localFilePath != null) {
      try {
        final file = File(_localFilePath!);
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (e) {
        debugPrint('Erreur lors de la suppression du fichier temporaire: $e');
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.error_outline, color: Colors.red, size: 32),
            onPressed: () {
              _initializeAudio();
            },
            tooltip: 'Réessayer',
          ),
          const SizedBox(width: 4),
          const Text(
            'Erreur',
            style: TextStyle(fontSize: 12, color: Colors.red),
          ),
        ],
      );
    }

    if (_isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 32,
            height: 32,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          const SizedBox(width: 8),
          const Text(
            'Chargement...',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            _isPlaying ? Icons.pause_circle : Icons.play_circle,
            size: 48,
            color: Colors.black87,
          ),
          onPressed: _togglePlayPause,
        ),
        const SizedBox(width: 8),
        // Barre de progression et temps
        if (_duration.inSeconds > 0) ...[
          SizedBox(
            width: 100,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Slider(
                  value: _position.inSeconds.toDouble(),
                  min: 0,
                  max: _duration.inSeconds.toDouble(),
                  onChanged: (value) {
                    _audioPlayer.seek(Duration(seconds: value.toInt()));
                  },
                  activeColor: const Color(0xFFB41839),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_position),
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                    Text(
                      _formatDuration(_duration),
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
