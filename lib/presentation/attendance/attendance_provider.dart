import 'package:flutter/foundation.dart';
import '../../data/models/attendance_model.dart';
import '../../data/repositories/attendance_repository.dart';

class AttendanceProvider with ChangeNotifier {
  final AttendanceRepository _repository = AttendanceRepository();

  List<AttendanceModel> _attendances = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AttendanceModel> get attendances => _attendances;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadAttendances(int projectId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _attendances = await _repository.getAttendances(projectId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkIn({
    required int projectId,
    required int employeeId,
    double? latitude,
    double? longitude,
    String? photoPath,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.checkIn(
        projectId: projectId,
        employeeId: employeeId,
        latitude: latitude,
        longitude: longitude,
        photoPath: photoPath,
      );
      _isLoading = false;

      if (result['success'] == true) {
        await loadAttendances(projectId);
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> checkOut({
    required int attendanceId,
    required int projectId,
    double? latitude,
    double? longitude,
    String? photoPath,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.checkOut(
        attendanceId: attendanceId,
        projectId: projectId,
        latitude: latitude,
        longitude: longitude,
        photoPath: photoPath,
      );
      _isLoading = false;

      if (result['success'] == true) {
        await loadAttendances(projectId);
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> markAbsence({
    required int projectId,
    required int employeeId,
    required String reason,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.markAbsence(
        projectId: projectId,
        employeeId: employeeId,
        reason: reason,
      );
      _isLoading = false;

      if (result['success'] == true) {
        await loadAttendances(projectId);
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

