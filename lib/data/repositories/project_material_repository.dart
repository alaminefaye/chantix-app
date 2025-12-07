import '../models/project_material_model.dart';
import '../services/api_service.dart';

class ProjectMaterialRepository {
  final ApiService _apiService = ApiService();

  Future<List<ProjectMaterialModel>> getProjectMaterials(int projectId) async {
    try {
      final response = await _apiService.get('/v1/projects/$projectId/materials');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => ProjectMaterialModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> addMaterialToProject({
    required int projectId,
    required int materialId,
    required double quantityPlanned,
    String? notes,
  }) async {
    try {
      final response = await _apiService.post(
        '/v1/projects/$projectId/materials',
        data: {
          'material_id': materialId,
          'quantity_planned': quantityPlanned,
          'notes': notes,
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': ProjectMaterialModel.fromJson(response.data['data'] ?? response.data),
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Erreur lors de l\'ajout du matériau',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> updateProjectMaterial({
    required int projectId,
    required int materialId,
    double? quantityOrdered,
    double? quantityDelivered,
    double? quantityUsed,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (quantityOrdered != null) data['quantity_ordered'] = quantityOrdered;
      if (quantityDelivered != null) data['quantity_delivered'] = quantityDelivered;
      if (quantityUsed != null) data['quantity_used'] = quantityUsed;
      if (notes != null) data['notes'] = notes;

      final response = await _apiService.put(
        '/v1/projects/$projectId/materials/$materialId',
        data: data,
      );
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': ProjectMaterialModel.fromJson(response.data['data'] ?? response.data),
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

  Future<bool> removeMaterialFromProject(int projectId, int materialId) async {
    try {
      final response = await _apiService.delete(
        '/v1/projects/$projectId/materials/$materialId',
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}

