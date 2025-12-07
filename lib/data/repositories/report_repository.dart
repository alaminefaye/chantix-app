import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/report_model.dart';
import '../services/api_service.dart';

class ReportRepository {
  final ApiService _apiService = ApiService();

  Future<List<ReportModel>> getReports({
    required int projectId,
    Map<String, dynamic>? filters,
  }) async {
    try {
      if (kDebugMode) {
        print('Fetching reports for project: $projectId');
      }

      final response = await _apiService.get(
        '/v1/projects/$projectId/reports',
        queryParameters: filters,
      );

      if (kDebugMode) {
        print('Reports response status: ${response.statusCode}');
        print('Reports response data: ${response.data}');
      }

      if (response.statusCode == 200) {
        final responseData = response.data;
        List<dynamic> data;

        if (responseData is Map && responseData.containsKey('data')) {
          data = responseData['data'] as List<dynamic>;
        } else if (responseData is List) {
          data = responseData;
        } else {
          if (kDebugMode) {
            print('Unexpected response format: $responseData');
          }
          return [];
        }

        if (kDebugMode) {
          print('Found ${data.length} reports');
        }

        final reports = <ReportModel>[];
        for (var json in data) {
          try {
            // Convertir en Map<String, dynamic> si nécessaire
            Map<String, dynamic> reportMap;
            if (json is Map<String, dynamic>) {
              reportMap = json;
            } else if (json is Map) {
              reportMap = Map<String, dynamic>.from(json);
            } else {
              if (kDebugMode) {
                print(
                  'Skipping invalid report data: $json (type: ${json.runtimeType})',
                );
              }
              continue;
            }

            // Normaliser les dates (Laravel peut retourner des objets Date)
            if (reportMap.containsKey('report_date')) {
              final reportDate = reportMap['report_date'];
              if (reportDate is! String) {
                // Si c'est un objet Date, le convertir en string
                reportMap['report_date'] = reportDate.toString().split(' ')[0];
              }
            }

            if (reportMap.containsKey('end_date') &&
                reportMap['end_date'] != null) {
              final endDate = reportMap['end_date'];
              if (endDate is! String) {
                reportMap['end_date'] = endDate.toString().split(' ')[0];
              }
            }

            // Normaliser le champ data (array en PHP, doit être Map en Dart)
            if (reportMap.containsKey('data') && reportMap['data'] != null) {
              final dataValue = reportMap['data'];
              if (dataValue is List) {
                // Convertir la liste en Map si nécessaire
                reportMap['data'] =
                    null; // Ou un Map vide si vous voulez garder les données
              } else if (dataValue is Map) {
                reportMap['data'] = Map<String, dynamic>.from(dataValue);
              }
            }

            // Normaliser created_at et updated_at
            if (reportMap.containsKey('created_at') &&
                reportMap['created_at'] != null) {
              final createdAt = reportMap['created_at'];
              if (createdAt is! String) {
                reportMap['created_at'] = createdAt.toString();
              }
            }

            if (reportMap.containsKey('updated_at') &&
                reportMap['updated_at'] != null) {
              final updatedAt = reportMap['updated_at'];
              if (updatedAt is! String) {
                reportMap['updated_at'] = updatedAt.toString();
              }
            }

            if (kDebugMode) {
              print(
                'Parsing report: ID=${reportMap['id']}, Type=${reportMap['type']}',
              );
            }

            final report = ReportModel.fromJson(reportMap);
            reports.add(report);
          } catch (e, stackTrace) {
            if (kDebugMode) {
              print('Error parsing report: $e');
              print('Report data: $json');
              print('Stack trace: $stackTrace');
            }
            // Continue avec les autres rapports au lieu de tout arrêter
          }
        }

        if (kDebugMode) {
          print('Successfully parsed ${reports.length} reports');
        }

        return reports;
      }

      if (kDebugMode) {
        print('Failed to fetch reports: status ${response.statusCode}');
      }

      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching reports: $e');
      }
      return [];
    }
  }

  Future<ReportModel?> getReport(int id, int projectId) async {
    try {
      final response = await _apiService.get(
        '/v1/projects/$projectId/reports/$id',
      );

      if (response.statusCode == 200) {
        return ReportModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> generateReport({
    required int projectId,
    required String type,
    required String reportDate,
    String? endDate,
  }) async {
    try {
      if (kDebugMode) {
        print(
          'Generating report: projectId=$projectId, type=$type, date=$reportDate, endDate=$endDate',
        );
      }

      final response = await _apiService.post(
        '/v1/projects/$projectId/reports/generate',
        data: {
          'type': type,
          'report_date': reportDate,
          if (endDate != null) 'end_date': endDate,
        },
      );

      if (kDebugMode) {
        print('Report generation response: status=${response.statusCode}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;

        if (kDebugMode) {
          print('Report generation response data: $responseData');
        }

        // Le serveur retourne soit directement le rapport, soit dans une clé 'report'
        final reportData = responseData['report'] ?? responseData;

        if (kDebugMode) {
          print('Report data to parse: $reportData');
        }

        try {
          // Convertir en Map<String, dynamic> si nécessaire
          Map<String, dynamic> reportMap;
          if (reportData is Map<String, dynamic>) {
            reportMap = reportData;
          } else if (reportData is Map) {
            reportMap = Map<String, dynamic>.from(reportData);
          } else {
            reportMap = {'id': 0};
          }

          final report = ReportModel.fromJson(reportMap);

          if (kDebugMode) {
            print('Report generated successfully');
          }

          // Extraire file_url de manière sécurisée
          String? fileUrl;
          if (responseData is Map && responseData.containsKey('file_url')) {
            fileUrl = responseData['file_url'] as String?;
          }
          if (fileUrl == null && reportMap.containsKey('file_path')) {
            fileUrl = reportMap['file_path'] as String?;
          }

          return {'success': true, 'report': report, 'file_url': fileUrl ?? ''};
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing report model: $e');
          }

          // Même si le parsing échoue, on retourne le succès avec les données brutes
          // Convertir reportData en Map<String, dynamic> pour l'extraction
          Map<String, dynamic> safeReportData;
          if (reportData is Map<String, dynamic>) {
            safeReportData = reportData;
          } else if (reportData is Map) {
            safeReportData = Map<String, dynamic>.from(reportData);
          } else {
            safeReportData = {};
          }

          String? fileUrl;
          if (responseData is Map && responseData.containsKey('file_url')) {
            fileUrl = responseData['file_url'] as String?;
          }
          if (fileUrl == null && safeReportData.containsKey('file_path')) {
            fileUrl = safeReportData['file_path'] as String?;
          }

          return {
            'success': true,
            'report': null,
            'file_url': fileUrl ?? '',
            'raw_data': safeReportData,
          };
        }
      }

      // Extraire le message d'erreur
      String errorMessage = 'Erreur lors de la génération du rapport';
      final responseData = response.data;

      if (responseData is Map) {
        if (responseData.containsKey('message')) {
          errorMessage = responseData['message'] as String;
        } else if (responseData.containsKey('errors')) {
          final errors = responseData['errors'];
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

      if (kDebugMode) {
        print('Report generation failed: $errorMessage');
        print('Response data: $responseData');
      }

      return {'success': false, 'message': errorMessage};
    } catch (e) {
      final errorMessage = _handleError(e);

      if (kDebugMode) {
        print('Report generation error: $errorMessage');
        print('Exception: $e');
      }

      return {'success': false, 'message': errorMessage};
    }
  }

  Future<bool> deleteReport(int id, int projectId) async {
    try {
      final response = await _apiService.delete(
        '/v1/projects/$projectId/reports/$id',
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
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
              // Extraire tous les messages d'erreur
              final errorMessages = <String>[];
              errors.forEach((key, value) {
                if (value is List) {
                  errorMessages.addAll(value.map((e) => e.toString()));
                } else if (value is String) {
                  errorMessages.add(value);
                }
              });

              if (errorMessages.isNotEmpty) {
                return errorMessages.join('. ');
              }

              final firstError = errors.values.first;
              if (firstError is List && firstError.isNotEmpty) {
                return firstError.first as String;
              } else if (firstError is String) {
                return firstError;
              }
            }
          }
        }

        // Gérer les erreurs 500 spécifiquement
        if (error.response!.statusCode == 500) {
          return 'Erreur serveur. Veuillez réessayer plus tard ou contacter le support technique.';
        }
      }

      return error.message ?? 'Erreur lors de la génération du rapport';
    }

    if (error.toString().contains('SocketException') ||
        error.toString().contains('Failed host lookup')) {
      return 'Impossible de se connecter au serveur. Vérifiez votre connexion internet.';
    }

    return 'Erreur lors de la génération du rapport';
  }
}
