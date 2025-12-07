import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/attendance_model.dart';
import '../auth/auth_provider.dart';
import 'attendance_provider.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  final int projectId;

  const AttendanceHistoryScreen({super.key, required this.projectId});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AttendanceProvider>(
        context,
        listen: false,
      ).loadAttendances(widget.projectId);
    });
  }

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeString;
    }
  }

  String _formatTime(String? timeString) {
    if (timeString == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(timeString);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timeString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFB41839), // Rouge
                Color(0xFF3F1B3D), // Violet foncé
              ],
            ),
          ),
        ),
        title: const Text(
          'Historique des pointages',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<AttendanceProvider>(
        builder: (context, attendanceProvider, _) {
          if (attendanceProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (attendanceProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    attendanceProvider.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      attendanceProvider.loadAttendances(widget.projectId);
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final attendances = attendanceProvider.attendances;
          final authProvider = Provider.of<AuthProvider>(
            context,
            listen: false,
          );
          final userId = authProvider.user?.id;

          final userAttendances = userId != null
              ? attendances.where((att) => att.employeeId == userId).toList()
              : <AttendanceModel>[];

          if (userAttendances.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icône avec design 3D
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.grey[300]!, Colors.grey[400]!],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.access_time,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Aucun pointage enregistré',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Vos pointages apparaîtront ici',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                attendanceProvider.loadAttendances(widget.projectId),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: userAttendances.length,
              itemBuilder: (context, index) {
                final attendance = userAttendances[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
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
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    attendance.isAbsence
                                        ? 'Absence'
                                        : 'Pointage',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDateTime(
                                      attendance.checkInTime ??
                                          attendance.createdAt,
                                    ),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (attendance.isAbsence) ...[
                          if (attendance.absenceReason != null)
                            Text(
                              'Raison: ${attendance.absenceReason}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                        ] else ...[
                          Row(
                            children: [
                              Expanded(
                                child: _InfoItem(
                                  icon: Icons.login,
                                  label: 'Check-in',
                                  value: _formatTime(attendance.checkInTime),
                                ),
                              ),
                              if (attendance.checkOutTime != null)
                                Expanded(
                                  child: _InfoItem(
                                    icon: Icons.logout,
                                    label: 'Check-out',
                                    value: _formatTime(attendance.checkOutTime),
                                  ),
                                ),
                            ],
                          ),
                          if (attendance.hoursWorked != null) ...[
                            const SizedBox(height: 8),
                            _InfoItem(
                              icon: Icons.access_time,
                              label: 'Heures travaillées',
                              value:
                                  '${attendance.hoursWorked!.toStringAsFixed(1)} h',
                            ),
                          ],
                          if (attendance.overtimeHours != null &&
                              attendance.overtimeHours! > 0) ...[
                            const SizedBox(height: 8),
                            _InfoItem(
                              icon: Icons.timer,
                              label: 'Heures supplémentaires',
                              value:
                                  '${attendance.overtimeHours!.toStringAsFixed(1)} h',
                              color: Colors.orange,
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color ?? Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
