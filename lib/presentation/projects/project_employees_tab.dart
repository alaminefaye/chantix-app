import 'package:flutter/material.dart';
import '../../data/models/project_employee_model.dart';
import '../../data/repositories/project_employee_repository.dart';
import 'add_project_employee_screen.dart';

class ProjectEmployeesTab extends StatefulWidget {
  final int projectId;

  const ProjectEmployeesTab({super.key, required this.projectId});

  @override
  State<ProjectEmployeesTab> createState() => _ProjectEmployeesTabState();
}

class _ProjectEmployeesTabState extends State<ProjectEmployeesTab> {
  final ProjectEmployeeRepository _repository = ProjectEmployeeRepository();
  List<ProjectEmployeeModel> _employees = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() => _isLoading = true);
    final employees = await _repository.getProjectEmployees(widget.projectId);
    setState(() {
      _employees = employees;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadEmployees,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Employés affectés',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AddProjectEmployeeScreen(
                          projectId: widget.projectId,
                        ),
                      ),
                    );
                    if (result == true) {
                      _loadEmployees();
                    }
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text('Affecter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB41839),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _employees.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucun employé affecté à ce projet',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Appuyez sur "Affecter" pour en ajouter',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _employees.length,
                        itemBuilder: (context, index) {
                          final projectEmployee = _employees[index];
                          return _EmployeeCard(
                            projectEmployee: projectEmployee,
                            onRemove: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Confirmer le retrait'),
                                  content: Text(
                                    'Voulez-vous retirer "${projectEmployee.employee.firstName} ${projectEmployee.employee.lastName}" du projet ?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Annuler'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      child: const Text('Retirer'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                final success = await _repository
                                    .removeEmployeeFromProject(
                                  widget.projectId,
                                  projectEmployee.employee.id,
                                );
                                if (success && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Employé retiré du projet'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  _loadEmployees();
                                } else if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Erreur lors du retrait'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _EmployeeCard extends StatelessWidget {
  final ProjectEmployeeModel projectEmployee;
  final VoidCallback onRemove;

  const _EmployeeCard({
    required this.projectEmployee,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final employee = projectEmployee.employee;
    final fullName = '${employee.firstName} ${employee.lastName}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFB41839),
                Color(0xFF3F1B3D),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              fullName.isNotEmpty ? fullName[0].toUpperCase() : 'E',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          fullName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (employee.position != null) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  employee.position!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            if (projectEmployee.assignedDate != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Affecté le: ${_formatDate(projectEmployee.assignedDate!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onRemove,
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}

