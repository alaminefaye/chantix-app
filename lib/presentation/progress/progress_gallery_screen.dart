import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
      Provider.of<ProgressProvider>(context, listen: false)
          .loadProgressUpdates(widget.projectId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Galerie de médias'),
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
                    'Aucun média disponible',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(
                      icon: Icon(Icons.photo),
                      text: 'Photos',
                    ),
                    Tab(
                      icon: Icon(Icons.videocam),
                      text: 'Vidéos',
                    ),
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
                                return Card(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.play_circle_outline,
                                        size: 48,
                                        color: Colors.red,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Vidéo ${index + 1}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
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
}

