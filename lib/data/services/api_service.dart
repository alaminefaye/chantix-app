import 'package:dio/dio.dart';
import '../../config/api_config.dart';
import 'storage_service.dart';

class ApiService {
  late Dio _dio;
  String? _token;

  ApiService() {
    final token = StorageService.getToken();
    _token = token;

    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: Duration(milliseconds: ApiConfig.connectTimeout),
        receiveTimeout: Duration(milliseconds: ApiConfig.receiveTimeout),
        headers: ApiConfig.getHeaders(token: token),
      ),
    );

    // Intercepteur pour ajouter le token automatiquement
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Toujours récupérer le token depuis StorageService pour s'assurer qu'il est à jour
          final token = StorageService.getToken() ?? _token;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            _token = token; // Mettre à jour le token local aussi
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          // Gestion des erreurs
          return handler.next(error);
        },
      ),
    );
  }

  void setToken(String? token) {
    _token = token;
  }

  // Authentification
  Future<Response> login(String email, String password) async {
    return await _dio.post(
      ApiConfig.login,
      data: {'email': email, 'password': password},
    );
  }

  Future<Response> register(Map<String, dynamic> data) async {
    return await _dio.post(ApiConfig.register, data: data);
  }

  Future<Response> logout() async {
    return await _dio.post(ApiConfig.logout);
  }

  Future<Response> getUser() async {
    return await _dio.get(ApiConfig.user);
  }

  Future<Response> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    return await _dio.post(
      ApiConfig.changePassword,
      data: {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPassword,
      },
    );
  }

  Future<Response> deleteAccount() async {
    return await _dio.delete(ApiConfig.deleteAccount);
  }

  // Méthode générique pour les requêtes GET
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.get(endpoint, queryParameters: queryParameters);
  }

  // Méthode générique pour les requêtes POST
  Future<Response> post(String endpoint, {Map<String, dynamic>? data}) async {
    return await _dio.post(endpoint, data: data);
  }

  // Méthode générique pour les requêtes PUT
  Future<Response> put(String endpoint, {Map<String, dynamic>? data}) async {
    return await _dio.put(endpoint, data: data);
  }

  // Méthode générique pour les requêtes DELETE
  Future<Response> delete(String endpoint, {Map<String, dynamic>? data}) async {
    if (data != null) {
      return await _dio.delete(endpoint, data: data);
    }
    return await _dio.delete(endpoint);
  }

  // Méthode pour les requêtes POST avec FormData (upload de fichiers)
  Future<Response> postFormData(String endpoint, FormData formData) async {
    final fullUrl = '${ApiConfig.baseUrl}$endpoint';
    print('🔵 DEBUG: Full URL: $fullUrl');
    print('🔵 DEBUG: Base URL: ${ApiConfig.baseUrl}');
    print('🔵 DEBUG: Endpoint: $endpoint');

    try {
      final response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );
      print('🟢 DEBUG: Response status: ${response.statusCode}');
      return response;
    } catch (e) {
      print('🔴 DEBUG: Error in postFormData: $e');
      if (e is DioException) {
        print('🔴 DEBUG: DioException details:');
        print('  - Type: ${e.type}');
        print('  - Message: ${e.message}');
        print(
          '  - Response: ${e.response?.statusCode} - ${e.response?.statusMessage}',
        );
        print('  - Request path: ${e.requestOptions.path}');
        print('  - Request baseUrl: ${e.requestOptions.baseUrl}');
      }
      rethrow;
    }
  }

  // Méthode pour les requêtes PUT avec FormData (upload de fichiers)
  Future<Response> putFormData(String endpoint, FormData formData) async {
    return await _dio.put(
      endpoint,
      data: formData,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
    );
  }

  // Getter pour accéder à Dio si nécessaire
  Dio get dio => _dio;
}
