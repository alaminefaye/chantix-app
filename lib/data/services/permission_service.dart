import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:record/record.dart';

/// Service pour gérer toutes les permissions de l'application
class PermissionService {
  /// Demande toutes les permissions nécessaires au démarrage de l'application
  /// Retourne true si toutes les permissions sont accordées
  static Future<bool> requestAllPermissions() async {
    try {
      // 1. Permission de localisation
      await _requestLocationPermission();

      // 2. Permission de caméra
      await _requestCameraPermission();

      // 3. Permission de microphone
      await _requestMicrophonePermission();

      // 4. Permission de photos (pour Android uniquement)
      await _requestPhotosPermission();

      return true;
    } catch (e) {
      print('Erreur lors de la demande de permissions: $e');
      return false;
    }
  }

  /// Demande la permission de localisation (comme dans check_in_screen)
  static Future<void> _requestLocationPermission() async {
    try {
      // Vérifier si le service de localisation est activé
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Le service n'est pas activé, mais on continue quand même
        // L'utilisateur pourra l'activer plus tard
        return;
      }

      // Vérifier les permissions avec geolocator
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        // Demander la permission - affichera la popup native iOS automatiquement
        permission = await Geolocator.requestPermission();
      }

      // Si définitivement refusée, on continue quand même
      // L'utilisateur pourra l'activer dans les paramètres plus tard
    } catch (e) {
      print('Erreur lors de la demande de permission de localisation: $e');
    }
  }

  /// Demande la permission de caméra
  static Future<void> _requestCameraPermission() async {
    try {
      var status = await Permission.camera.status;

      // Si définitivement refusée, on ne peut plus la demander
      if (status.isPermanentlyDenied) {
        return;
      }

      // Si pas accordée, demander la permission
      // Cela affichera la boîte de dialogue native iOS
      if (!status.isGranted) {
        await Permission.camera.request();
      }
    } catch (e) {
      print('Erreur lors de la demande de permission caméra: $e');
    }
  }

  /// Demande la permission de microphone
  /// Utilise la même approche que la localisation pour afficher la boîte de dialogue native
  static Future<void> _requestMicrophonePermission() async {
    try {
      var status = await Permission.microphone.status;

      // Si définitivement refusée, on ne peut plus la demander
      // L'utilisateur devra l'activer dans les paramètres
      if (status.isPermanentlyDenied) {
        print(
          'Permission microphone définitivement refusée - doit être activée dans les paramètres',
        );
        return;
      }

      // Si pas accordée, demander la permission
      // Cela affichera la boîte de dialogue native iOS automatiquement
      if (!status.isGranted) {
        print('Demande de permission microphone...');
        status = await Permission.microphone.request();
        print('Résultat permission microphone: $status');
      }

      // Vérifier aussi avec AudioRecorder (il a sa propre vérification)
      final audioRecorder = AudioRecorder();
      if (!await audioRecorder.hasPermission()) {
        print('AudioRecorder n\'a pas la permission microphone');
      }
      audioRecorder.dispose();
    } catch (e) {
      print('Erreur lors de la demande de permission microphone: $e');
    }
  }

  /// Demande la permission de photos (Android uniquement)
  static Future<void> _requestPhotosPermission() async {
    try {
      // Sur iOS, pas besoin de permission pour la galerie
      // Sur Android, demander la permission si nécessaire
      final status = await Permission.photos.status;
      if (status.isDenied) {
        await Permission.photos.request();
      }
    } catch (e) {
      print('Erreur lors de la demande de permission photos: $e');
    }
  }

  /// Vérifie si toutes les permissions sont accordées
  static Future<bool> areAllPermissionsGranted() async {
    try {
      // Vérifier la localisation
      LocationPermission locationPermission =
          await Geolocator.checkPermission();
      bool locationGranted =
          locationPermission == LocationPermission.whileInUse ||
          locationPermission == LocationPermission.always;

      // Vérifier la caméra
      bool cameraGranted = await Permission.camera.isGranted;

      // Vérifier le microphone
      bool microphoneGranted = await Permission.microphone.isGranted;

      return locationGranted && cameraGranted && microphoneGranted;
    } catch (e) {
      print('Erreur lors de la vérification des permissions: $e');
      return false;
    }
  }
}
