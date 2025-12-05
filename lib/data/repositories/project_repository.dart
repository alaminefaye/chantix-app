import '../models/project_model.dart';
import '../services/api_service.dart';

class ProjectRepository {
  final ApiService _apiService = ApiService();

  Future<List<ProjectModel>> getProjects({Map<String, dynamic>? filters}) async {
    try {
      final response = await _apiService.get('/v1/projects', queryParameters: filters);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => ProjectModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
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

