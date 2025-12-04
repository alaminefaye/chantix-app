import '../models/material_model.dart';
import '../services/api_service.dart';

class MaterialRepository {
  final ApiService _apiService = ApiService();

  Future<List<MaterialModel>> getMaterials({Map<String, dynamic>? filters}) async {
    try {
      final response = await _apiService.get('/v1/materials', queryParameters: filters);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => MaterialModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<MaterialModel?> getMaterial(int id) async {
    try {
      final response = await _apiService.get('/v1/materials/$id');
      
      if (response.statusCode == 200) {
        return MaterialModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> createMaterial(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post('/v1/materials', data: data);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'material': MaterialModel.fromJson(response.data),
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Erreur lors de la création du matériau',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> updateMaterial(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put('/v1/materials/$id', data: data);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'material': MaterialModel.fromJson(response.data),
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Erreur lors de la mise à jour du matériau',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<bool> deleteMaterial(int id) async {
    try {
      final response = await _apiService.delete('/v1/materials/$id');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}

