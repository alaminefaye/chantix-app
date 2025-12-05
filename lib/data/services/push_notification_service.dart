import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'api_service.dart';
import 'storage_service.dart';

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final ApiService _apiService = ApiService();

  String? _fcmToken;
  bool _initialized = false;

  // Handler pour les notifications en arrière-plan
  static Future<void> backgroundMessageHandler(RemoteMessage message) async {
    print('Handling background message: ${message.messageId}');
    // Vous pouvez traiter la notification en arrière-plan ici
  }

  /// Initialiser le service de notifications push
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Demander la permission pour les notifications
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted notification permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('User granted provisional notification permission');
      } else {
        print('User declined or has not accepted notification permission');
        return;
      }

      // Initialiser les notifications locales
      await _initializeLocalNotifications();

      // Sur iOS, il faut d'abord obtenir le token APNS
      if (Platform.isIOS) {
        print('📱 iOS détecté - Configuration du token APNS...');
        print('💡 Vérifiez que "Push Notifications" est activé dans Xcode (Signing & Capabilities)');
        
        // Essayer d'obtenir le token APNS avec plusieurs tentatives
        String? apnsToken;
        for (int i = 0; i < 10; i++) {
          try {
            apnsToken = await _firebaseMessaging.getAPNSToken();
            if (apnsToken != null) {
              print('✅ Token APNS obtenu après ${i * 2} secondes: ${apnsToken.substring(0, 50)}...');
              break;
            }
          } catch (e) {
            // Ignorer les erreurs et continuer
          }
          
          if (i < 9) {
            await Future.delayed(const Duration(seconds: 2));
          }
        }
        
        if (apnsToken != null) {
          await _getFcmTokenAfterApns();
        } else {
          print('⚠️ Token APNS non disponible après 20 secondes');
          print('💡 Le token sera réessayé après la connexion');
          print('💡 Assurez-vous que "Push Notifications" est activé dans Xcode');
        }
      } else {
        // Sur Android, obtenir directement le token FCM
        await _getFcmTokenAfterApns();
      }

      // Écouter les changements de token
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        print('FCM Token refreshed: $newToken');
        _fcmToken = newToken;
        _registerToken(newToken);
      });

      // Configurer les handlers pour les notifications
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Vérifier si l'app a été ouverte depuis une notification
      RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

      _initialized = true;
    } catch (e) {
      print('Error initializing push notifications: $e');
    }
  }

  /// Initialiser les notifications locales
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Créer un canal de notification pour Android
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'chantix_notifications',
        'Chantix Notifications',
        description: 'Notifications pour les mises à jour de stockage et autres événements',
        importance: Importance.high,
        playSound: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  /// Enregistrer le token FCM sur le serveur
  Future<void> _registerToken(String fcmToken) async {
    try {
      print('🔄 Tentative d\'enregistrement du token FCM...');
      print('   Token FCM: ${fcmToken.substring(0, 50)}...');
      
      final authToken = StorageService.getToken();
      if (authToken == null) {
        print('❌ No auth token found, skipping FCM token registration');
        print('💡 Le token FCM sera enregistré automatiquement après la connexion');
        return;
      }

      print('✅ Auth token trouvé: ${authToken.substring(0, 20)}...');

      final deviceInfo = await _getDeviceInfo();
      print('📱 Device info: ${deviceInfo['device_type']} - ${deviceInfo['device_name']}');
      
      print('📤 Envoi de la requête à /v1/fcm-tokens...');
      final response = await _apiService.post('/v1/fcm-tokens', data: {
        'token': fcmToken,
        'device_id': deviceInfo['device_id'],
        'device_type': deviceInfo['device_type'],
        'device_name': deviceInfo['device_name'],
      });

      print('📥 Réponse reçue: Status ${response.statusCode}');
      print('   Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ FCM token registered successfully');
      } else {
        print('⚠️ FCM token registration failed: ${response.statusCode}');
        print('   Response: ${response.data}');
      }
    } catch (e, stackTrace) {
      print('❌ Error registering FCM token: $e');
      print('   Stack trace: $stackTrace');
    }
  }

  /// Réessayer l'enregistrement du token FCM (utile après connexion)
  Future<void> retryTokenRegistration() async {
    print('🔄 retryTokenRegistration() appelé');
    
    if (_fcmToken != null) {
      print('✅ FCM token disponible: ${_fcmToken!.substring(0, 50)}...');
      print('🔄 Retrying FCM token registration...');
      await _registerToken(_fcmToken!);
    } else {
      print('⚠️ No FCM token available to register');
      print('💡 Tentative de récupération du token FCM...');
      
      // Sur iOS, s'assurer que le token APNS est disponible
      if (Platform.isIOS) {
        try {
          String? apnsToken = await _firebaseMessaging.getAPNSToken();
          if (apnsToken == null) {
            print('⏳ Attente du token APNS...');
            await Future.delayed(const Duration(seconds: 2));
            apnsToken = await _firebaseMessaging.getAPNSToken();
          }
          
          if (apnsToken != null) {
            print('✅ Token APNS disponible: ${apnsToken.substring(0, 50)}...');
          } else {
            print('⚠️ Token APNS toujours non disponible');
          }
        } catch (e) {
          print('⚠️ Erreur APNS: $e');
        }
      }
      
      // Essayer de récupérer le token FCM
      try {
        // Attendre un peu pour iOS
        if (Platform.isIOS) {
          await Future.delayed(const Duration(seconds: 1));
        }
        
        _fcmToken = await _firebaseMessaging.getToken();
        if (_fcmToken != null) {
          print('✅ Token FCM récupéré: ${_fcmToken!.substring(0, 50)}...');
          await _registerToken(_fcmToken!);
        } else {
          print('❌ Impossible de récupérer le token FCM');
          print('💡 Le token sera réessayé automatiquement lors du rafraîchissement');
        }
      } catch (e) {
        print('❌ Erreur lors de la récupération du token: $e');
        if (Platform.isIOS && e.toString().contains('apns-token-not-set')) {
          print('💡 Sur iOS, le token APNS peut prendre du temps. Réessayez dans quelques secondes.');
        }
      }
    }
  }

  /// Obtenir le token FCM après que le token APNS soit disponible (iOS)
  Future<void> _getFcmTokenAfterApns() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      if (_fcmToken != null) {
        print('✅ FCM Token obtenu: ${_fcmToken!.substring(0, 50)}...');
        await _registerToken(_fcmToken!);
      } else {
        print('⚠️ Token FCM non disponible');
      }
    } catch (e) {
      print('❌ Erreur lors de la récupération du token FCM: $e');
      if (Platform.isIOS && e.toString().contains('apns-token-not-set')) {
        print('💡 Le token APNS n\'est toujours pas disponible');
        print('💡 Vérifiez la configuration dans Xcode (Signing & Capabilities > Push Notifications)');
      }
    }
  }

  /// Obtenir les informations du dispositif
  Future<Map<String, String>> _getDeviceInfo() async {
    return {
      'device_id': Platform.isAndroid ? 'android_device' : 'ios_device',
      'device_type': Platform.isAndroid ? 'android' : 'ios',
      'device_name': '${Platform.operatingSystem} Device',
    };
  }

  /// Gérer les notifications en premier plan
  void _handleForegroundMessage(RemoteMessage message) {
    print('Received foreground message: ${message.messageId}');
    
    final notification = message.notification;
    final data = message.data;

    if (notification != null) {
      _showLocalNotification(
        id: message.hashCode,
        title: notification.title ?? 'Notification',
        body: notification.body ?? '',
        payload: data.toString(),
      );
    }
  }

  /// Gérer le tap sur une notification
  void _handleNotificationTap(RemoteMessage message) {
    print('Notification tapped: ${message.messageId}');
    final data = message.data;
    
    // Vous pouvez naviguer vers une page spécifique basée sur le type de notification
    if (data['type'] != null) {
      switch (data['type']) {
        case 'material_created':
        case 'material_updated':
        case 'material_stock_increased':
        case 'material_stock_decreased':
        case 'material_low_stock':
        case 'material_deleted':
          // Naviguer vers la page des matériaux
          // Vous pouvez utiliser un GlobalKey pour Navigator ou un système de routage
          break;
        default:
          break;
      }
    }
  }

  /// Gérer le tap sur une notification locale
  void _onNotificationTapped(NotificationResponse response) {
    print('Local notification tapped: ${response.payload}');
    // Traiter le tap sur la notification locale
  }

  /// Afficher une notification locale
  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'chantix_notifications',
      'Chantix Notifications',
      channelDescription: 'Notifications pour les mises à jour de stockage et autres événements',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Obtenir le token FCM actuel
  String? get fcmToken => _fcmToken;

  /// Vérifier si le service est initialisé
  bool get isInitialized => _initialized;

  /// Supprimer le token FCM
  Future<void> deleteToken() async {
    try {
      if (_fcmToken != null) {
        await _apiService.delete('/v1/fcm-tokens', data: {
          'token': _fcmToken,
        });
      }
      await _firebaseMessaging.deleteToken();
      _fcmToken = null;
      print('FCM token deleted successfully');
    } catch (e) {
      print('Error deleting FCM token: $e');
    }
  }
}

