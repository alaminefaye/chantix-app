import '../models/employee_model.dart';
import '../services/api_service.dart';

class EmployeeRepository {
  final ApiService _apiService = ApiService();

  Future<List<EmployeeModel>> getEmployees({Map<String, dynamic>? filters}) async {
    try {
      final response = await _apiService.get('/v1/employees', queryParameters: filters);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => EmployeeModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
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

