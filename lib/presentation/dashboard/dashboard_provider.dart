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

  int get totalProjects => _dashboardData?['total_projects'] ?? 0;
  int get activeProjects => _dashboardData?['active_projects'] ?? 0;
  int get completedProjects => _dashboardData?['completed_projects'] ?? 0;
  int get blockedProjects => _dashboardData?['blocked_projects'] ?? 0;
  double get totalBudget => (_dashboardData?['total_budget'] ?? 0).toDouble();
  double get averageProgress => (_dashboardData?['average_progress'] ?? 0).toDouble();

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
}

