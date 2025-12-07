import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/employee_model.dart';
import '../services/api_service.dart';

class EmployeeRepository {
  final ApiService _apiService = ApiService();

  Future<List<EmployeeModel>> getEmployees({Map<String, dynamic>? filters}) async {
    try {
      final response = await _apiService.get('/v1/employees', queryParameters: filters);
      
      debugPrint('=== RÉPONSE API EMPLOYÉS ===');
      debugPrint('Status code: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');
      debugPrint('Response data type: ${response.data.runtimeType}');
      
      if (response.statusCode == 200) {
        // Vérifier la structure de la réponse
        dynamic responseData = response.data;
        
        // Si c'est une Map avec 'success' et 'data'
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('success') && responseData['success'] == true) {
            final data = responseData['data'];
            if (data is List) {
              debugPrint('Données trouvées dans response.data[\'data\']: ${data.length} employés');
              return data.map((json) {
                try {
                  return EmployeeModel.fromJson(json);
                } catch (e) {
                  debugPrint('Erreur lors du parsing d\'un employé: $e');
                  debugPrint('JSON: $json');
                  rethrow;
                }
              }).toList();
            } else if (data != null) {
              debugPrint('response.data[\'data\'] n\'est pas une liste: $data');
            }
          } else {
            debugPrint('Response success = false ou absent');
            debugPrint('Message: ${responseData['message']}');
          }
        }
        
        // Si c'est directement une liste
        if (responseData is List) {
          debugPrint('Données trouvées directement comme liste: ${responseData.length} employés');
          return responseData.map((json) {
            try {
              return EmployeeModel.fromJson(json);
            } catch (e) {
              debugPrint('Erreur lors du parsing d\'un employé: $e');
              debugPrint('JSON: $json');
              rethrow;
            }
          }).toList();
        }
        
        debugPrint('Format de réponse non reconnu');
        return [];
      }
      
      debugPrint('Status code non 200: ${response.statusCode}');
      if (response.data is Map) {
        debugPrint('Message d\'erreur: ${response.data['message']}');
      }
      return [];
    } on DioException catch (e) {
      debugPrint('=== ERREUR DIO ===');
      debugPrint('Type: ${e.type}');
      debugPrint('Message: ${e.message}');
      debugPrint('Response: ${e.response?.data}');
      debugPrint('Status code: ${e.response?.statusCode}');
      if (e.response?.statusCode == 400) {
        debugPrint('Erreur 400: L\'utilisateur n\'a peut-être pas de company_id défini');
      }
      return [];
    } catch (e, stackTrace) {
      debugPrint('Erreur lors de la récupération des employés: $e');
      debugPrint('Stack trace: $stackTrace');
      return [];
    }
  }

  Future<EmployeeModel?> getEmployee(int id) async {
    try {
      final response = await _apiService.get('/v1/employees/$id');
      
      if (response.statusCode == 200) {
        return EmployeeModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> createEmployee(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post('/v1/employees', data: data);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'employee': EmployeeModel.fromJson(response.data),
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Erreur lors de la création de l\'employé',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> updateEmployee(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put('/v1/employees/$id', data: data);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'employee': EmployeeModel.fromJson(response.data),
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Erreur lors de la mise à jour de l\'employé',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<bool> deleteEmployee(int id) async {
    try {
      final response = await _apiService.delete('/v1/employees/$id');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}

