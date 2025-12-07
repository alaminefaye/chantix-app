import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/models/project_model.dart';
import '../auth/auth_provider.dart';
import 'attendance_provider.dart';

class CheckInScreen extends StatefulWidget {
  final ProjectModel project;

  const CheckInScreen({super.key, required this.project});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  File? _photo;
  Position? _position;
  bool _isLoading = false;
  bool _isLoadingLocation = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  // Vérifier simplement le statut sans demander
  Future<void> _checkLocationPermission() async {
    try {
      // Utiliser locationWhenInUse pour iOS (plus approprié)
      final status = await Permission.locationWhenInUse.status;
      if (status.isGranted) {
        await _getCurrentLocation();
      }
    } catch (e) {
      // Ignorer les erreurs silencieusement
    }
  }

  // Demander la permission (affichera la popup native iOS - simple comme pour la caméra)
  Future<void> _requestLocationPermission() async {
    print('🔵 DEBUG: Bouton Activer cliqué - début');

    if (!mounted) {
      print('🔴 DEBUG: Widget pas monté');
      return;
    }

    if (_isLoadingLocation) {
      print('🟡 DEBUG: Déjà en cours');
      return;
    }

    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Méthode 1: Utiliser geolocator directement (plus simple)
      print('🔵 DEBUG: Vérification du service de localisation');
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print('🔵 DEBUG: Service activé: $serviceEnabled');

      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Veuillez activer la localisation dans les paramètres',
              ),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // Vérifier les permissions avec geolocator
      print('🔵 DEBUG: Vérification des permissions avec geolocator');
      LocationPermission permission = await Geolocator.checkPermission();
      print('🔵 DEBUG: Permission actuelle: $permission');

      if (permission == LocationPermission.denied) {
        print('🔵 DEBUG: Permission refusée, demande de permission');
        permission = await Geolocator.requestPermission();
        print('🔵 DEBUG: Nouvelle permission: $permission');
      }

      if (permission == LocationPermission.deniedForever) {
        print('🔴 DEBUG: Permission définitivement refusée');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Permission définitivement refusée. Activez-la dans les paramètres',
              ),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      if (permission == LocationPermission.denied) {
        print('🔴 DEBUG: Permission toujours refusée');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permission de localisation refusée'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // Permission accordée, obtenir la localisation
      print('🟢 DEBUG: Permission accordée, obtention de la localisation');
      await _getCurrentLocation();
    } catch (e, stackTrace) {
      print('🔴 DEBUG: Erreur: $e');
      print('🔴 DEBUG: Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
        print('🔵 DEBUG: Fin de la demande');
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Vérifier si le service de localisation est activé
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage =
              null; // Pas d'erreur, juste pas de localisation disponible
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      setState(() {
        _position = position;
        _errorMessage =
            null; // Réinitialiser l'erreur si on obtient la position
      });
    } catch (e) {
      // En cas d'erreur, on continue sans localisation (c'est optionnel)
      setState(() {
        _errorMessage = null; // Ne pas bloquer l'utilisateur
      });
    }
  }

  Future<void> _takePhoto() async {
    try {
      final status = await Permission.camera.request();
      if (status.isDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permission de caméra refusée')),
          );
        }
        return;
      }

      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _photo = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la prise de photo: $e')),
        );
      }
    }
  }

  Future<void> _pickPhotoFromGallery() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _photo = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la sélection: $e')),
        );
      }
    }
  }

  Future<void> _submitCheckIn() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id;

    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Utilisateur non connecté')));
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final attendanceProvider = Provider.of<AttendanceProvider>(
      context,
      listen: false,
    );

    final success = await attendanceProvider.checkIn(
      projectId: widget.project.id,
      employeeId: userId,
      latitude: _position?.latitude,
      longitude: _position?.longitude,
      photoPath: _photo?.path,
    );

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Check-in effectué avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            attendanceProvider.errorMessage ?? 'Erreur lors du check-in',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Check-in',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),

            // Informations du projet
            const Text(
              'Projet',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFFB41839),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.construction,
                    color: Color(0xFFB41839),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.project.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF212121),
                          ),
                        ),
                        if (widget.project.address != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.project.address!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Localisation
            const Text(
              'Localisation',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFFB41839),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: _position != null
                  ? Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Color(0xFFB41839),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Lat: ${_position!.latitude.toStringAsFixed(6)}\nLng: ${_position!.longitude.toStringAsFixed(6)}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF212121),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        _isLoadingLocation
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.location_off,
                                color: Colors.grey,
                                size: 20,
                              ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Localisation non disponible (optionnel)',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ),
                        TextButton(
                          onPressed: _isLoadingLocation
                              ? null
                              : () {
                                  _requestLocationPermission();
                                },
                          child: const Text('Activer'),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 20),

            // Photo
            const Text(
              'Photo (optionnel)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFFB41839),
              ),
            ),
            const SizedBox(height: 6),
            if (_photo != null)
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _photo!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: _takePhoto,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Reprendre'),
                      ),
                      TextButton.icon(
                        onPressed: _pickPhotoFromGallery,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Changer'),
                      ),
                    ],
                  ),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _takePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Prendre une photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: const Color(0xFF212121),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _pickPhotoFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galerie'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: const Color(0xFF212121),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 24),

            // Bouton de soumission
            Container(
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFFB41839), Color(0xFF3F1B3D)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitCheckIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'CONFIRMER LE CHECK-IN',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
              ),
            ),

            // Note: La localisation est optionnelle, on n'affiche pas d'erreur bloquante
            if (_errorMessage != null && _errorMessage!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.orange[900],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
