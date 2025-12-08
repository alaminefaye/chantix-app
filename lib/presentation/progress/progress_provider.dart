import 'package:flutter/foundation.dart';
import '../../data/models/progress_update_model.dart';
import '../../data/repositories/progress_repository.dart';
import 'dart:io';

class ProgressProvider with ChangeNotifier {
  final ProgressRepository _repository = ProgressRepository();

  List<ProgressUpdateModel> _progressUpdates = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ProgressUpdateModel> get progressUpdates => _progressUpdates;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadProgressUpdates(int projectId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _progressUpdates = await _repository.getProgressUpdates(projectId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createProgressUpdate({
    required int projectId,
    required int progress,
    String? description,
    String? audioPath,
    double? latitude,
    double? longitude,
    List<File>? photos,
    List<File>? videos,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.createProgressUpdate(
        projectId: projectId,
        progress: progress,
        description: description,
        audioPath: audioPath,
        latitude: latitude,
        longitude: longitude,
        photos: photos,
        videos: videos,
      );
      _isLoading = false;

      if (result['success'] == true) {
        await loadProgressUpdates(projectId);
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('Erreur dans createProgressUpdate: $e');
      debugPrint('Stack trace: $stackTrace');

      // Extraire un message d'erreur plus lisible
      String errorMsg = 'Erreur lors de la création';
      if (e.toString().contains('422')) {
        errorMsg =
            'Les données fournies sont invalides. Veuillez vérifier les informations saisies.';
      } else if (e.toString().contains('network') ||
          e.toString().contains('timeout')) {
        errorMsg = 'Erreur de connexion. Vérifiez votre connexion internet.';
      } else {
        errorMsg = e.toString();
        // Limiter la longueur du message d'erreur
        if (errorMsg.length > 200) {
          errorMsg = '${errorMsg.substring(0, 200)}...';
        }
      }

      _errorMessage = errorMsg;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProgressUpdate({
    required int projectId,
    required int progressUpdateId,
    required int progress,
    String? description,
    String? audioPath,
    double? latitude,
    double? longitude,
    List<File>? photos,
    List<File>? videos,
    List<String>? existingPhotos,
    List<String>? existingVideos,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.updateProgressUpdate(
        projectId: projectId,
        progressUpdateId: progressUpdateId,
        progress: progress,
        description: description,
        audioPath: audioPath,
        latitude: latitude,
        longitude: longitude,
        photos: photos,
        videos: videos,
        existingPhotos: existingPhotos,
        existingVideos: existingVideos,
      );
      _isLoading = false;

      if (result['success'] == true) {
        await loadProgressUpdates(projectId);
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProgressUpdate(int projectId, int progressUpdateId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _repository.deleteProgressUpdate(
        projectId,
        progressUpdateId,
      );
      _isLoading = false;

      if (success) {
        _progressUpdates.removeWhere((p) => p.id == progressUpdateId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _isLoading = false;
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
