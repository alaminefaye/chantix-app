class ApiConfig {
  // URL de base de l'API Laravel
  static const String baseUrl = 'https://chantix.universaltechnologiesafrica.com/api';
  
  // Timeout pour les requêtes HTTP (en millisecondes)
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  
  // Endpoints
  static const String login = '/v1/login';
  static const String register = '/v1/register';
  static const String logout = '/v1/logout';
  static const String user = '/v1/user';
  static const String forgotPassword = '/v1/forgot-password';
  static const String resetPassword = '/v1/reset-password';
  static const String changePassword = '/v1/change-password';
  static const String deleteAccount = '/v1/delete-account';
  
  // Headers
  static Map<String, String> getHeaders({String? token}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}

