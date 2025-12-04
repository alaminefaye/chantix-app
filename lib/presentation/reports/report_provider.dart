import 'package:flutter/foundation.dart';
import '../../data/models/report_model.dart';
import '../../data/repositories/report_repository.dart';

class ReportProvider with ChangeNotifier {
  final ReportRepository _repository = ReportRepository();

  List<ReportModel> _reports = [];
  ReportModel? _selectedReport;
  bool _isLoading = false;
  String? _errorMessage;
  int? _selectedProjectId;

  List<ReportModel> get reports => _reports;
  ReportModel? get selectedReport => _selectedReport;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get selectedProjectId => _selectedProjectId;

  void setSelectedProject(int? projectId) {
    _selectedProjectId = projectId;
    notifyListeners();
  }

  Future<void> loadReports({Map<String, dynamic>? filters}) async {
    if (_selectedProjectId == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _reports = await _repository.getReports(
        projectId: _selectedProjectId!,
        filters: filters,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadReport(int id) async {
    if (_selectedProjectId == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedReport = await _repository.getReport(id, _selectedProjectId!);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> generateReport({
    required String type,
    required String reportDate,
    String? endDate,
  }) async {
    if (_selectedProjectId == null) {
      return {
        'success': false,
        'message': 'Aucun projet sélectionné',
      };
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.generateReport(
        projectId: _selectedProjectId!,
        type: type,
        reportDate: reportDate,
        endDate: endDate,
      );
      _isLoading = false;

      if (result['success'] == true) {
        await loadReports();
        notifyListeners();
      } else {
        _errorMessage = result['message'];
        notifyListeners();
      }

      return result;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<bool> deleteReport(int id) async {
    if (_selectedProjectId == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final success = await _repository.deleteReport(id, _selectedProjectId!);
      _isLoading = false;

      if (success) {
        _reports.removeWhere((r) => r.id == id);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _isLoading = false;
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

