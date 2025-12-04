import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'employee_provider.dart';
import '../../data/models/employee_model.dart';
import 'create_employee_screen.dart';
import 'employee_detail_screen.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  String _filter = 'all'; // all, active

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EmployeeProvider>(context, listen: false).loadEmployees();
    });
  }

  List<EmployeeModel> _getFilteredEmployees(List<EmployeeModel> employees) {
    switch (_filter) {
      case 'active':
        return employees.where((e) => e.isActive).toList();
      default:
        return employees;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employés'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CreateEmployeeScreen(),
                ),
              ).then((_) {
                Provider.of<EmployeeProvider>(context, listen: false)
                    .loadEmployees();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtres
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Tous'),
                    selected: _filter == 'all',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _filter = 'all';
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Actifs'),
                    selected: _filter == 'active',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _filter = 'active';
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          // Liste
          Expanded(
            child: Consumer<EmployeeProvider>(
              builder: (context, employeeProvider, _) {
                if (employeeProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (employeeProvider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          employeeProvider.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            employeeProvider.clearError();
                            employeeProvider.loadEmployees();
                          },
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }

                final filteredEmployees =
                    _getFilteredEmployees(employeeProvider.employees);

                if (filteredEmployees.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.people, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'Aucun employé trouvé',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const CreateEmployeeScreen(),
                              ),
                            );
                          },
                          child: const Text('Créer un employé'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => employeeProvider.loadEmployees(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredEmployees.length,
                    itemBuilder: (context, index) {
                      final employee = filteredEmployees[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: Colors.green.withAlpha((255 * 0.2).round()),
                            child: Text(
                              employee.firstName[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            employee.fullName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (employee.position != null)
                                Text(
                                  employee.position!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              if (employee.phone != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.phone, size: 12, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      employee.phone!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (employee.employeeNumber != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'N°: ${employee.employeeNumber}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: Colors.grey[400],
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => EmployeeDetailScreen(
                                  employeeId: employee.id,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


