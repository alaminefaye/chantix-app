import '../models/attendance_model.dart';
import '../services/api_service.dart';

class AttendanceRepository {
  final ApiService _apiService = ApiService();

  Future<List<AttendanceModel>> getAttendances(int projectId) async {
    try {
      final response = await _apiService.get('/v1/projects/$projectId/attendances');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => AttendanceModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> checkIn({
    required int projectId,
    required int employeeId,
    double? latitude,
    double? longitude,
    String? photoPath,
  }) async {
    try {
      final formData = {
        'employee_id': employeeId,
        if (latitude != null) 'check_in_latitude': latitude,
        if (longitude != null) 'check_in_longitude': longitude,
      };

      final response = await _apiService.post(
        '/v1/projects/$projectId/attendances/check-in',
        data: formData,
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'attendance': AttendanceModel.fromJson(response.data),
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Erreur lors du check-in',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> checkOut({
    required int attendanceId,
    required int projectId,
    double? latitude,
    double? longitude,
    String? photoPath,
  }) async {
    try {
      final formData = {
        if (latitude != null) 'check_out_latitude': latitude,
        if (longitude != null) 'check_out_longitude': longitude,
      };

      final response = await _apiService.post(
        '/v1/projects/$projectId/attendances/$attendanceId/check-out',
        data: formData,
      );
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'attendance': AttendanceModel.fromJson(response.data),
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Erreur lors du check-out',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> markAbsence({
    required int projectId,
    required int employeeId,
    required String reason,
  }) async {
    try {
      final formData = {
        'employee_id': employeeId,
        'absence_reason': reason,
      };

      final response = await _apiService.post(
        '/v1/projects/$projectId/attendances/absence',
        data: formData,
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'attendance': AttendanceModel.fromJson(response.data),
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Erreur lors de la déclaration d\'absence',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}

