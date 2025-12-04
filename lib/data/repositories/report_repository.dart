import '../models/report_model.dart';
import '../services/api_service.dart';

class ReportRepository {
  final ApiService _apiService = ApiService();

  Future<List<ReportModel>> getReports({
    required int projectId,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final response = await _apiService.get(
        '/v1/projects/$projectId/reports',
        queryParameters: filters,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => ReportModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<ReportModel?> getReport(int id, int projectId) async {
    try {
      final response = await _apiService.get(
        '/v1/projects/$projectId/reports/$id',
      );
      
      if (response.statusCode == 200) {
        return ReportModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> generateReport({
    required int projectId,
    required String type,
    required String reportDate,
    String? endDate,
  }) async {
    try {
      final response = await _apiService.post(
        '/v1/projects/$projectId/reports/generate',
        data: {
          'type': type,
          'report_date': reportDate,
          if (endDate != null) 'end_date': endDate,
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'report': ReportModel.fromJson(response.data),
          'file_url': response.data['file_url'] ?? response.data['file_path'],
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Erreur lors de la génération du rapport',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<bool> deleteReport(int id, int projectId) async {
    try {
      final response = await _apiService.delete(
        '/v1/projects/$projectId/reports/$id',
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}

