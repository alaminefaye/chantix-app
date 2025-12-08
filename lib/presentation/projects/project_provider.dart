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
      final projects = await _repository.getProjects(filters: filters);
      debugPrint('Projects loaded: ${projects.length} projects');

      // Vérifier chaque projet parsé
      for (var i = 0; i < projects.length; i++) {
        final project = projects[i];
        debugPrint(
          'Project $i: id=${project.id}, name=${project.name}, status=${project.status}',
        );
      }

      _projects = projects;
      _isLoading = false;
      _errorMessage = null;
      debugPrint(
        'Provider: Notifying listeners with ${_projects.length} projects',
      );
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('Error loading projects: $e');
      debugPrint('Stack trace: $stackTrace');
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

  /// Vider le cache et forcer le rechargement
  void clearCache() {
    _projects = [];
    _selectedProject = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Recharger les projets en vidant d'abord le cache
  Future<void> reloadProjects({Map<String, dynamic>? filters}) async {
    clearCache();
    await loadProjects(filters: filters);
  }
}
