import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../../core/constants/app_constants.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiService.login(email, password);
      
      // Debug: afficher la réponse
      debugPrint('Login response status: ${response.statusCode}');
      debugPrint('Login response data: ${response.data}');
      
      if (response.statusCode == 200) {
        final data = response.data;
        final token = data['token'] ?? data['access_token'];
        final userData = data['user'] ?? data;

        if (token != null) {
          // Sauvegarder le token
          await StorageService.saveToken(token);
          _apiService.setToken(token);

          // Sauvegarder les données utilisateur
          await StorageService.saveUserData(jsonEncode(userData));

          return {
            'success': true,
            'user': UserModel.fromJson(userData),
            'token': token,
          };
        } else {
          // Pas de token dans la réponse
          return {
            'success': false,
            'message': 'Réponse invalide du serveur. Veuillez réessayer.',
          };
        }
      }

      // Gérer les erreurs HTTP (codes autres que 200)
      final errorData = response.data;
      String errorMessage = AppConstants.loginError;
      
      debugPrint('Login error - Status: ${response.statusCode}, Data: $errorData');
      
      if (errorData is Map) {
        if (errorData.containsKey('message')) {
          errorMessage = errorData['message'] as String;
        } else if (errorData.containsKey('errors')) {
          final errors = errorData['errors'];
          if (errors is Map && errors.isNotEmpty) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              errorMessage = firstError.first as String;
            } else if (firstError is String) {
              errorMessage = firstError;
            }
          }
        }
      } else if (errorData is String) {
        errorMessage = errorData;
      }
      
      // Messages spécifiques selon le code de statut
      if (response.statusCode == 401) {
        errorMessage = 'Les identifiants fournis sont incorrects.';
      } else if (response.statusCode == 403) {
        errorMessage = 'Votre compte n\'a pas encore été validé par l\'administrateur.';
      } else if (response.statusCode == 422) {
        errorMessage = errorMessage; // Garder le message de validation
      }
      
      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      return {
        'success': false,
        'message': _handleError(e),
      };
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.register(data);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        final token = responseData['token'] ?? responseData['access_token'];
        final userData = responseData['user'] ?? responseData;
        
        // Si pas de token, c'est normal pour un utilisateur non vérifié
        // Le backend ne retourne pas de token si l'utilisateur n'est pas vérifié
        if (token == null) {
          // Ne pas sauvegarder de token ni de données utilisateur
          // L'utilisateur devra attendre la validation avant de pouvoir se connecter
          return {
            'success': true,
            'user': UserModel.fromJson(userData),
            'message': responseData['message'] ?? 'Votre compte est en attente de validation.',
          };
        }

        // Si token présent, l'utilisateur est vérifié - sauvegarder et connecter
        await StorageService.saveToken(token);
        _apiService.setToken(token);
        await StorageService.saveUserData(jsonEncode(userData));

        return {
          'success': true,
          'user': UserModel.fromJson(userData),
          'token': token,
        };
      }

      // Gérer les erreurs de validation
      if (response.statusCode == 422) {
        final errorData = response.data;
        if (errorData is Map && errorData.containsKey('errors')) {
          final errors = errorData['errors'] as Map;
          if (errors.isNotEmpty) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              return {
                'success': false,
                'message': firstError.first as String,
              };
            }
          }
        }
      }
      
      final errorData = response.data;
      return {
        'success': false,
        'message': (errorData is Map && errorData.containsKey('message'))
            ? errorData['message'] as String
            : AppConstants.registerError,
      };
    } catch (e) {
      return {
        'success': false,
        'message': _handleError(e),
      };
    }
  }

  Future<bool> logout() async {
    try {
      await _apiService.logout();
      await StorageService.clearAll();
      _apiService.setToken(null);
      return true;
    } catch (e) {
      // Même en cas d'erreur, on nettoie le stockage local
      await StorageService.clearAll();
      _apiService.setToken(null);
      return true;
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final userDataString = StorageService.getUserData();
      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        return UserModel.fromJson(userData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  bool isLoggedIn() {
    final token = StorageService.getToken();
    return token != null && token.isNotEmpty;
  }

  Future<Map<String, dynamic>> changePassword(String currentPassword, String newPassword) async {
    try {
      final response = await _apiService.changePassword(currentPassword, newPassword);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Mot de passe modifié avec succès.',
        };
      }

      final errorData = response.data;
      String errorMessage = 'Erreur lors de la modification du mot de passe.';
      
      if (errorData is Map) {
        if (errorData.containsKey('message')) {
          errorMessage = errorData['message'] as String;
        } else if (errorData.containsKey('errors')) {
          final errors = errorData['errors'];
          if (errors is Map && errors.isNotEmpty) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              errorMessage = firstError.first as String;
            } else if (firstError is String) {
              errorMessage = firstError;
            }
          }
        }
      }

      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      return {
        'success': false,
        'message': _handleError(e),
      };
    }
  }

  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final response = await _apiService.deleteAccount();
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        await StorageService.clearAll();
        _apiService.setToken(null);
        return {
          'success': true,
          'message': 'Compte supprimé avec succès.',
        };
      }

      final errorData = response.data;
      String errorMessage = 'Erreur lors de la suppression du compte.';
      
      if (errorData is Map && errorData.containsKey('message')) {
        errorMessage = errorData['message'] as String;
      }

      return {
        'success': false,
        'message': errorMessage,
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
      // Gérer les erreurs de timeout
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return 'Délai d\'attente dépassé. Vérifiez votre connexion internet.';
      }
      
      // Gérer les erreurs de connexion
      if (error.type == DioExceptionType.connectionError) {
        return 'Impossible de se connecter au serveur. Vérifiez votre connexion internet.';
      }
      
      // Extraire le message d'erreur de la réponse HTTP
      if (error.response != null) {
        final data = error.response!.data;
        
        // Gérer les réponses JSON
        if (data is Map) {
          if (data.containsKey('message')) {
            final message = data['message'];
            if (message is String) {
              return message;
            }
          }
          
          if (data.containsKey('errors')) {
            final errors = data['errors'];
            if (errors is Map && errors.isNotEmpty) {
              final firstError = errors.values.first;
              if (firstError is List && firstError.isNotEmpty) {
                return firstError.first as String;
              } else if (firstError is String) {
                return firstError;
              }
            }
          }
        }
        
        // Gérer les codes de statut HTTP spécifiques
        final statusCode = error.response!.statusCode;
        if (statusCode == 401) {
          return 'Les identifiants fournis sont incorrects.';
        } else if (statusCode == 403) {
          return 'Votre compte n\'a pas encore été validé par l\'administrateur.';
        } else if (statusCode == 404) {
          return 'Service non trouvé. Veuillez contacter le support.';
        } else if (statusCode == 500) {
          return 'Erreur du serveur. Veuillez réessayer plus tard.';
        } else if (statusCode != null) {
          return 'Erreur HTTP $statusCode. Veuillez réessayer.';
        }
      }
      
      // Message d'erreur par défaut de Dio
      if (error.message != null && error.message!.isNotEmpty) {
        return error.message!;
      }
    }
    
    // Gérer les erreurs réseau
    if (error.toString().contains('SocketException') ||
        error.toString().contains('Failed host lookup') ||
        error.toString().contains('Network is unreachable')) {
      return 'Erreur de connexion réseau. Vérifiez votre connexion internet.';
    }
    
    // Erreur inconnue avec plus de détails pour le débogage
    return 'Une erreur inconnue s\'est produite: ${error.toString()}';
  }
}

