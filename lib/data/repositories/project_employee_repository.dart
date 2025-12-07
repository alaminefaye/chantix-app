import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/project_employee_model.dart';
import '../services/api_service.dart';

class ProjectEmployeeRepository {
  final ApiService _apiService = ApiService();

  Future<List<ProjectEmployeeModel>> getProjectEmployees(int projectId) async {
    try {
      final response = await _apiService.get('/v1/projects/$projectId/employees');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => ProjectEmployeeModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> assignEmployeeToProject({
    required int projectId,
    required int employeeId,
    String? assignedDate,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{
        'employee_id': employeeId,
      };
      if (assignedDate != null && assignedDate.isNotEmpty) {
        data['assigned_date'] = assignedDate;
      }
      if (notes != null && notes.isNotEmpty) {
        data['notes'] = notes;
      }

      debugPrint('=== ASSIGN EMPLOYEE TO PROJECT ===');
      debugPrint('Project ID: $projectId');
      debugPrint('Employee ID: $employeeId');
      debugPrint('Assigned Date: $assignedDate');
      debugPrint('Notes: $notes');
      debugPrint('Data to send: $data');

      final response = await _apiService.post(
        '/v1/projects/$projectId/employees',
        data: data,
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': ProjectEmployeeModel.fromJson(response.data['data'] ?? response.data),
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Erreur lors de l\'affectation',
      };
    } on DioException catch (e) {
      debugPrint('=== DIO EXCEPTION ===');
      debugPrint('Type: ${e.type}');
      debugPrint('Message: ${e.message}');
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response data: ${e.response?.data}');
      
      String errorMessage = 'Erreur lors de l\'affectation de l\'employé';
      
      if (e.response != null) {
        final responseData = e.response!.data;
        debugPrint('Response data type: ${responseData.runtimeType}');
        
        if (responseData is Map<String, dynamic>) {
          // Gérer les erreurs de validation (422)
          if (responseData.containsKey('errors')) {
            final errors = responseData['errors'] as Map<String, dynamic>;
            debugPrint('Validation errors: $errors');
            final errorList = <String>[];
            errors.forEach((key, value) {
              if (value is List) {
                errorList.addAll(value.map((e) => e.toString()));
              } else {
                errorList.add(value.toString());
              }
            });
            errorMessage = errorList.join('\n');
          } else if (responseData.containsKey('message')) {
            errorMessage = responseData['message'].toString();
          }
        }
      } else {
        errorMessage = e.message ?? 'Erreur de connexion';
      }
      
      debugPrint('Final error message: $errorMessage');
      
      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e, stackTrace) {
      debugPrint('=== UNEXPECTED ERROR ===');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<bool> removeEmployeeFromProject(int projectId, int employeeId) async {
    try {
      final response = await _apiService.delete(
        '/v1/projects/$projectId/employees/$employeeId',
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}

