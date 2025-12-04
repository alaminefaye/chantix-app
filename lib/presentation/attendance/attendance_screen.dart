import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/project_model.dart';
import '../../data/models/attendance_model.dart';
import '../projects/project_provider.dart';
import 'attendance_provider.dart';
import '../auth/auth_provider.dart';
import 'check_in_screen.dart';
import 'check_out_screen.dart';
import 'attendance_history_screen.dart';
import 'absence_screen.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  ProjectModel? _selectedProject;
  AttendanceModel? _currentAttendance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProjects();
    });
  }

  Future<void> _loadProjects() async {
    final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
    if (projectProvider.projects.isEmpty) {
      await projectProvider.loadProjects();
    }
  }

  Future<void> _loadCurrentAttendance() async {
    if (_selectedProject == null) return;

    final attendanceProvider =
        Provider.of<AttendanceProvider>(context, listen: false);
    await attendanceProvider.loadAttendances(_selectedProject!.id);

    // Trouver le pointage actuel (check-in sans check-out)
    final attendances = attendanceProvider.attendances;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id;

    if (userId != null) {
      try {
        _currentAttendance = attendances.firstWhere(
          (att) =>
              att.employeeId == userId &&
              att.checkInTime != null &&
              att.checkOutTime == null &&
              !att.isAbsence,
        );
      } catch (e) {
        _currentAttendance = null;
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pointage'),
        actions: [
          if (_selectedProject != null)
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AttendanceHistoryScreen(
                      projectId: _selectedProject!.id,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Sélection du projet
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Consumer<ProjectProvider>(
              builder: (context, projectProvider, _) {
                if (projectProvider.isLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (projectProvider.projects.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Aucun projet disponible'),
                    ),
                  );
                }

                return DropdownButtonFormField<ProjectModel>(
                  value: _selectedProject,
                  decoration: const InputDecoration(
                    labelText: 'Sélectionner un projet',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.construction),
                  ),
                  items: projectProvider.projects.map((project) {
                    return DropdownMenuItem<ProjectModel>(
                      value: project,
                      child: Text(project.name),
                    );
                  }).toList(),
                  onChanged: (project) {
                    setState(() {
                      _selectedProject = project;
                      _currentAttendance = null;
                    });
                    _loadCurrentAttendance();
                  },
                );
              },
            ),
          ),

          // Contenu principal
          Expanded(
            child: _selectedProject == null
                ? const Center(
                    child: Text(
                      'Veuillez sélectionner un projet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : _buildAttendanceContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceContent() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id;

    if (userId == null) {
      return const Center(
        child: Text('Utilisateur non connecté'),
      );
    }

    // Vérifier si l'utilisateur a déjà fait un check-in aujourd'hui
    final hasCheckedIn = _currentAttendance != null &&
        _currentAttendance!.checkInTime != null &&
        _currentAttendance!.checkOutTime == null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Informations du projet
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.construction, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedProject!.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_selectedProject!.address != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _selectedProject!.address!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Statut actuel
          if (hasCheckedIn) ...[
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.blue,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Vous êtes en service',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    if (_currentAttendance!.checkInTime != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Check-in: ${_formatTime(_currentAttendance!.checkInTime!)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Boutons d'action
          if (!hasCheckedIn) ...[
            ElevatedButton.icon(
              onPressed: () => _navigateToCheckIn(),
              icon: const Icon(Icons.login, size: 24),
              label: const Text(
                'CHECK-IN',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ] else ...[
            ElevatedButton.icon(
              onPressed: () => _navigateToCheckOut(),
              icon: const Icon(Icons.logout, size: 24),
              label: const Text(
                'CHECK-OUT',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF44336),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Déclarer une absence
          OutlinedButton.icon(
            onPressed: () => _navigateToAbsence(),
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Déclarer une absence'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Historique rapide
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Historique récent',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Consumer<AttendanceProvider>(
                    builder: (context, attendanceProvider, _) {
                      if (attendanceProvider.isLoading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final recentAttendances = attendanceProvider.attendances
                          .where((att) => att.employeeId == userId)
                          .take(5)
                          .toList();

                      if (recentAttendances.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Aucun pointage enregistré',
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      return Column(
                        children: recentAttendances.map((attendance) {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: attendance.isAbsence
                                  ? Colors.orange
                                  : attendance.checkOutTime != null
                                      ? Colors.green
                                      : Colors.blue,
                              child: Icon(
                                attendance.isAbsence
                                    ? Icons.cancel
                                    : attendance.checkOutTime != null
                                        ? Icons.check
                                        : Icons.access_time,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              attendance.isAbsence
                                  ? 'Absence'
                                  : '${_formatTime(attendance.checkInTime ?? '')} - ${attendance.checkOutTime != null ? _formatTime(attendance.checkOutTime!) : 'En cours'}',
                            ),
                            subtitle: Text(
                              attendance.isAbsence
                                  ? attendance.absenceReason ?? ''
                                  : '${attendance.hoursWorked?.toStringAsFixed(1) ?? '0'} heures',
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => AttendanceHistoryScreen(
                                    projectId: _selectedProject!.id,
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToCheckIn() async {
    if (_selectedProject == null) return;

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CheckInScreen(project: _selectedProject!),
      ),
    );

    if (result == true && mounted) {
      _loadCurrentAttendance();
    }
  }

  Future<void> _navigateToCheckOut() async {
    if (_selectedProject == null || _currentAttendance == null) return;

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CheckOutScreen(
          project: _selectedProject!,
          attendance: _currentAttendance!,
        ),
      ),
    );

    if (result == true && mounted) {
      _loadCurrentAttendance();
    }
  }

  Future<void> _navigateToAbsence() async {
    if (_selectedProject == null) return;

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AbsenceScreen(project: _selectedProject!),
      ),
    );

    if (result == true && mounted) {
      _loadCurrentAttendance();
    }
  }

  String _formatTime(String timeString) {
    try {
      final dateTime = DateTime.parse(timeString);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timeString;
    }
  }
}

