import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../attendance/attendance_provider.dart';
import '../attendance/attendance_history_screen.dart';

class ProjectAttendanceScreen extends StatefulWidget {
  final int projectId;

  const ProjectAttendanceScreen({super.key, required this.projectId});

  @override
  State<ProjectAttendanceScreen> createState() =>
      _ProjectAttendanceScreenState();
}

class _ProjectAttendanceScreenState extends State<ProjectAttendanceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AttendanceProvider>(context, listen: false)
          .loadAttendances(widget.projectId);
    });
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
                Color(0xFFB41839),
                Color(0xFF3F1B3D),
              ],
            ),
          ),
        ),
        title: const Text(
          'Pointage',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AttendanceHistoryScreen(
                    projectId: widget.projectId,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<AttendanceProvider>(
        builder: (context, attendanceProvider, _) {
          if (attendanceProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Bouton Check-in
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFB41839),
                        Color(0xFF3F1B3D),
                      ],
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      // TODO: Récupérer le projet depuis le provider
                      // final project = Provider.of<ProjectProvider>(context, listen: false)
                      //     .projects.firstWhere((p) => p.id == widget.projectId);
                      // final result = await Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //     builder: (_) => CheckInScreen(
                      //       project: project,
                      //     ),
                      //   ),
                      // );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fonctionnalité en cours de développement'),
                        ),
                      );
                      final result = false;
                      if (result == true && mounted) {
                        attendanceProvider.loadAttendances(widget.projectId);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.login, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'CHECK-IN',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Informations
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pointage du jour',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (attendanceProvider.attendances.isEmpty)
                        const Text(
                          'Aucun pointage enregistré aujourd\'hui',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        )
                      else
                        ...attendanceProvider.attendances.map((attendance) {
                          return ListTile(
                            leading: const Icon(Icons.access_time),
                            title: Text(
                              attendance.checkInTime != null
                                  ? 'Check-in: ${_formatTime(attendance.checkInTime!)}'
                                  : 'Non pointé',
                            ),
                            subtitle: attendance.checkOutTime != null
                                ? Text('Check-out: ${_formatTime(attendance.checkOutTime!)}')
                                : null,
                          );
                        }),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
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

