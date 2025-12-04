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
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
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
      data: {
        'email': email,
        'password': password,
      },
    );
  }

  Future<Response> register(Map<String, dynamic> data) async {
    return await _dio.post(
      ApiConfig.register,
      data: data,
    );
  }

  Future<Response> logout() async {
    return await _dio.post(ApiConfig.logout);
  }

  Future<Response> getUser() async {
    return await _dio.get(ApiConfig.user);
  }

  // Méthode générique pour les requêtes GET
  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
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
  Future<Response> delete(String endpoint) async {
    return await _dio.delete(endpoint);
  }

  // Méthode pour les requêtes POST avec FormData (upload de fichiers)
  Future<Response> postFormData(String endpoint, FormData formData) async {
    return await _dio.post(
      endpoint,
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      ),
    );
  }

  // Getter pour accéder à Dio si nécessaire
  Dio get dio => _dio;
}

