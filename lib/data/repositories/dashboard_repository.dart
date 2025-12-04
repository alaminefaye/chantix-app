import 'package:dio/dio.dart';
import '../services/api_service.dart';

class DashboardRepository {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final response = await _apiService.get('/v1/dashboard');
      
      if (response.statusCode == 200) {
        final data = response.data;
        // Si la réponse contient déjà 'data', on l'utilise directement
        // Sinon, on utilise toute la réponse comme données
        final dashboardData = (data is Map && data.containsKey('data')) 
            ? data['data'] 
            : data;
        
        return {
          'success': true,
          'data': dashboardData,
        };
      }
      
      final errorData = response.data;
      return {
        'success': false,
        'message': (errorData is Map && errorData.containsKey('message'))
            ? errorData['message'] as String
            : 'Erreur lors du chargement des données',
      };
    } catch (e) {
      return {
        'success': false,
        'message': _handleError(e),
      };
    }
  }

  String _handleError(dynamic error) {
    // Gérer les erreurs Dio
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return 'Délai d\'attente dépassé. Vérifiez votre connexion internet.';
      }
      
      if (error.type == DioExceptionType.connectionError) {
        return 'Impossible de se connecter au serveur. Vérifiez votre connexion internet.';
      }
      
      // Extraire le message d'erreur de la réponse
      if (error.response != null) {
        final data = error.response!.data;
        if (data is Map && data.containsKey('message')) {
          return data['message'] as String;
        }
        if (data is Map && data.containsKey('errors')) {
          final errors = data['errors'] as Map;
          if (errors.isNotEmpty) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              return firstError.first as String;
            }
          }
        }
      }
      
      return error.message ?? 'Erreur lors du chargement des données';
    }
    
    if (error.toString().contains('SocketException') ||
        error.toString().contains('Failed host lookup')) {
      return 'Impossible de se connecter au serveur. Vérifiez votre connexion internet.';
    }
    
    return 'Erreur lors du chargement des données';
  }
}

