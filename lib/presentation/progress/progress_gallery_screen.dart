import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'progress_provider.dart';
import '../../config/api_config.dart';

class ProgressGalleryScreen extends StatefulWidget {
  final int projectId;

  const ProgressGalleryScreen({super.key, required this.projectId});

  @override
  State<ProgressGalleryScreen> createState() => _ProgressGalleryScreenState();
}

class _ProgressGalleryScreenState extends State<ProgressGalleryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProgressProvider>(
        context,
        listen: false,
      ).loadProgressUpdates(widget.projectId);
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
          'Galerie de médias',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<ProgressProvider>(
        builder: (context, progressProvider, _) {
          if (progressProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final updates = progressProvider.progressUpdates;
          final allPhotos = <String>[];
          final allVideos = <String>[];

          for (final update in updates) {
            if (update.photos != null) {
              allPhotos.addAll(update.photos!);
            }
            if (update.videos != null) {
              allVideos.addAll(update.videos!);
            }
          }

          if (allPhotos.isEmpty && allVideos.isEmpty) {
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
                          colors: [Colors.grey[300]!, Colors.grey[400]!],
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
                        Icons.photo_library_outlined,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Aucun média disponible',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Les médias apparaîtront ici',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            );
          }

          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.photo), text: 'Photos'),
                    Tab(icon: Icon(Icons.videocam), text: 'Vidéos'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      // Photos
                      allPhotos.isEmpty
                          ? Center(
                              child: Text(
                                'Aucune photo',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.all(8),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                  ),
                              itemCount: allPhotos.length,
                              itemBuilder: (context, index) {
                                final photoUrl = allPhotos[index];
                                final fullUrl = photoUrl.startsWith('http')
                                    ? photoUrl
                                    : '${ApiConfig.baseUrl.replaceAll('/api', '')}/$photoUrl';

                                return GestureDetector(
                                  onTap: () {
                                    _showImageDialog(context, fullUrl);
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
                                      errorWidget: (context, url, error) =>
                                          Container(
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.error),
                                          ),
                                    ),
                                  ),
                                );
                              },
                            ),
                      // Vidéos
                      allVideos.isEmpty
                          ? Center(
                              child: Text(
                                'Aucune vidéo',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.all(8),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                  ),
                              itemCount: allVideos.length,
                              itemBuilder: (context, index) {
                                final videoUrl = allVideos[index];
                                final fullUrl = videoUrl.startsWith('http')
                                    ? videoUrl
                                    : '${ApiConfig.baseUrl.replaceAll('/api', '')}/$videoUrl';

                                return GestureDetector(
                                  onTap: () {
                                    _showVideoDialog(context, fullUrl);
                                  },
                                  child: Card(
                                    clipBehavior: Clip.antiAlias,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        // Thumbnail de la vidéo
                                        Container(
                                          color: Colors.black,
                                          child: VideoThumbnailWidget(
                                            videoUrl: fullUrl,
                                          ),
                                        ),
                                        // Overlay avec icône de lecture
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(
                                              alpha: 0.3,
                                            ),
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.play_circle_filled,
                                              size: 64,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVideoDialog(BuildContext context, String videoUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Center(child: VideoPlayerWidget(videoUrl: videoUrl)),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget pour afficher une miniature de vidéo
class VideoThumbnailWidget extends StatefulWidget {
  final String videoUrl;

  const VideoThumbnailWidget({super.key, required this.videoUrl});

  @override
  State<VideoThumbnailWidget> createState() => _VideoThumbnailWidgetState();
}

class _VideoThumbnailWidgetState extends State<VideoThumbnailWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeThumbnail();
  }

  Future<void> _initializeThumbnail() async {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
      await _controller!.initialize();
      // S'assurer que la vidéo ne joue pas automatiquement
      _controller!.pause();
      // Aller à la première frame
      await _controller!.seekTo(Duration.zero);
      // Prendre la première frame comme thumbnail
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      // En cas d'erreur, on affiche juste une icône
      if (mounted) {
        setState(() {
          _isInitialized = true; // Pour afficher l'icône d'erreur
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return Container(
        color: Colors.grey[900],
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        ),
      );
    }

    // Afficher la première frame de la vidéo comme thumbnail
    return VideoPlayer(_controller!);
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
