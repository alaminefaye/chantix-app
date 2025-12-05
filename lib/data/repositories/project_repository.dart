import 'package:flutter/foundation.dart';
import '../models/project_model.dart';
import '../services/api_service.dart';

class ProjectRepository {
  final ApiService _apiService = ApiService();

  Future<List<ProjectModel>> getProjects({Map<String, dynamic>? filters}) async {
    try {
      debugPrint('Loading projects from API...');
      final response = await _apiService.get('/v1/projects', queryParameters: filters);
      
      debugPrint('Projects API response status: ${response.statusCode}');
      debugPrint('Projects API response data: ${response.data}');
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        
        // Vérifier si la réponse a une structure avec 'success' et 'data'
        if (responseData is Map && responseData.containsKey('success')) {
          if (responseData['success'] == true && responseData.containsKey('data')) {
            final List<dynamic> data = responseData['data'] is List 
                ? responseData['data'] 
                : [];
            debugPrint('Found ${data.length} projects in response');
            return data.map((json) => ProjectModel.fromJson(json)).toList();
          } else {
            // Si success est false, il y a une erreur
            final errorMsg = responseData['message'] ?? 'Erreur lors du chargement des projets';
            debugPrint('API returned success=false: $errorMsg');
            throw Exception(errorMsg);
          }
        }
        
        // Si la réponse est directement une liste
        if (responseData is List) {
          debugPrint('Response is directly a list with ${responseData.length} items');
          return responseData.map((json) => ProjectModel.fromJson(json)).toList();
        }
        
        // Si la réponse a une clé 'data' directement
        if (responseData is Map && responseData.containsKey('data')) {
          final List<dynamic> data = responseData['data'] is List 
              ? responseData['data'] 
              : [];
          debugPrint('Found ${data.length} projects in data key');
          return data.map((json) => ProjectModel.fromJson(json)).toList();
        }
        
        debugPrint('Unexpected response format: $responseData');
        return [];
      } else {
        final errorMessage = response.data is Map && response.data.containsKey('message')
            ? response.data['message']
            : 'Erreur lors du chargement des projets (status: ${response.statusCode})';
        debugPrint('API error: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e, stackTrace) {
      debugPrint('Exception in getProjects: $e');
      debugPrint('Stack trace: $stackTrace');
      // Propager l'erreur au lieu de retourner une liste vide
      rethrow;
    }
  }

  Future<ProjectModel?> getProject(int id) async {
    try {
      final response = await _apiService.get('/v1/projects/$id');
      
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return ProjectModel.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> createProject(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post('/v1/projects', data: data);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final projectData = response.data['data'] ?? response.data;
        return {
          'success': true,
          'project': ProjectModel.fromJson(projectData),
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Erreur lors de la création du projet',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> updateProject(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put('/v1/projects/$id', data: data);
      
      if (response.statusCode == 200) {
        final projectData = response.data['data'] ?? response.data;
        return {
          'success': true,
          'project': ProjectModel.fromJson(projectData),
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Erreur lors de la mise à jour',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<bool> deleteProject(int id) async {
    try {
      final response = await _apiService.delete('/v1/projects/$id');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}

