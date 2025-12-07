import '../models/task_model.dart';
import '../services/api_service.dart';

class TaskRepository {
  final ApiService _apiService = ApiService();

  Future<List<TaskModel>> getTasks({
    int? projectId,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (filters != null) {
        queryParams.addAll(filters);
      }

      final endpoint = projectId != null
          ? '/v1/projects/$projectId/tasks'
          : '/v1/tasks';

      final response = await _apiService.get(
        endpoint,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => TaskModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<TaskModel?> getTask(int id, {int? projectId}) async {
    try {
      final endpoint = projectId != null
          ? '/v1/projects/$projectId/tasks/$id'
          : '/v1/tasks/$id';

      final response = await _apiService.get(endpoint);

      if (response.statusCode == 200) {
        return TaskModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> createTask({
    required int projectId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _apiService.post(
        '/v1/projects/$projectId/tasks',
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Handle different response structures
        final taskData =
            response.data is Map && response.data.containsKey('data')
            ? response.data['data']
            : response.data;

        return {'success': true, 'task': TaskModel.fromJson(taskData)};
      }

      return {
        'success': false,
        'message':
            response.data['message'] ??
            'Erreur lors de la création de la tâche',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateTask({
    required int id,
    required int projectId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _apiService.put(
        '/v1/projects/$projectId/tasks/$id',
        data: data,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'task': TaskModel.fromJson(response.data)};
      }

      return {
        'success': false,
        'message':
            response.data['message'] ??
            'Erreur lors de la mise à jour de la tâche',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<bool> deleteTask(int id, {int? projectId}) async {
    try {
      final endpoint = projectId != null
          ? '/v1/projects/$projectId/tasks/$id'
          : '/v1/tasks/$id';

      final response = await _apiService.delete(endpoint);
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}
