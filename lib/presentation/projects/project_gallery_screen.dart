import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../data/repositories/progress_repository.dart';
import '../../config/api_config.dart';

class ProjectGalleryScreen extends StatefulWidget {
  final int projectId;

  const ProjectGalleryScreen({super.key, required this.projectId});

  @override
  State<ProjectGalleryScreen> createState() => _ProjectGalleryScreenState();
}

class _ProjectGalleryScreenState extends State<ProjectGalleryScreen>
    with SingleTickerProviderStateMixin {
  final ProgressRepository _repository = ProgressRepository();
  List<String> _allPhotos = [];
  List<String> _allVideos = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadGallery();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadGallery() async {
    setState(() => _isLoading = true);
    final updates = await _repository.getProgressUpdates(widget.projectId);

    final photos = <String>[];
    final videos = <String>[];

    for (final update in updates) {
      if (update.photos != null) {
        photos.addAll(update.photos!);
      }
      if (update.videos != null) {
        videos.addAll(update.videos!);
      }
    }

    setState(() {
      _allPhotos = photos;
      _allVideos = videos;
      _isLoading = false;
    });
  }

  String _getFullUrl(String path) {
    if (path.startsWith('http')) return path;
    // Si le chemin commence déjà par '/storage/' ou 'storage/', on l'utilise tel quel
    // car Storage::url() retourne déjà le chemin complet avec /storage/
    if (path.startsWith('/storage/') || path.startsWith('storage/')) {
      final cleanPath = path.startsWith('/') ? path : '/$path';
      return '${ApiConfig.baseUrl.replaceAll('/api', '')}$cleanPath';
    }
    // Sinon, on ajoute /storage/ devant
    return '${ApiConfig.baseUrl.replaceAll('/api', '')}/storage/$path';
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
              colors: [Color(0xFFB41839), Color(0xFF3F1B3D)],
            ),
          ),
        ),
        title: const Text(
          'Galerie',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.photo, size: 20),
                  const SizedBox(width: 8),
                  Text('Photos (${_allPhotos.length})'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.video_library, size: 20),
                  const SizedBox(width: 8),
                  Text('Vidéos (${_allVideos.length})'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [_buildPhotosTab(), _buildVideosTab()],
            ),
    );
  }

  Widget _buildPhotosTab() {
    if (_allPhotos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune photo disponible',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadGallery,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _allPhotos.length,
        itemBuilder: (context, index) {
          final photoUrl = _getFullUrl(_allPhotos[index]);
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => _PhotoViewerScreen(
                    photos: _allPhotos,
                    initialIndex: index,
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: photoUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.grey,
                        size: 32,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Erreur',
                        style: TextStyle(color: Colors.grey[600], fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideosTab() {
    if (_allVideos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune vidéo disponible',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadGallery,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _allVideos.length,
        itemBuilder: (context, index) {
          final videoUrl = _getFullUrl(_allVideos[index]);
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => _VideoPlayerScreen(videoUrl: videoUrl),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(color: Colors.black),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Thumbnail de la vidéo
                    VideoThumbnailWidget(videoUrl: videoUrl),
                    // Overlay avec icône de lecture
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.play_circle_filled,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    ),
                    // Label de la vidéo
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Text(
                        'Vidéo ${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PhotoViewerScreen extends StatelessWidget {
  final List<String> photos;
  final int initialIndex;

  const _PhotoViewerScreen({required this.photos, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        itemCount: photos.length,
        itemBuilder: (context, index) {
          final path = photos[index];
          final photoUrl = path.startsWith('http')
              ? path
              : path.startsWith('/storage/') || path.startsWith('storage/')
              ? '${ApiConfig.baseUrl.replaceAll('/api', '')}${path.startsWith('/') ? path : '/$path'}'
              : '${ApiConfig.baseUrl.replaceAll('/api', '')}/storage/$path';
          return Center(
            child: CachedNetworkImage(
              imageUrl: photoUrl,
              fit: BoxFit.contain,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              errorWidget: (context, url, error) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Erreur de chargement',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
  bool _hasError = false;

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
          _hasError = true;
          _isInitialized = true;
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
    if (!_isInitialized) {
      return Container(
        color: Colors.grey[900],
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        ),
      );
    }

    if (_hasError || _controller == null) {
      return Container(
        color: Colors.grey[900],
        child: const Center(
          child: Icon(Icons.video_library, color: Colors.white54, size: 32),
        ),
      );
    }

    // Afficher la première frame de la vidéo comme thumbnail
    return VideoPlayer(_controller!);
  }
}

// Widget pour lire les vidéos
class _VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const _VideoPlayerScreen({required this.videoUrl});

  @override
  State<_VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<_VideoPlayerScreen> {
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: _hasError
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Erreur de chargement de la vidéo',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      widget.videoUrl,
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
            : !_isInitialized || _chewieController == null
            ? const CircularProgressIndicator(color: Colors.white)
            : AspectRatio(
                aspectRatio: _videoAspectRatio ?? 16 / 9,
                child: Chewie(controller: _chewieController!),
              ),
      ),
    );
  }
}
