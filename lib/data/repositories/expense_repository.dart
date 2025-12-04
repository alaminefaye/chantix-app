import '../models/expense_model.dart';
import '../services/api_service.dart';
import 'dart:io';
import 'package:dio/dio.dart';

class ExpenseRepository {
  final ApiService _apiService = ApiService();

  Future<List<ExpenseModel>> getExpenses({
    int? projectId,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (projectId != null) {
        queryParams['project_id'] = projectId;
      }
      if (filters != null) {
        queryParams.addAll(filters);
      }

      final endpoint = projectId != null
          ? '/v1/projects/$projectId/expenses'
          : '/v1/expenses';

      final response = await _apiService.get(endpoint, queryParameters: queryParams);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => ExpenseModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<ExpenseModel?> getExpense(int id, {int? projectId}) async {
    try {
      final endpoint = projectId != null
          ? '/v1/projects/$projectId/expenses/$id'
          : '/v1/expenses/$id';

      final response = await _apiService.get(endpoint);
      
      if (response.statusCode == 200) {
        return ExpenseModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> createExpense({
    required int projectId,
    required Map<String, dynamic> data,
    File? invoiceFile,
  }) async {
    try {
      if (invoiceFile != null) {
        // Utiliser FormData pour l'upload de fichier
        final formData = FormData.fromMap(data);
        formData.files.add(
          MapEntry(
            'invoice_file',
            await MultipartFile.fromFile(
              invoiceFile.path,
              filename: invoiceFile.path.split('/').last,
            ),
          ),
        );

        final response = await _apiService.postFormData(
          '/v1/projects/$projectId/expenses',
          formData,
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          return {
            'success': true,
            'expense': ExpenseModel.fromJson(response.data),
          };
        }
      } else {
        final response = await _apiService.post(
          '/v1/projects/$projectId/expenses',
          data: data,
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          return {
            'success': true,
            'expense': ExpenseModel.fromJson(response.data),
          };
        }
      }

      return {
        'success': false,
        'message': 'Erreur lors de la création de la dépense',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> updateExpense({
    required int id,
    required int projectId,
    required Map<String, dynamic> data,
    File? invoiceFile,
  }) async {
    try {
      if (invoiceFile != null) {
        final formData = FormData.fromMap(data);
        formData.files.add(
          MapEntry(
            'invoice_file',
            await MultipartFile.fromFile(
              invoiceFile.path,
              filename: invoiceFile.path.split('/').last,
            ),
          ),
        );

        final response = await _apiService.postFormData(
          '/v1/projects/$projectId/expenses/$id',
          formData,
        );

        if (response.statusCode == 200) {
          return {
            'success': true,
            'expense': ExpenseModel.fromJson(response.data),
          };
        }
      } else {
        final response = await _apiService.put(
          '/v1/projects/$projectId/expenses/$id',
          data: data,
        );

        if (response.statusCode == 200) {
          return {
            'success': true,
            'expense': ExpenseModel.fromJson(response.data),
          };
        }
      }

      return {
        'success': false,
        'message': 'Erreur lors de la mise à jour de la dépense',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<bool> deleteExpense(int id, {int? projectId}) async {
    try {
      final endpoint = projectId != null
          ? '/v1/projects/$projectId/expenses/$id'
          : '/v1/expenses/$id';

      final response = await _apiService.delete(endpoint);
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}

