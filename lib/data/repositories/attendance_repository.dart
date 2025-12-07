import 'dart:io';
import 'package:dio/dio.dart';
import '../models/attendance_model.dart';
import '../services/api_service.dart';

class AttendanceRepository {
  final ApiService _apiService = ApiService();

  Future<List<AttendanceModel>> getAttendances(int projectId) async {
    try {
      final response = await _apiService.get(
        '/v1/projects/$projectId/attendances',
      );

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
    required int
    employeeId, // Gardé pour compatibilité mais non utilisé par l'API
    double? latitude,
    double? longitude,
    String? photoPath,
  }) async {
    try {
      // Créer FormData pour gérer les fichiers
      final formData = FormData.fromMap({
        if (latitude != null) 'check_in_latitude': latitude,
        if (longitude != null) 'check_in_longitude': longitude,
        if (photoPath != null && File(photoPath).existsSync())
          'check_in_photo': await MultipartFile.fromFile(
            photoPath,
            filename: 'check_in_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
      });

      final endpoint = '/v1/projects/$projectId/attendances/check-in';
      print('🔵 DEBUG: Check-in URL: $endpoint');
      print('🔵 DEBUG: Project ID: $projectId');

      final response = await _apiService.postFormData(endpoint, formData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        // L'API retourne { success: true, data: {...} }
        final attendanceData = responseData['data'] ?? responseData;
        return {
          'success': true,
          'attendance': AttendanceModel.fromJson(attendanceData),
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Erreur lors du check-in',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
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
      // Créer FormData pour gérer les fichiers
      final formData = FormData.fromMap({
        if (latitude != null) 'check_out_latitude': latitude,
        if (longitude != null) 'check_out_longitude': longitude,
        if (photoPath != null && File(photoPath).existsSync())
          'check_out_photo': await MultipartFile.fromFile(
            photoPath,
            filename: 'check_out_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
      });

      final response = await _apiService.postFormData(
        '/v1/projects/$projectId/attendances/$attendanceId/check-out',
        formData,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        // L'API retourne { success: true, data: {...} }
        final attendanceData = responseData['data'] ?? responseData;
        return {
          'success': true,
          'attendance': AttendanceModel.fromJson(attendanceData),
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Erreur lors du check-out',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> markAbsence({
    required int projectId,
    required int
    employeeId, // Gardé pour compatibilité mais non utilisé par l'API
    required String reason,
  }) async {
    try {
      final formData = {'absence_reason': reason};

      final response = await _apiService.post(
        '/v1/projects/$projectId/attendances/absence',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        // L'API retourne { success: true, data: {...} }
        final attendanceData = responseData['data'] ?? responseData;
        return {
          'success': true,
          'attendance': AttendanceModel.fromJson(attendanceData),
        };
      }

      return {
        'success': false,
        'message':
            response.data['message'] ??
            'Erreur lors de la déclaration d\'absence',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
