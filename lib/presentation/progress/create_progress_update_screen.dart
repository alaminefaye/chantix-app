import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/progress_update_model.dart';
import '../../config/api_config.dart';
import '../projects/project_provider.dart';
import 'progress_provider.dart';

class CreateProgressUpdateScreen extends StatefulWidget {
  final int projectId;
  final ProgressUpdateModel? update; // Pour le mode édition

  const CreateProgressUpdateScreen({
    super.key,
    required this.projectId,
    this.update,
  });

  @override
  State<CreateProgressUpdateScreen> createState() =>
      _CreateProgressUpdateScreenState();
}

class _CreateProgressUpdateScreenState
    extends State<CreateProgressUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();

  int _progress = 0;
  final List<File> _photos = []; // Nouvelles photos
  final List<String> _existingPhotos = []; // URLs des photos existantes
  final List<File> _videos = []; // Nouvelles vidéos
  final List<String> _existingVideos = []; // URLs des vidéos existantes
  File? _audioFile;
  bool _isRecording = false;
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;
  Position? _position;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Si on est en mode édition, initialiser les valeurs
    if (widget.update != null) {
      _progress = widget.update!.progress;
      _descriptionController.text = widget.update!.description ?? '';
      // Initialiser les photos existantes (garder les URLs complètes pour l'affichage)
      if (widget.update!.photos != null && widget.update!.photos!.isNotEmpty) {
        _existingPhotos.addAll(widget.update!.photos!);
      }
      // Initialiser les vidéos existantes (garder les URLs complètes pour l'affichage)
      if (widget.update!.videos != null && widget.update!.videos!.isNotEmpty) {
        _existingVideos.addAll(widget.update!.videos!);
      }
      if (widget.update!.latitude != null && widget.update!.longitude != null) {
        _position = Position(
          latitude: widget.update!.latitude!,
          longitude: widget.update!.longitude!,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
      }
    } else {
      // En mode création, charger le dernier pourcentage d'avancement
      _loadLastProgress();
      _requestLocationPermission();
    }
  }

  /// Charge le dernier pourcentage d'avancement du projet
  Future<void> _loadLastProgress() async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    final projectProvider = Provider.of<ProjectProvider>(
      context,
      listen: false,
    );

    try {
      final project = projectProvider.projects.firstWhere(
        (p) => p.id == widget.projectId,
        orElse: () => projectProvider.selectedProject!,
      );

      // Utiliser le pourcentage actuel du projet
      if (project.progress > 0) {
        if (mounted) {
          setState(() {
            _progress = project.progress;
          });
        }
        return;
      }

      // Si le projet n'a pas de pourcentage, chercher dans les mises à jour
      final progressProvider = Provider.of<ProgressProvider>(
        context,
        listen: false,
      );

      // Charger les mises à jour si elles ne sont pas déjà chargées
      if (progressProvider.progressUpdates.isEmpty) {
        await progressProvider.loadProgressUpdates(widget.projectId);
      }

      if (progressProvider.progressUpdates.isNotEmpty) {
        // Trier par date de création (plus récent en premier)
        final sortedUpdates =
            List<ProgressUpdateModel>.from(progressProvider.progressUpdates)
              ..sort((a, b) {
                final dateA = a.createdAt != null
                    ? DateTime.tryParse(a.createdAt!)
                    : null;
                final dateB = b.createdAt != null
                    ? DateTime.tryParse(b.createdAt!)
                    : null;

                if (dateA == null && dateB == null) return 0;
                if (dateA == null) return 1;
                if (dateB == null) return -1;

                return dateB.compareTo(dateA);
              });

        // Prendre le pourcentage de la dernière mise à jour
        if (sortedUpdates.isNotEmpty && sortedUpdates.first.progress > 0) {
          if (mounted) {
            setState(() {
              _progress = sortedUpdates.first.progress;
            });
          }
        }
      }
    } catch (e) {
      // En cas d'erreur, garder 0% par défaut
      debugPrint('Erreur lors du chargement du dernier pourcentage: $e');
    }
  }

  String _getFullUrl(String url) {
    if (url.startsWith('http')) {
      return url;
    }
    if (url.startsWith('/storage/')) {
      return '${ApiConfig.baseUrl.replaceAll('/api', '')}$url';
    }
    return '${ApiConfig.baseUrl.replaceAll('/api', '')}/storage/$url';
  }

  // Extraire le chemin relatif depuis une URL complète
  String _extractRelativePath(String url) {
    if (!url.startsWith('http')) {
      // C'est déjà un chemin relatif
      return url;
    }
    // Extraire le chemin après /storage/
    final storageIndex = url.indexOf('/storage/');
    if (storageIndex != -1) {
      return url.substring(storageIndex + 9); // +9 pour sauter "/storage/"
    }
    // Si on ne trouve pas /storage/, essayer d'extraire le dernier segment
    final segments = url.split('/');
    if (segments.length > 2) {
      // Prendre les deux derniers segments (ex: progress/photos/file.jpg)
      return '${segments[segments.length - 2]}/${segments.last}';
    }
    return url;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _audioRecorder.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  void _startRecordingTimer() {
    _recordingDuration = Duration.zero;
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _isRecording) {
        setState(() {
          _recordingDuration = Duration(
            seconds: _recordingDuration.inSeconds + 1,
          );
        });
      } else {
        timer.cancel();
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _position = position;
      });
    } catch (e) {
      // Silently fail - location is optional
    }
  }

  Future<void> _pickPhotos() async {
    if (!mounted) return;

    try {
      // Sur iOS, pas besoin de permission pour la galerie
      // Sur Android, demander la permission simplement
      if (Platform.isAndroid) {
        final status = await Permission.photos.request();
        if (!status.isGranted) {
          return; // Permission refusée, on continue simplement
        }
      }

      // Utiliser pickMultiImage pour Android, pickImage pour iOS
      List<XFile> selectedImages = [];

      if (Platform.isAndroid) {
        // Android supporte la sélection multiple
        try {
          selectedImages = await _imagePicker.pickMultiImage(imageQuality: 80);
        } catch (e) {
          debugPrint('Erreur pickMultiImage: $e');
          // Fallback sur sélection simple
          final singleImage = await _imagePicker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 80,
          );
          if (singleImage != null) {
            selectedImages = [singleImage];
          }
        }
      } else {
        // iOS - sélection simple
        final image = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );
        if (image != null) {
          selectedImages = [image];
        }
      }

      if (selectedImages.isNotEmpty && mounted) {
        setState(() {
          _photos.addAll(selectedImages.map((image) => File(image.path)));
        });
      }
    } catch (e, stackTrace) {
      debugPrint('Erreur lors de la sélection de photos: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur lors de la sélection: ${e.toString().length > 100 ? e.toString().substring(0, 100) + '...' : e.toString()}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    if (!mounted) return;

    try {
      // Sur iOS, image_picker demande automatiquement la permission caméra
      // On l'appelle directement - il affichera la popup native iOS automatiquement
      // Exactement comme Geolocator pour la localisation
      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null && mounted) {
        setState(() {
          _photos.add(File(image.path));
        });
      }
    } catch (e) {
      // image_picker gère les permissions automatiquement
      // Si erreur, c'est que l'utilisateur a refusé ou annulé
      debugPrint('Erreur lors de la prise de photo: $e');
    }
  }

  Future<void> _pickVideos() async {
    if (!mounted) return;

    try {
      // Sur iOS, pas besoin de permission pour la galerie
      // Sur Android, demander la permission simplement
      if (Platform.isAndroid) {
        final status = await Permission.photos.request();
        if (!status.isGranted) {
          return; // Permission refusée, on continue simplement
        }
      }

      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;

      final video = await _imagePicker.pickVideo(source: ImageSource.gallery);

      if (video != null && mounted) {
        setState(() {
          _videos.add(File(video.path));
        });
      }
    } catch (e, stackTrace) {
      debugPrint('Erreur lors de la sélection de vidéo: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur lors de la sélection de vidéo: ${e.toString().length > 100 ? e.toString().substring(0, 100) + '...' : e.toString()}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _recordVideo() async {
    if (!mounted) return;

    try {
      // Sur iOS, image_picker demande automatiquement les permissions caméra et microphone
      // On l'appelle directement - il affichera les popups natives iOS automatiquement
      // Exactement comme Geolocator pour la localisation
      final video = await _imagePicker.pickVideo(source: ImageSource.camera);

      if (video != null && mounted) {
        setState(() {
          _videos.add(File(video.path));
        });
      }
    } catch (e) {
      // image_picker gère les permissions automatiquement
      // Si erreur, c'est que l'utilisateur a refusé ou annulé
      debugPrint('Erreur lors de l\'enregistrement vidéo: $e');
    }
  }

  Future<void> _startRecording() async {
    if (!mounted) return;

    try {
      // Approche simplifiée : essayer directement de démarrer l'enregistrement
      // et gérer les erreurs de permission si nécessaire

      // Préparer le chemin pour l'enregistrement
      final directory = await getTemporaryDirectory();
      final path =
          '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

      debugPrint('Tentative de démarrage de l\'enregistrement: $path');

      // Essayer directement de démarrer l'enregistrement
      // Si la permission n'est pas accordée, une erreur sera levée
      try {
        // Configurer l'enregistrement en format AAC/M4A pour garantir la compatibilité avec le serveur
        await _audioRecorder.start(
          RecordConfig(
            encoder: AudioEncoder.aacLc, // AAC Low Complexity pour format M4A
            bitRate: 128000, // 128 kbps
            sampleRate: 44100, // 44.1 kHz
          ),
          path: path,
        );
        debugPrint('Enregistrement démarré avec succès en format AAC/M4A');

        if (mounted) {
          setState(() {
            _isRecording = true;
            _audioFile = File(path);
          });

          // Démarrer le timer pour afficher la durée
          _startRecordingTimer();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Enregistrement audio démarré'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
        return; // Succès, on sort
      } catch (e) {
        debugPrint('Erreur lors du démarrage: $e');

        // Si l'erreur n'est pas liée à la permission, propager l'erreur
        final errorString = e.toString().toLowerCase();
        if (!errorString.contains('permission') &&
            !errorString.contains('denied') &&
            !errorString.contains('microphone') &&
            !errorString.contains('unauthorized')) {
          // Autre erreur, la propager
          rethrow;
        }

        // Erreur liée à la permission, vérifier le statut
        var status = await Permission.microphone.status;
        debugPrint('Statut permission après erreur: $status');

        // Si définitivement refusée, proposer d'aller dans les paramètres
        if (status.isPermanentlyDenied) {
          if (mounted) {
            final result = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Permission microphone requise'),
                content: const Text(
                  'Pour enregistrer des rapports audio, veuillez activer la permission microphone dans les paramètres de l\'application.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Annuler'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Paramètres'),
                  ),
                ],
              ),
            );

            if (result == true) {
              await openAppSettings();
              // Attendre que l'utilisateur revienne
              await Future.delayed(const Duration(seconds: 2));

              // Réessayer après le retour
              status = await Permission.microphone.status;
              debugPrint('Statut après retour des paramètres: $status');

              if (status.isGranted) {
                // Réessayer de démarrer l'enregistrement
                try {
                  await _audioRecorder.start(const RecordConfig(), path: path);
                  debugPrint(
                    'Enregistrement démarré avec succès après activation',
                  );

                  if (mounted) {
                    setState(() {
                      _isRecording = true;
                      _audioFile = File(path);
                    });
                    _startRecordingTimer();
                  }
                  return;
                } catch (e2) {
                  debugPrint('Erreur lors du réessai: $e2');
                }
              }
            }
          }
          return;
        }

        // Si pas définitivement refusée, demander la permission
        if (!status.isGranted) {
          debugPrint('Demande de permission microphone...');
          status = await Permission.microphone.request();
          debugPrint('Résultat de la demande: $status');

          if (status.isGranted) {
            // Réessayer de démarrer l'enregistrement
            try {
              await _audioRecorder.start(const RecordConfig(), path: path);
              debugPrint(
                'Enregistrement démarré avec succès après autorisation',
              );

              if (mounted) {
                setState(() {
                  _isRecording = true;
                  _audioFile = File(path);
                });
                _startRecordingTimer();
              }
              return;
            } catch (e2) {
              debugPrint('Erreur lors du démarrage après autorisation: $e2');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur: ${e2.toString()}'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
              return;
            }
          } else {
            // Permission refusée
            debugPrint('Permission refusée par l\'utilisateur');
            return;
          }
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Erreur lors de l\'enregistrement audio: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur lors du démarrage de l\'enregistrement: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      // Arrêter le timer
      _recordingTimer?.cancel();

      final path = await _audioRecorder.stop();
      if (path != null) {
        // S'assurer que le fichier a l'extension .m4a pour la compatibilité avec le serveur
        File audioFile = File(path);
        String finalPath = path;

        // Vérifier et corriger l'extension si nécessaire
        if (!path.toLowerCase().endsWith('.m4a')) {
          final directory = await getTemporaryDirectory();
          final newPath =
              '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
          // Copier le fichier avec la bonne extension
          audioFile = await audioFile.copy(newPath);
          finalPath = newPath;

          // Supprimer l'ancien fichier
          try {
            await File(path).delete();
          } catch (e) {
            debugPrint('Impossible de supprimer l\'ancien fichier: $e');
          }
        }

        debugPrint('🎤 Fichier audio enregistré:');
        debugPrint('  - Chemin original: $path');
        debugPrint('  - Chemin final: $finalPath');
        debugPrint('  - Extension: ${finalPath.split('.').last}');

        setState(() {
          _isRecording = false;
          _audioFile = File(finalPath);
          _recordingDuration = Duration.zero;
        });
      } else {
        setState(() {
          _isRecording = false;
          _recordingDuration = Duration.zero;
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Enregistrement arrêté (${_formatDuration(_recordingDuration)})',
            ),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      _recordingTimer?.cancel();
      setState(() {
        _isRecording = false;
        _recordingDuration = Duration.zero;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final progressProvider = Provider.of<ProgressProvider>(
      context,
      listen: false,
    );

    final bool success;
    if (widget.update != null) {
      // Mode édition
      success = await progressProvider.updateProgressUpdate(
        projectId: widget.projectId,
        progressUpdateId: widget.update!.id,
        progress: _progress,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        audioPath: _audioFile?.path,
        latitude: _position?.latitude,
        longitude: _position?.longitude,
        photos: _photos.isEmpty ? null : _photos,
        videos: _videos.isEmpty ? null : _videos,
        existingPhotos: _existingPhotos.isEmpty
            ? null
            : _existingPhotos.map((url) => _extractRelativePath(url)).toList(),
        existingVideos: _existingVideos.isEmpty
            ? null
            : _existingVideos.map((url) => _extractRelativePath(url)).toList(),
      );
    } else {
      // Mode création
      success = await progressProvider.createProgressUpdate(
        projectId: widget.projectId,
        progress: _progress,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        audioPath: _audioFile?.path,
        latitude: _position?.latitude,
        longitude: _position?.longitude,
        photos: _photos.isEmpty ? null : _photos,
        videos: _videos.isEmpty ? null : _videos,
      );
    }

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.update != null
                ? 'Mise à jour modifiée avec succès'
                : 'Mise à jour créée avec succès',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else if (mounted) {
      final errorMessage =
          progressProvider.errorMessage ??
          (widget.update != null
              ? 'Erreur lors de la modification'
              : 'Erreur lors de la création');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(
      context,
      listen: false,
    );
    final project = projectProvider.projects.firstWhere(
      (p) => p.id == widget.projectId,
      orElse: () => projectProvider.selectedProject!,
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFB41839), // Rouge
              const Color(0xFF3F1B3D), // Violet foncé
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Text(
                        widget.update != null
                            ? 'Modifier la mise à jour'
                            : 'Nouvelle mise à jour',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Projet info
                          Card(
                            color: const Color(
                              0xFFB41839,
                            ).withAlpha((255 * 0.1).round()),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.construction,
                                    color: Color(0xFFB41839),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      project.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Pourcentage d'avancement
                          Text(
                            'Pourcentage d\'avancement',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$_progress%',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB41839),
                            ),
                          ),
                          Slider(
                            value: _progress.toDouble(),
                            min: 0,
                            max: 100,
                            divisions: 100,
                            label: '$_progress%',
                            activeColor: const Color(0xFFB41839),
                            onChanged: (value) {
                              setState(() {
                                _progress = value.toInt();
                              });
                            },
                          ),
                          const SizedBox(height: 24),

                          // Description
                          TextFormField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              labelText: 'Description (optionnel)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            maxLines: 5,
                            textInputAction: TextInputAction.newline,
                          ),
                          const SizedBox(height: 24),

                          // Géolocalisation
                          if (_position != null)
                            Card(
                              color: Colors.blue[50],
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Localisation',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '${_position!.latitude.toStringAsFixed(6)}, ${_position!.longitude.toStringAsFixed(6)}',
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
                          const SizedBox(height: 24),

                          // Photos
                          Text(
                            'Photos',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _takePhoto,
                                  icon: const Icon(Icons.camera_alt),
                                  label: const Text('Prendre une photo'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _pickPhotos,
                                  icon: const Icon(Icons.photo_library),
                                  label: const Text('Galerie'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Afficher les photos existantes et nouvelles
                          if (_existingPhotos.isNotEmpty ||
                              _photos.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount:
                                    _existingPhotos.length + _photos.length,
                                itemBuilder: (context, index) {
                                  final bool isExisting =
                                      index < _existingPhotos.length;
                                  final int actualIndex = isExisting
                                      ? index
                                      : index - _existingPhotos.length;

                                  return Stack(
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 100,
                                        margin: const EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          color: Colors.grey[300],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: isExisting
                                              ? CachedNetworkImage(
                                                  imageUrl: _getFullUrl(
                                                    _existingPhotos[actualIndex],
                                                  ),
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
                                                      const Center(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      ),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          const Icon(
                                                            Icons.error,
                                                          ),
                                                )
                                              : Image(
                                                  image: FileImage(
                                                    _photos[actualIndex],
                                                  ),
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              if (isExisting) {
                                                _existingPhotos.removeAt(
                                                  actualIndex,
                                                );
                                              } else {
                                                _photos.removeAt(actualIndex);
                                              }
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),

                          // Vidéos
                          Text(
                            'Vidéos',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _recordVideo,
                                  icon: const Icon(Icons.videocam),
                                  label: const Text('Enregistrer une vidéo'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _pickVideos,
                                  icon: const Icon(Icons.video_library),
                                  label: const Text('Galerie'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Afficher les vidéos existantes et nouvelles
                          if (_existingVideos.isNotEmpty ||
                              _videos.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                // Vidéos existantes
                                ..._existingVideos.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  return Stack(
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          color: Colors.grey[300],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl: _getFullUrl(entry.value),
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                const Center(
                                                  child: Icon(
                                                    Icons.videocam,
                                                    size: 40,
                                                  ),
                                                ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(
                                                      Icons.videocam,
                                                      size: 40,
                                                    ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _existingVideos.removeAt(index);
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                                // Nouvelles vidéos
                                ..._videos.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  return Stack(
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          color: Colors.grey[300],
                                        ),
                                        child: const Icon(
                                          Icons.videocam,
                                          size: 40,
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _videos.removeAt(index);
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ],
                          const SizedBox(height: 24),

                          // Audio
                          Text(
                            'Rapport audio',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Affichage pendant l'enregistrement
                          if (_isRecording) ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.red[300]!,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                children: [
                                  // Animation et temps
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Animation d'ondes sonores
                                      _RecordingAnimation(),
                                      const SizedBox(width: 16),
                                      // Temps écoulé
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Enregistrement en cours',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red[700],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _formatDuration(_recordingDuration),
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red[900],
                                              fontFeatures: [
                                                const FontFeature.tabularFigures(),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  // Bouton arrêter
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: _stopRecording,
                                      icon: const Icon(Icons.stop),
                                      label: const Text(
                                        'Arrêter l\'enregistrement',
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            // Bouton pour démarrer l'enregistrement
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _startRecording,
                                    icon: const Icon(Icons.mic),
                                    label: const Text('Enregistrer'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (_audioFile != null && !_isRecording)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.audiotrack,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Audio enregistré',
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _audioFile = null;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 32),

                          // Bouton de soumission
                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFB41839), Color(0xFF3F1B3D)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : Text(
                                      widget.update != null
                                          ? 'MODIFIER LA MISE À JOUR'
                                          : 'ENREGISTRER LA MISE À JOUR',
                                      style: const TextStyle(
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
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget d'animation pour l'enregistrement audio
class _RecordingAnimation extends StatefulWidget {
  const _RecordingAnimation();

  @override
  State<_RecordingAnimation> createState() => _RecordingAnimationState();
}

class _RecordingAnimationState extends State<_RecordingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red,
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.5),
                blurRadius: 20 * _animation.value,
                spreadRadius: 5 * _animation.value,
              ),
            ],
          ),
          child: const Icon(Icons.mic, color: Colors.white, size: 30),
        );
      },
    );
  }
}
