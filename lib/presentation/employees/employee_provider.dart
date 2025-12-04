import 'package:flutter/foundation.dart';
import '../../data/models/employee_model.dart';
import '../../data/repositories/employee_repository.dart';

class EmployeeProvider with ChangeNotifier {
  final EmployeeRepository _repository = EmployeeRepository();

  List<EmployeeModel> _employees = [];
  EmployeeModel? _selectedEmployee;
  bool _isLoading = false;
  String? _errorMessage;

  List<EmployeeModel> get employees => _employees;
  EmployeeModel? get selectedEmployee => _selectedEmployee;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadEmployees({Map<String, dynamic>? filters}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _employees = await _repository.getEmployees(filters: filters);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadEmployee(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedEmployee = await _repository.getEmployee(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createEmployee(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.createEmployee(data);
      _isLoading = false;

      if (result['success'] == true) {
        await loadEmployees();
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

  Future<bool> updateEmployee(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.updateEmployee(id, data);
      _isLoading = false;

      if (result['success'] == true) {
        await loadEmployees();
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

  Future<bool> deleteEmployee(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _repository.deleteEmployee(id);
      _isLoading = false;

      if (success) {
        _employees.removeWhere((e) => e.id == id);
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

