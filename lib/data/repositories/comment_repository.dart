import '../models/comment_model.dart';
import '../services/api_service.dart';
import 'dart:io';
import 'package:dio/dio.dart';

class CommentRepository {
  final ApiService _apiService = ApiService();

  Future<List<CommentModel>> getComments({
    required int projectId,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final response = await _apiService.get(
        '/v1/projects/$projectId/comments',
        queryParameters: filters,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        final comments = data.map((json) => CommentModel.fromJson(json)).toList();
        // Debug: vérifier que les réponses sont bien parsées
        for (var comment in comments) {
          if (comment.replies != null && comment.replies!.isNotEmpty) {
            print('Comment ${comment.id} has ${comment.replies!.length} replies');
            for (var reply in comment.replies!) {
              print('  - Reply ${reply.id} by ${reply.user?.name ?? "Unknown"}');
            }
          }
        }
        return comments;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<CommentModel?> getComment(int id, int projectId) async {
    try {
      final response = await _apiService.get(
        '/v1/projects/$projectId/comments/$id',
      );
      
      if (response.statusCode == 200) {
        return CommentModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> createComment({
    required int projectId,
    required String content,
    int? parentId,
    List<File>? attachments,
  }) async {
    try {
      if (attachments != null && attachments.isNotEmpty) {
        // Utiliser FormData pour l'upload de fichiers
        final formData = FormData.fromMap({
          'content': content,
          if (parentId != null) 'parent_id': parentId,
        });

        // Ajouter les pièces jointes
        for (var file in attachments) {
          formData.files.add(
            MapEntry(
              'attachments[]',
              await MultipartFile.fromFile(
                file.path,
                filename: file.path.split('/').last,
              ),
            ),
          );
        }

        final response = await _apiService.postFormData(
          '/v1/projects/$projectId/comments',
          formData,
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          return {
            'success': true,
            'comment': CommentModel.fromJson(response.data),
          };
        }
      } else {
        final response = await _apiService.post(
          '/v1/projects/$projectId/comments',
          data: {
            'content': content,
            if (parentId != null) 'parent_id': parentId,
          },
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          return {
            'success': true,
            'comment': CommentModel.fromJson(response.data),
          };
        }
      }

      return {
        'success': false,
        'message': 'Erreur lors de la création du commentaire',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<bool> deleteComment(int id, int projectId) async {
    try {
      final response = await _apiService.delete(
        '/v1/projects/$projectId/comments/$id',
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}

