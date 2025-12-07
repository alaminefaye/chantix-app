import 'package:flutter/foundation.dart';
import '../../data/models/report_model.dart';
import '../../data/repositories/report_repository.dart';

class ReportProvider with ChangeNotifier {
  final ReportRepository _repository = ReportRepository();

  List<ReportModel> _reports = [];
  ReportModel? _selectedReport;
  bool _isLoading = false;
  String? _errorMessage;
  int? _selectedProjectId;

  List<ReportModel> get reports => _reports;
  ReportModel? get selectedReport => _selectedReport;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get selectedProjectId => _selectedProjectId;

  void setSelectedProject(int? projectId) {
    _selectedProjectId = projectId;
    notifyListeners();
  }

  Future<void> loadReports({Map<String, dynamic>? filters}) async {
    if (_selectedProjectId == null) {
      if (kDebugMode) {
        print('Cannot load reports: no project selected');
      }
      return;
    }

    if (kDebugMode) {
      print('Loading reports for project: $_selectedProjectId');
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final reports = await _repository.getReports(
        projectId: _selectedProjectId!,
        filters: filters,
      );

      if (kDebugMode) {
        print('Loaded ${reports.length} reports from API');
        if (reports.isNotEmpty) {
          print(
            'Premier rapport chargé: ID=${reports.first.id}, Type=${reports.first.type}',
          );
        }
      }

      _reports = reports;
      _isLoading = false;
      notifyListeners();

      if (kDebugMode) {
        print('Reports list updated. Total: ${_reports.length}');
        if (_reports.isEmpty) {
          print('⚠️ ATTENTION: La liste est vide après le chargement!');
          print('Vérifiez que:');
          print('  1. Le projet $_selectedProjectId existe');
          print(
            '  2. Il y a des rapports pour ce projet dans la base de données',
          );
          print('  3. L\'utilisateur a les permissions pour voir ces rapports');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading reports: $e');
      }
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadReport(int id) async {
    if (_selectedProjectId == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedReport = await _repository.getReport(id, _selectedProjectId!);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> generateReport({
    required String type,
    required String reportDate,
    String? endDate,
  }) async {
    if (_selectedProjectId == null) {
      if (kDebugMode) {
        print('ERREUR: Aucun projet sélectionné pour générer le rapport');
      }
      return {
        'success': false,
        'message': 'Aucun projet sélectionné. Veuillez sélectionner un projet.',
      };
    }

    if (kDebugMode) {
      print('=== GÉNÉRATION DE RAPPORT ===');
      print('Projet ID: $_selectedProjectId');
      print('Type: $type');
      print('Date: $reportDate');
      print('Date fin: $endDate');
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.generateReport(
        projectId: _selectedProjectId!,
        type: type,
        reportDate: reportDate,
        endDate: endDate,
      );

      if (kDebugMode) {
        print('Résultat de la génération: $result');
      }
      _isLoading = false;

      if (result['success'] == true) {
        if (kDebugMode) {
          print('Rapport généré avec succès, rechargement de la liste...');
        }

        // Si le rapport est dans le résultat, l'ajouter directement à la liste
        if (result.containsKey('report') && result['report'] != null) {
          try {
            final reportData = result['report'];

            if (kDebugMode) {
              print('Rapport reçu dans le résultat: $reportData');
            }

            if (reportData is ReportModel) {
              final newReport = reportData;
              if (kDebugMode) {
                print(
                  'Rapport parsé: ID=${newReport.id}, Type=${newReport.type}, Project ID=${newReport.projectId}',
                );
                print('Projet sélectionné actuellement: $_selectedProjectId');
              }

              // Vérifier que le rapport appartient au projet sélectionné
              if (newReport.projectId != _selectedProjectId) {
                if (kDebugMode) {
                  print(
                    'ATTENTION: Le rapport appartient au projet ${newReport.projectId} mais le projet sélectionné est $_selectedProjectId',
                  );
                }
              }

              // Vérifier si le rapport n'est pas déjà dans la liste
              if (!_reports.any((r) => r.id == newReport.id)) {
                // Vérifier que le rapport appartient au projet sélectionné avant de l'ajouter
                if (newReport.projectId == _selectedProjectId) {
                  _reports.insert(0, newReport);
                  if (kDebugMode) {
                    print(
                      'Rapport ajouté à la liste. Nombre total: ${_reports.length}',
                    );
                  }
                  notifyListeners();
                } else {
                  if (kDebugMode) {
                    print(
                      'Le rapport n\'a pas été ajouté car il appartient à un autre projet',
                    );
                  }
                }
              } else {
                if (kDebugMode) {
                  print(
                    'Le rapport existe déjà dans la liste (ID: ${newReport.id})',
                  );
                }
              }
            } else {
              if (kDebugMode) {
                print(
                  'Le rapport n\'est pas une instance de ReportModel: ${reportData.runtimeType}',
                );
              }
            }
          } catch (e, stackTrace) {
            if (kDebugMode) {
              print('Erreur lors de l\'ajout du rapport à la liste: $e');
              print('Stack trace: $stackTrace');
            }
          }
        } else {
          if (kDebugMode) {
            print(
              'Aucun rapport dans le résultat. Clés disponibles: ${result.keys}',
            );
          }
        }

        // Attendre un peu pour que le serveur termine la création et que la base de données soit à jour
        await Future.delayed(const Duration(milliseconds: 1000));

        // Recharger les rapports pour s'assurer qu'on a la dernière version
        if (kDebugMode) {
          print(
            'Rechargement de la liste des rapports pour le projet: $_selectedProjectId',
          );
        }

        // Vérifier que le projet est toujours sélectionné avant de recharger
        if (_selectedProjectId == null) {
          if (kDebugMode) {
            print(
              'ERREUR: Le projet n\'est plus sélectionné après la génération!',
            );
          }
        } else {
          await loadReports();

          if (kDebugMode) {
            print(
              'Liste des rapports rechargée. Nombre total: ${_reports.length}',
            );
            if (_reports.isNotEmpty) {
              print('=== RAPPORTS TROUVÉS ===');
              for (var report in _reports) {
                print(
                  '  - ID: ${report.id}, Type: ${report.type}, Date: ${report.reportDate}, Project ID: ${report.projectId}',
                );
              }
            } else {
              print('AUCUN RAPPORT TROUVÉ dans la liste après rechargement!');
              print(
                'Vérifiez que le rapport a bien été créé avec le project_id: $_selectedProjectId',
              );
            }
          }
        }

        notifyListeners();
      } else {
        _errorMessage = result['message'];
        notifyListeners();
      }

      return result;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<bool> deleteReport(int id) async {
    if (_selectedProjectId == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final success = await _repository.deleteReport(id, _selectedProjectId!);
      _isLoading = false;

      if (success) {
        _reports.removeWhere((r) => r.id == id);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _isLoading = false;
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
