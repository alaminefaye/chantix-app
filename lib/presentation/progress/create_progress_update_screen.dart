import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../projects/project_provider.dart';
import 'progress_provider.dart';

class CreateProgressUpdateScreen extends StatefulWidget {
  final int projectId;

  const CreateProgressUpdateScreen({super.key, required this.projectId});

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
  final List<File> _photos = [];
  final List<File> _videos = [];
  File? _audioFile;
  bool _isRecording = false;
  Position? _position;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _audioRecorder.dispose();
    super.dispose();
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

  Future<void> _handlePermissionDenied(String permissionName, PermissionStatus status) async {
    if (!mounted) return;
    
    if (status.isPermanentlyDenied) {
      final shouldOpen = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Permission requise'),
          content: Text(
            'La permission $permissionName est requise. '
            'Voulez-vous ouvrir les paramètres pour l\'activer ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Ouvrir les paramètres'),
            ),
          ],
        ),
      );
      
      if (shouldOpen == true && mounted) {
        await openAppSettings();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Permission $permissionName refusée'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _pickPhotos() async {
    if (!mounted) return;
    
    try {
      // Sur iOS, pas besoin de permission pour la galerie
      // Sur Android, demander la permission
      if (Platform.isAndroid) {
        final status = await Permission.photos.request();
        if (!status.isGranted) {
          await _handlePermissionDenied('galerie', status);
          return;
        }
      }

      // Utiliser pickMultiImage pour Android, pickImage pour iOS
      List<XFile> selectedImages = [];
      
      if (Platform.isAndroid) {
        // Android supporte la sélection multiple
        try {
          selectedImages = await _imagePicker.pickMultiImage(
            imageQuality: 80,
          );
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
            content: Text('Erreur lors de la sélection: ${e.toString().length > 100 ? e.toString().substring(0, 100) + '...' : e.toString()}'),
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
      // Vérifier et demander la permission caméra
      final status = await Permission.camera.request();
      
      if (!status.isGranted) {
        await _handlePermissionDenied('caméra', status);
        return;
      }

      // Attendre un peu pour s'assurer que la permission est bien accordée
      await Future.delayed(const Duration(milliseconds: 100));
      
      if (!mounted) return;

      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null && mounted) {
        setState(() {
          _photos.add(File(image.path));
        });
      }
    } catch (e, stackTrace) {
      debugPrint('Erreur lors de la prise de photo: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la prise de photo: ${e.toString().length > 100 ? e.toString().substring(0, 100) + '...' : e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _pickVideos() async {
    if (!mounted) return;
    
    try {
      // Sur iOS, pas besoin de permission pour la galerie
      // Sur Android, demander la permission
      if (Platform.isAndroid) {
        final status = await Permission.photos.request();
        if (!status.isGranted) {
          await _handlePermissionDenied('galerie vidéo', status);
          return;
        }
      }

      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;

      final video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
      );

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
            content: Text('Erreur lors de la sélection de vidéo: ${e.toString().length > 100 ? e.toString().substring(0, 100) + '...' : e.toString()}'),
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
      // Demander permission caméra
      final cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        await _handlePermissionDenied('caméra', cameraStatus);
        return;
      }

      // Demander permission microphone
      final micStatus = await Permission.microphone.request();
      if (!micStatus.isGranted) {
        await _handlePermissionDenied('microphone', micStatus);
        return;
      }

      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;

      final video = await _imagePicker.pickVideo(
        source: ImageSource.camera,
      );

      if (video != null && mounted) {
        setState(() {
          _videos.add(File(video.path));
        });
      }
    } catch (e, stackTrace) {
      debugPrint('Erreur lors de l\'enregistrement vidéo: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'enregistrement: ${e.toString().length > 100 ? e.toString().substring(0, 100) + '...' : e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _startRecording() async {
    if (!mounted) return;
    
    try {
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        if (mounted) {
          String message = 'Permission de microphone refusée';
          if (status.isPermanentlyDenied) {
            message = 'Permission de microphone refusée définitivement. Veuillez l\'activer dans les paramètres.';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      if (await _audioRecorder.hasPermission()) {
        final directory = await getTemporaryDirectory();
        final path = '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _audioRecorder.start(
          const RecordConfig(),
          path: path,
        );

        if (mounted) {
          setState(() {
            _isRecording = true;
            _audioFile = File(path);
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permission de microphone non accordée par l\'enregistreur audio'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Erreur lors de l\'enregistrement audio: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'enregistrement: ${e.toString().length > 100 ? e.toString().substring(0, 100) + '...' : e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        if (path != null) {
          _audioFile = File(path);
        }
      });
    } catch (e) {
      setState(() {
        _isRecording = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
          ),
        );
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

    final progressProvider =
        Provider.of<ProgressProvider>(context, listen: false);

    final success = await progressProvider.createProgressUpdate(
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

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mise à jour créée avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            progressProvider.errorMessage ?? 'Erreur lors de la création',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
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
                        'Nouvelle mise à jour',
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
                            color: const Color(0xFFB41839).withAlpha((255 * 0.1).round()),
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
                                    const Icon(Icons.location_on, color: Colors.blue),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                    padding: const EdgeInsets.symmetric(vertical: 12),
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
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_photos.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _photos.length,
                                itemBuilder: (context, index) {
                                  return Stack(
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 100,
                                        margin: const EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          image: DecorationImage(
                                            image: FileImage(_photos[index]),
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
                                              _photos.removeAt(index);
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
                                  label: const Text('Enregistrer'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
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
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_videos.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _videos.asMap().entries.map((entry) {
                                final index = entry.key;
                                return Stack(
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.grey[300],
                                      ),
                                      child: const Icon(Icons.videocam, size: 40),
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
                              }).toList(),
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
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _isRecording ? _stopRecording : _startRecording,
                                  icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                                  label: Text(_isRecording ? 'Arrêter' : 'Enregistrer'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isRecording ? Colors.red : Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_audioFile != null && !_isRecording)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                children: [
                                  const Icon(Icons.audiotrack, color: Colors.green),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Audio enregistré',
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
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
                                padding: const EdgeInsets.symmetric(vertical: 16),
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
                                            AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      'ENREGISTRER LA MISE À JOUR',
                                      style: TextStyle(
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

