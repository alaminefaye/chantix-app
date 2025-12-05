import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'employee_provider.dart';
import 'create_employee_screen.dart';

class EmployeeDetailScreen extends StatefulWidget {
  final int employeeId;

  const EmployeeDetailScreen({super.key, required this.employeeId});

  @override
  State<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EmployeeProvider>(context, listen: false)
          .loadEmployee(widget.employeeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Détails de l\'employé'),
        actions: [
          Consumer<EmployeeProvider>(
            builder: (context, employeeProvider, _) {
              final employee = employeeProvider.selectedEmployee;
              if (employee == null) return const SizedBox.shrink();

              return IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CreateEmployeeScreen(
                        employee: employee,
                      ),
                    ),
                  ).then((_) {
                    employeeProvider.loadEmployee(widget.employeeId);
                  });
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<EmployeeProvider>(
        builder: (context, employeeProvider, _) {
          if (employeeProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final employee = employeeProvider.selectedEmployee;
          if (employee == null) {
            return const Center(
              child: Text('Employé non trouvé'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.green.withAlpha((255 * 0.2).round()),
                          child: Text(
                            employee.firstName[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                employee.fullName,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (employee.position != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  employee.position!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Informations personnelles
                _buildSectionTitle('Informations personnelles'),
                _buildInfoCard([
                  _buildInfoRow('Prénom', employee.firstName),
                  _buildInfoRow('Nom', employee.lastName),
                  if (employee.email != null)
                    _buildInfoRow('Email', employee.email!),
                  if (employee.phone != null)
                    _buildInfoRow('Téléphone', employee.phone!),
                  if (employee.birthDate != null)
                    _buildInfoRow('Date de naissance', _formatDate(employee.birthDate!)),
                  if (employee.idNumber != null)
                    _buildInfoRow('Numéro d\'identité', employee.idNumber!),
                ]),
                const SizedBox(height: 16),

                // Informations professionnelles
                _buildSectionTitle('Informations professionnelles'),
                _buildInfoCard([
                  if (employee.employeeNumber != null)
                    _buildInfoRow('Numéro d\'employé', employee.employeeNumber!),
                  if (employee.position != null)
                    _buildInfoRow('Poste', employee.position!),
                  if (employee.hireDate != null)
                    _buildInfoRow('Date d\'embauche', _formatDate(employee.hireDate!)),
                  if (employee.hourlyRate != null)
                    _buildInfoRow(
                      'Taux horaire',
                      '${employee.hourlyRate!.toStringAsFixed(2)} FCFA/h',
                    ),
                ]),
                const SizedBox(height: 16),

                // Adresse
                if (employee.address != null || employee.city != null || employee.country != null) ...[
                  _buildSectionTitle('Adresse'),
                  _buildInfoCard([
                    if (employee.address != null)
                      _buildInfoRow('Adresse', employee.address!),
                    if (employee.city != null)
                      _buildInfoRow('Ville', employee.city!),
                    if (employee.country != null)
                      _buildInfoRow('Pays', employee.country!),
                  ]),
                  const SizedBox(height: 16),
                ],

                // Notes
                if (employee.notes != null && employee.notes!.isNotEmpty) ...[
                  _buildSectionTitle('Notes'),
                  _buildInfoCard([
                    _buildInfoRow('Notes', employee.notes!),
                  ]),
                  const SizedBox(height: 16),
                ],

                // Statut
                _buildSectionTitle('Statut'),
                _buildInfoCard([
                  _buildInfoRow(
                    'Statut',
                    employee.isActive ? 'Actif' : 'Inactif',
                  ),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
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

