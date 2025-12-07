import '../models/progress_update_model.dart';
import '../services/api_service.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

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
      // S'assurer que progress est un entier
      final formData = FormData.fromMap({
        'progress': progress, // Envoyer comme entier
        if (description != null && description.isNotEmpty) 'description': description,
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
        final responseData = response.data;
        debugPrint('Progress update response: $responseData');
        
        // Extraire les données de la réponse
        final data = responseData['data'] ?? responseData;
        debugPrint('Progress update data to parse: $data');
        
        try {
          final progressUpdate = ProgressUpdateModel.fromJson(
            data is Map<String, dynamic> ? data : Map<String, dynamic>.from(data),
          );
          return {
            'success': true,
            'progressUpdate': progressUpdate,
          };
        } catch (parseError, stackTrace) {
          debugPrint('Erreur lors du parsing du ProgressUpdateModel: $parseError');
          debugPrint('Stack trace: $stackTrace');
          debugPrint('Données reçues: $data');
          return {
            'success': false,
            'message': 'Erreur lors du parsing des données: ${parseError.toString()}',
          };
        }
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Erreur lors de la création',
      };
    } catch (e, stackTrace) {
      debugPrint('Erreur lors de la création de la mise à jour: $e');
      debugPrint('Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Erreur: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> updateProgressUpdate({
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
    try {
      // Créer FormData pour l'upload de fichiers
      // Utiliser POST avec _method=PUT car certains serveurs ont des problèmes avec PUT et FormData
      final Map<String, dynamic> formDataMap = {
        '_method': 'PUT', // Méthode spoofing pour Laravel
        'progress': progress, // Laisser comme int
      };
      
      // Ajouter les champs optionnels seulement s'ils ont une valeur
      if (description != null && description.trim().isNotEmpty) {
        formDataMap['description'] = description.trim();
      }
      if (latitude != null) {
        formDataMap['latitude'] = latitude;
      }
      if (longitude != null) {
        formDataMap['longitude'] = longitude;
      }
      
      final formData = FormData.fromMap(formDataMap);

      // Ajouter les photos existantes à conserver (format Laravel: existing_photos[])
      if (existingPhotos != null && existingPhotos.isNotEmpty) {
        for (var photo in existingPhotos) {
          formData.fields.add(MapEntry('existing_photos[]', photo));
        }
      }

      // Ajouter les vidéos existantes à conserver (format Laravel: existing_videos[])
      if (existingVideos != null && existingVideos.isNotEmpty) {
        for (var video in existingVideos) {
          formData.fields.add(MapEntry('existing_videos[]', video));
        }
      }

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

      // Debug: afficher les données envoyées
      debugPrint('📤 Envoi de la mise à jour:');
      debugPrint('  - Progress: $progress');
      debugPrint('  - Description: $description');
      debugPrint('  - Existing photos: ${existingPhotos?.length ?? 0}');
      debugPrint('  - Existing videos: ${existingVideos?.length ?? 0}');
      debugPrint('  - New photos: ${photos?.length ?? 0}');
      debugPrint('  - New videos: ${videos?.length ?? 0}');
      debugPrint('  - FormData fields: ${formData.fields.length}');
      debugPrint('  - FormData files: ${formData.files.length}');

      // Utiliser POST avec _method=PUT pour éviter les problèmes avec PUT et FormData
      final response = await _apiService.postFormData(
        '/v1/projects/$projectId/progress/$progressUpdateId',
        formData,
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        debugPrint('✅ Progress update response: $responseData');
        
        // Extraire les données de la réponse
        final data = responseData['data'] ?? responseData;
        debugPrint('Progress update data to parse: $data');
        
        try {
          final progressUpdate = ProgressUpdateModel.fromJson(
            data is Map<String, dynamic> ? data : Map<String, dynamic>.from(data),
          );
          return {
            'success': true,
            'progressUpdate': progressUpdate,
          };
        } catch (parseError, stackTrace) {
          debugPrint('Erreur lors du parsing du ProgressUpdateModel: $parseError');
          debugPrint('Stack trace: $stackTrace');
          debugPrint('Données reçues: $data');
          return {
            'success': false,
            'message': 'Erreur lors du parsing des données: ${parseError.toString()}',
          };
        }
      }
      
      // Gérer les erreurs de validation (422)
      if (response.statusCode == 422) {
        final errorData = response.data;
        debugPrint('❌ Erreur de validation 422: $errorData');
        
        String errorMessage = 'Les données fournies sont invalides.';
        if (errorData is Map) {
          if (errorData.containsKey('message')) {
            errorMessage = errorData['message'] as String;
          }
          if (errorData.containsKey('errors')) {
            final errors = errorData['errors'];
            if (errors is Map && errors.isNotEmpty) {
              // Prendre le premier message d'erreur
              final firstError = errors.values.first;
              if (firstError is List && firstError.isNotEmpty) {
                errorMessage = firstError.first as String;
              } else if (firstError is String) {
                errorMessage = firstError;
              }
            }
          }
        }
        
        return {
          'success': false,
          'message': errorMessage,
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Erreur lors de la mise à jour',
      };
    } catch (e, stackTrace) {
      debugPrint('❌ Erreur lors de la mise à jour: $e');
      debugPrint('Stack trace: $stackTrace');
      
      // Gérer les erreurs DioException
      if (e is DioException) {
        if (e.response != null) {
          final errorData = e.response!.data;
          debugPrint('Erreur response data: $errorData');
          
          if (e.response!.statusCode == 422) {
            String errorMessage = 'Les données fournies sont invalides.';
            if (errorData is Map) {
              if (errorData.containsKey('message')) {
                errorMessage = errorData['message'] as String;
              }
              if (errorData.containsKey('errors')) {
                final errors = errorData['errors'];
                if (errors is Map && errors.isNotEmpty) {
                  final firstError = errors.values.first;
                  if (firstError is List && firstError.isNotEmpty) {
                    errorMessage = firstError.first as String;
                  } else if (firstError is String) {
                    errorMessage = firstError;
                  }
                }
              }
            }
            return {
              'success': false,
              'message': errorMessage,
            };
          }
        }
      }
      
      return {
        'success': false,
        'message': 'Erreur: ${e.toString()}',
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

