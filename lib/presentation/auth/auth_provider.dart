import 'package:flutter/foundation.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/api_service.dart';
import '../../data/services/push_notification_service.dart';

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
  bool get isVerified => _user?.isVerified ?? false;

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
        
        // Vérifier que le token est bien sauvegardé
        final token = StorageService.getToken();
        print('🔑 Token d\'authentification sauvegardé: ${token?.substring(0, 20)}...');
        
        // Attendre un peu pour que le token FCM soit généré (surtout sur iOS)
        // Sur iOS, le token APNS peut prendre 3-5 secondes
        await Future.delayed(const Duration(seconds: 3));
        
        // Enregistrer le token FCM après la connexion
        print('📱 Tentative d\'enregistrement du token FCM après connexion...');
        await PushNotificationService().retryTokenRegistration();
        
        // Réessayer après 5 secondes supplémentaires si nécessaire (pour iOS)
        Future.delayed(const Duration(seconds: 5), () async {
          print('🔄 Réessai automatique de l\'enregistrement du token FCM...');
          await PushNotificationService().retryTokenRegistration();
        });
        
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

  Future<Map<String, dynamic>> changePassword(String currentPassword, String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authRepository.changePassword(currentPassword, newPassword);
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> deleteAccount() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authRepository.deleteAccount();
      if (result['success'] == true) {
        _user = null;
      }
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

