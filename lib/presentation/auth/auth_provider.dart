import 'package:flutter/foundation.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  final ApiService _apiService = ApiService();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await StorageService.init();
    final token = StorageService.getToken();
    if (token != null && token.isNotEmpty) {
      _apiService.setToken(token);
      await loadUser();
    }
  }

  Future<void> loadUser() async {
    try {
      _user = await _authRepository.getCurrentUser();
      notifyListeners();
    } catch (e) {
      _user = null;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authRepository.login(email, password);
      
      if (result['success'] == true) {
        _user = result['user'] as UserModel?;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] as String?;
        _isLoading = false;
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

  Future<bool> register(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authRepository.register(data);
      
      if (result['success'] == true) {
        _user = result['user'] as UserModel?;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] as String?;
        _isLoading = false;
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

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authRepository.logout();
    _user = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

