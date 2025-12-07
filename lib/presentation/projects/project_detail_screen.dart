import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'project_provider.dart';
import '../tasks/tasks_screen.dart';
import '../expenses/expenses_screen.dart';
import 'project_materials_tab.dart';
import 'project_employees_tab.dart';
import 'project_timeline_screen.dart';
import 'project_gallery_screen.dart';
import 'project_progress_updates_screen.dart';
import 'project_attendance_screen.dart';
import 'project_reports_screen.dart';
import 'project_chat_screen.dart';

class ProjectDetailScreen extends StatefulWidget {
  final int projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProjectProvider>(context, listen: false)
          .loadProject(widget.projectId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          'Détails du Projet',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Infos', icon: Icon(Icons.info_outline)),
            Tab(text: 'Matériaux', icon: Icon(Icons.inventory)),
            Tab(text: 'Tâches', icon: Icon(Icons.checklist)),
            Tab(text: 'Employés', icon: Icon(Icons.people)),
            Tab(text: 'Dépenses', icon: Icon(Icons.attach_money)),
            Tab(text: 'Plus', icon: Icon(Icons.more_horiz)),
          ],
        ),
      ),
      body: Consumer<ProjectProvider>(
        builder: (context, projectProvider, _) {
          if (projectProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final project = projectProvider.selectedProject;
          if (project == null) {
            return const Center(
              child: Text('Projet non trouvé'),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildInfoTab(project),
              _buildMaterialsTab(project),
              _buildTasksTab(project),
              _buildEmployeesTab(project),
              _buildExpensesTab(project),
              _buildMoreTab(project),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoTab(project) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête
          Container(
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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          project.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _getStatusColor(project.status),
                              _getStatusColor(project.status).withValues(alpha: 0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          project.statusLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (project.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      project.description!,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.grey[200],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: project.progress / 100,
                        minHeight: 12,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getStatusColor(project.status),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Avancement: ${project.progress}%',
                    style: const TextStyle(
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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(
                    icon: Icons.currency_exchange,
                    label: 'Budget',
                    value: '${project.budget.toStringAsFixed(0)} FCFA',
                  ),
                  if (project.clientName != null)
                    _InfoRow(
                      icon: Icons.person,
                      label: 'Client',
                      value: project.clientName!,
                    ),
                  if (project.address != null)
                    _InfoRow(
                      icon: Icons.location_on,
                      label: 'Adresse',
                      value: project.address!,
                    ),
                  if (project.startDate != null)
                    _InfoRow(
                      icon: Icons.calendar_today,
                      label: 'Date de début',
                      value: project.startDate!,
                    ),
                  if (project.endDate != null)
                    _InfoRow(
                      icon: Icons.event,
                      label: 'Date de fin',
                      value: project.endDate!,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsTab(project) {
    return ProjectMaterialsTab(projectId: widget.projectId);
  }

  Widget _buildTasksTab(project) {
    return TasksScreen();
  }

  Widget _buildEmployeesTab(project) {
    return ProjectEmployeesTab(projectId: widget.projectId);
  }

  Widget _buildExpensesTab(project) {
    return ExpensesScreen();
  }

  Widget _buildMoreTab(project) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildActionCard(
            icon: Icons.timeline,
            title: 'Timeline',
            subtitle: 'Voir l\'historique du projet',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProjectTimelineScreen(
                    projectId: widget.projectId,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            icon: Icons.photo_library,
            title: 'Galerie',
            subtitle: 'Voir les photos du projet',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProjectGalleryScreen(
                    projectId: widget.projectId,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            icon: Icons.update,
            title: 'Mises à jour',
            subtitle: 'Voir les mises à jour d\'avancement',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProjectProgressUpdatesScreen(
                    projectId: widget.projectId,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            icon: Icons.access_time,
            title: 'Pointage',
            subtitle: 'Gérer les pointages',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProjectAttendanceScreen(
                    projectId: widget.projectId,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            icon: Icons.description,
            title: 'Rapports',
            subtitle: 'Générer et voir les rapports',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProjectReportsScreen(
                    projectId: widget.projectId,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            icon: Icons.chat_bubble_outline,
            title: 'Chat',
            subtitle: 'Discuter sur le projet',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProjectChatScreen(
                    projectId: widget.projectId,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
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
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFB41839),
                Color(0xFF3F1B3D),
              ],
            ),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'en_cours':
        return Colors.blue;
      case 'termine':
        return Colors.green;
      case 'bloque':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey[300]!,
                  Colors.grey[400]!,
                ],
              ),
            ),
            child: Icon(icon, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

