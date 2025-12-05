import 'package:flutter/foundation.dart';
import '../../data/repositories/dashboard_repository.dart';

class DashboardProvider with ChangeNotifier {
  final DashboardRepository _repository = DashboardRepository();

  Map<String, dynamic>? _dashboardData;
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalProjects => _toInt(_dashboardData?['total_projects']) ?? 0;
  int get activeProjects => _toInt(_dashboardData?['active_projects']) ?? 0;
  int get completedProjects => _toInt(_dashboardData?['completed_projects']) ?? 0;
  int get blockedProjects => _toInt(_dashboardData?['blocked_projects']) ?? 0;
  double get totalBudget => _toDouble(_dashboardData?['total_budget']) ?? 0.0;
  double get averageProgress => _toDouble(_dashboardData?['average_progress']) ?? 0.0;

  Future<void> loadDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getDashboardData();
      _isLoading = false;

      if (result['success'] == true) {
        _dashboardData = result['data'];
        notifyListeners();
      } else {
        _errorMessage = result['message'];
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed;
    }
    return null;
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) {
      // Nettoyer la chaîne (enlever les espaces, etc.)
      final cleaned = value.trim().replaceAll(' ', '');
      final parsed = double.tryParse(cleaned);
      return parsed;
    }
    return null;
  }
}

