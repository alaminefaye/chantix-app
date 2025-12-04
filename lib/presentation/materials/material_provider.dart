import 'package:flutter/foundation.dart';
import '../../data/models/material_model.dart';
import '../../data/repositories/material_repository.dart';

class MaterialProvider with ChangeNotifier {
  final MaterialRepository _repository = MaterialRepository();

  List<MaterialModel> _materials = [];
  MaterialModel? _selectedMaterial;
  bool _isLoading = false;
  String? _errorMessage;

  List<MaterialModel> get materials => _materials;
  MaterialModel? get selectedMaterial => _selectedMaterial;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadMaterials({Map<String, dynamic>? filters}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _materials = await _repository.getMaterials(filters: filters);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMaterial(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedMaterial = await _repository.getMaterial(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createMaterial(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.createMaterial(data);
      _isLoading = false;

      if (result['success'] == true) {
        await loadMaterials();
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

  Future<bool> updateMaterial(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.updateMaterial(id, data);
      _isLoading = false;

      if (result['success'] == true) {
        await loadMaterials();
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

  Future<bool> deleteMaterial(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _repository.deleteMaterial(id);
      _isLoading = false;

      if (success) {
        _materials.removeWhere((m) => m.id == id);
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

