import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/models/project_model.dart';
import '../../data/models/attendance_model.dart';
import 'attendance_provider.dart';

class CheckOutScreen extends StatefulWidget {
  final ProjectModel project;
  final AttendanceModel attendance;

  const CheckOutScreen({
    super.key,
    required this.project,
    required this.attendance,
  });

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  File? _photo;
  Position? _position;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final status = await Permission.location.request();
      if (status.isDenied) {
        setState(() {
          _errorMessage = 'Permission de localisation refusée';
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _position = position;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Impossible d\'obtenir la localisation: $e';
      });
    }
  }

  Future<void> _takePhoto() async {
    try {
      final status = await Permission.camera.request();
      if (status.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permission de caméra refusée'),
          ),
        );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la prise de photo: $e'),
        ),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la sélection: $e'),
        ),
      );
    }
  }

  Future<void> _submitCheckOut() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final attendanceProvider =
        Provider.of<AttendanceProvider>(context, listen: false);

    final success = await attendanceProvider.checkOut(
      attendanceId: widget.attendance.id,
      projectId: widget.project.id,
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
          content: Text('Check-out effectué avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            attendanceProvider.errorMessage ?? 'Erreur lors du check-out',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatTime(String? timeString) {
    if (timeString == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(timeString);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timeString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: Stack(
          children: [
            // Zone de contenu blanche qui s'étend jusqu'en bas
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              top: MediaQuery.of(context).size.height * 0.25,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12),

                      // Informations du check-in
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB41839).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFB41839).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.login,
                                color: Color(0xFFB41839), size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Check-in effectué',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFB41839),
                                    ),
                                  ),
                                  if (widget.attendance.checkInTime != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Heure: ${_formatTime(widget.attendance.checkInTime)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF212121),
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
                                  const Icon(Icons.location_on,
                                      color: Color(0xFFB41839), size: 20),
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
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      'Obtention de la localisation...',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF212121),
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _getCurrentLocation,
                                    child: const Text('Réessayer'),
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
                            colors: [
                              Color(0xFFB41839),
                              Color(0xFF3F1B3D),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitCheckOut,
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
                                        Colors.white),
                                  ),
                                )
                              : const Text(
                                  'CONFIRMER LE CHECK-OUT',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                        ),
                      ),

                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            // Section supérieure avec titre
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Expanded(
                      child: Text(
                        'Check-out',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

