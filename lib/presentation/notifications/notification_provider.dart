import 'package:flutter/foundation.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationRepository _repository = NotificationRepository();

  List<NotificationModel> _notifications = [];
  List<NotificationModel> _unreadNotifications = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _unreadCount = 0;

  List<NotificationModel> get notifications => _notifications;
  List<NotificationModel> get unreadNotifications => _unreadNotifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _unreadCount;
  bool get hasUnread => _unreadCount > 0;

  /// Charger toutes les notifications
  Future<void> loadNotifications({bool unreadOnly = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('📬 Chargement des notifications...');
      final notifications = await _repository.getNotifications(
        unreadOnly: unreadOnly,
      );

      print('✅ ${notifications.length} notifications chargées');
      _notifications = notifications;
      _unreadNotifications = notifications.where((n) => !n.isRead).toList();
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e, stackTrace) {
      print('❌ Erreur lors du chargement des notifications: $e');
      print('   Stack trace: $stackTrace');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charger le nombre de notifications non lues
  Future<void> loadUnreadCount() async {
    try {
      final count = await _repository.getUnreadCount();
      _unreadCount = count;
      notifyListeners();
    } catch (e) {
      // Ignorer les erreurs silencieusement
    }
  }

  /// Charger les dernières notifications
  Future<void> loadLatestNotifications({int limit = 10}) async {
    try {
      final notifications = await _repository.getLatestNotifications(limit: limit);
      _unreadNotifications = notifications;
      _unreadCount = notifications.length;
      notifyListeners();
    } catch (e) {
      // Ignorer les erreurs silencieusement
    }
  }

  /// Marquer une notification comme lue
  Future<bool> markAsRead(int notificationId) async {
    try {
      final success = await _repository.markAsRead(notificationId);
      if (success) {
        // Mettre à jour localement
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          final oldNotification = _notifications[index];
          _notifications[index] = NotificationModel(
            id: oldNotification.id,
            userId: oldNotification.userId,
            projectId: oldNotification.projectId,
            type: oldNotification.type,
            title: oldNotification.title,
            message: oldNotification.message,
            link: oldNotification.link,
            isRead: true,
            readAt: DateTime.now(),
            data: oldNotification.data,
            createdAt: oldNotification.createdAt,
            updatedAt: DateTime.now(),
          );
        }

        // Retirer des notifications non lues
        _unreadNotifications.removeWhere((n) => n.id == notificationId);
        _unreadCount = _unreadNotifications.length;
        notifyListeners();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  /// Marquer toutes les notifications comme lues
  Future<bool> markAllAsRead() async {
    try {
      final success = await _repository.markAllAsRead();
      if (success) {
        // Mettre à jour localement
        _notifications = _notifications.map((n) {
          if (!n.isRead) {
            return NotificationModel(
              id: n.id,
              userId: n.userId,
              projectId: n.projectId,
              type: n.type,
              title: n.title,
              message: n.message,
              link: n.link,
              isRead: true,
              readAt: DateTime.now(),
              data: n.data,
              createdAt: n.createdAt,
              updatedAt: DateTime.now(),
            );
          }
          return n;
        }).toList();

        _unreadNotifications.clear();
        _unreadCount = 0;
        notifyListeners();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  /// Supprimer une notification
  Future<bool> deleteNotification(int notificationId) async {
    try {
      final success = await _repository.deleteNotification(notificationId);
      if (success) {
        _notifications.removeWhere((n) => n.id == notificationId);
        _unreadNotifications.removeWhere((n) => n.id == notificationId);
        _unreadCount = _unreadNotifications.length;
        notifyListeners();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  /// Rafraîchir les notifications
  Future<void> refresh() async {
    await loadNotifications();
    await loadUnreadCount();
  }
}

