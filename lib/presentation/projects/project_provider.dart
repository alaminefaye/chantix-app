import 'package:flutter/foundation.dart';
import '../../data/models/project_model.dart';
import '../../data/repositories/project_repository.dart';

class ProjectProvider with ChangeNotifier {
  final ProjectRepository _repository = ProjectRepository();

  List<ProjectModel> _projects = [];
  ProjectModel? _selectedProject;
  bool _isLoading = false;
  String? _errorMessage;

  List<ProjectModel> get projects => _projects;
  ProjectModel? get selectedProject => _selectedProject;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadProjects({Map<String, dynamic>? filters}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _projects = await _repository.getProjects(filters: filters);
      debugPrint('Projects loaded: ${_projects.length} projects');
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading projects: $e');
      _errorMessage = e.toString();
      _projects = []; // S'assurer que la liste est vide en cas d'erreur
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProject(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedProject = await _repository.getProject(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createProject(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.createProject(data);
      _isLoading = false;

      if (result['success'] == true) {
        await loadProjects();
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

  Future<bool> updateProject(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.updateProject(id, data);
      _isLoading = false;

      if (result['success'] == true) {
        await loadProjects();
        await loadProject(id);
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

  Future<bool> deleteProject(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _repository.deleteProject(id);
      _isLoading = false;

      if (success) {
        _projects.removeWhere((p) => p.id == id);
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

