import '../models/progress_update_model.dart';
import '../services/api_service.dart';
import 'dart:io';
import 'package:dio/dio.dart';

class ProgressRepository {
  final ApiService _apiService = ApiService();

  Future<List<ProgressUpdateModel>> getProgressUpdates(int projectId) async {
    try {
      final response = await _apiService.get('/v1/projects/$projectId/progress');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => ProgressUpdateModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> createProgressUpdate({
    required int projectId,
    required int progress,
    String? description,
    String? audioPath,
    double? latitude,
    double? longitude,
    List<File>? photos,
    List<File>? videos,
  }) async {
    try {
      // Créer FormData pour l'upload de fichiers
      final formData = FormData.fromMap({
        'progress': progress,
        if (description != null) 'description': description,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      });

      // Ajouter les photos
      if (photos != null && photos.isNotEmpty) {
        for (var photo in photos) {
          formData.files.add(
            MapEntry(
              'photos[]',
              await MultipartFile.fromFile(
                photo.path,
                filename: photo.path.split('/').last,
              ),
            ),
          );
        }
      }

      // Ajouter les vidéos
      if (videos != null && videos.isNotEmpty) {
        for (var video in videos) {
          formData.files.add(
            MapEntry(
              'videos[]',
              await MultipartFile.fromFile(
                video.path,
                filename: video.path.split('/').last,
              ),
            ),
          );
        }
      }

      // Ajouter l'audio
      if (audioPath != null) {
        final audioFile = File(audioPath);
        if (await audioFile.exists()) {
          formData.files.add(
            MapEntry(
              'audio_report',
              await MultipartFile.fromFile(
                audioPath,
                filename: audioPath.split('/').last,
              ),
            ),
          );
        }
      }

      // Utiliser la méthode postFormData de ApiService
      final response = await _apiService.postFormData(
        '/v1/projects/$projectId/progress',
        formData,
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        return {
          'success': true,
          'progressUpdate': ProgressUpdateModel.fromJson(
            data['data'] ?? data,
          ),
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Erreur lors de la création',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<bool> deleteProgressUpdate(int projectId, int progressUpdateId) async {
    try {
      final response = await _apiService.delete(
        '/v1/projects/$projectId/progress/$progressUpdateId',
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}

