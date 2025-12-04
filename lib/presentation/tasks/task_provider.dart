import 'package:flutter/foundation.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';

class TaskProvider with ChangeNotifier {
  final TaskRepository _repository = TaskRepository();

  List<TaskModel> _tasks = [];
  TaskModel? _selectedTask;
  bool _isLoading = false;
  String? _errorMessage;
  int? _selectedProjectId;

  List<TaskModel> get tasks => _tasks;
  TaskModel? get selectedTask => _selectedTask;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get selectedProjectId => _selectedProjectId;

  void setSelectedProject(int? projectId) {
    _selectedProjectId = projectId;
    notifyListeners();
  }

  Future<void> loadTasks({Map<String, dynamic>? filters}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasks = await _repository.getTasks(
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

  Future<void> loadTask(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedTask = await _repository.getTask(
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

  Future<bool> createTask({
    required int projectId,
    required Map<String, dynamic> data,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.createTask(
        projectId: projectId,
        data: data,
      );
      _isLoading = false;

      if (result['success'] == true) {
        await loadTasks();
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

  Future<bool> updateTask({
    required int id,
    required int projectId,
    required Map<String, dynamic> data,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.updateTask(
        id: id,
        projectId: projectId,
        data: data,
      );
      _isLoading = false;

      if (result['success'] == true) {
        await loadTasks();
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

  Future<bool> deleteTask(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _repository.deleteTask(
        id,
        projectId: _selectedProjectId,
      );
      _isLoading = false;

      if (success) {
        _tasks.removeWhere((t) => t.id == id);
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
