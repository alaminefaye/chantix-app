import '../models/notification_model.dart';
import '../services/api_service.dart';

class NotificationRepository {
  final ApiService _apiService = ApiService();

  /// Récupérer toutes les notifications
  Future<List<NotificationModel>> getNotifications({
    bool? unreadOnly,
    int? limit,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (unreadOnly != null) {
        queryParams['unread_only'] = unreadOnly;
      }
      if (limit != null) {
        queryParams['limit'] = limit;
      }

      final response = await _apiService.get(
        '/v1/notifications',
        queryParameters: queryParams,
      );

      print('📬 Notifications API Response: ${response.statusCode}');
      print('📬 Response data: ${response.data}');

      if (response.statusCode == 200) {
        final dynamic responseData = response.data;
        List<dynamic> data;
        
        // Gérer différentes structures de réponse
        if (responseData is Map) {
          data = responseData['data'] ?? responseData['notifications'] ?? [];
        } else if (responseData is List) {
          data = responseData;
        } else {
          print('⚠️ Format de réponse inattendu: ${responseData.runtimeType}');
          return [];
        }
        
        if (data.isEmpty) {
          print('ℹ️ Aucune notification trouvée');
          return [];
        }
        
        return data.map((json) {
          try {
            return NotificationModel.fromJson(json);
          } catch (e) {
            print('❌ Erreur parsing notification: $e');
            print('   JSON: $json');
            rethrow;
          }
        }).toList();
      }
      print('⚠️ Status code non 200: ${response.statusCode}');
      return [];
    } catch (e, stackTrace) {
      print('❌ Erreur lors de la récupération des notifications: $e');
      print('   Stack trace: $stackTrace');
      rethrow; // Propager l'erreur au lieu de la masquer
    }
  }

  /// Récupérer le nombre de notifications non lues
  Future<int> getUnreadCount() async {
    try {
      final response = await _apiService.get('/v1/notifications/unread-count');

      if (response.statusCode == 200) {
        final count = response.data['count'] ?? 0;
        print('📊 Nombre de notifications non lues: $count');
        return count;
      }
      print('⚠️ Erreur unread-count: status ${response.statusCode}');
      return 0;
    } catch (e) {
      print('❌ Erreur unread-count: $e');
      return 0;
    }
  }

  /// Récupérer les dernières notifications
  Future<List<NotificationModel>> getLatestNotifications({int limit = 10}) async {
    try {
      final response = await _apiService.get(
        '/v1/notifications/latest',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final dynamic responseData = response.data['data'] ?? response.data;
        if (responseData is List) {
          return responseData.map((json) => NotificationModel.fromJson(json)).toList();
        }
        return [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Marquer une notification comme lue
  Future<bool> markAsRead(int notificationId) async {
    try {
      final response = await _apiService.post(
        '/v1/notifications/$notificationId/mark-read',
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Marquer toutes les notifications comme lues
  Future<bool> markAllAsRead() async {
    try {
      final response = await _apiService.post('/v1/notifications/mark-all-read');

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Supprimer une notification
  Future<bool> deleteNotification(int notificationId) async {
    try {
      final response = await _apiService.delete('/v1/notifications/$notificationId');

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}

