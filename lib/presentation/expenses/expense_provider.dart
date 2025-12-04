import 'package:flutter/foundation.dart';
import '../../data/models/expense_model.dart';
import '../../data/repositories/expense_repository.dart';
import 'dart:io';

class ExpenseProvider with ChangeNotifier {
  final ExpenseRepository _repository = ExpenseRepository();

  List<ExpenseModel> _expenses = [];
  ExpenseModel? _selectedExpense;
  bool _isLoading = false;
  String? _errorMessage;
  int? _selectedProjectId;

  List<ExpenseModel> get expenses => _expenses;
  ExpenseModel? get selectedExpense => _selectedExpense;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get selectedProjectId => _selectedProjectId;

  void setSelectedProject(int? projectId) {
    _selectedProjectId = projectId;
    notifyListeners();
  }

  Future<void> loadExpenses({Map<String, dynamic>? filters}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _expenses = await _repository.getExpenses(
        projectId: _selectedProjectId,
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

  Future<void> loadExpense(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedExpense = await _repository.getExpense(
        id,
        projectId: _selectedProjectId,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createExpense({
    required int projectId,
    required Map<String, dynamic> data,
    File? invoiceFile,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.createExpense(
        projectId: projectId,
        data: data,
        invoiceFile: invoiceFile,
      );
      _isLoading = false;

      if (result['success'] == true) {
        await loadExpenses();
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

  Future<bool> updateExpense({
    required int id,
    required int projectId,
    required Map<String, dynamic> data,
    File? invoiceFile,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.updateExpense(
        id: id,
        projectId: projectId,
        data: data,
        invoiceFile: invoiceFile,
      );
      _isLoading = false;

      if (result['success'] == true) {
        await loadExpenses();
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

  Future<bool> deleteExpense(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _repository.deleteExpense(
        id,
        projectId: _selectedProjectId,
      );
      _isLoading = false;

      if (success) {
        _expenses.removeWhere((e) => e.id == id);
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

