import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/employee_model.dart';
import '../../data/repositories/employee_repository.dart';
import '../../data/repositories/project_employee_repository.dart';

class AddProjectEmployeeScreen extends StatefulWidget {
  final int projectId;

  const AddProjectEmployeeScreen({super.key, required this.projectId});

  @override
  State<AddProjectEmployeeScreen> createState() =>
      _AddProjectEmployeeScreenState();
}

class _AddProjectEmployeeScreenState extends State<AddProjectEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final EmployeeRepository _employeeRepository = EmployeeRepository();
  final ProjectEmployeeRepository _projectEmployeeRepository =
      ProjectEmployeeRepository();
  
  List<EmployeeModel> _employees = [];
  EmployeeModel? _selectedEmployee;
  DateTime? _assignedDate;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _assignedDate = DateTime.now();
    _loadEmployees();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    setState(() => _isLoading = true);
    try {
      final employees = await _employeeRepository.getEmployees();
      
      debugPrint('=== CHARGEMENT DES EMPLOYÉS ===');
      debugPrint('Nombre total d\'employés reçus: ${employees.length}');
      
      // Debug: afficher les détails de chaque employé
      for (var i = 0; i < employees.length; i++) {
        final emp = employees[i];
        debugPrint('Employé $i: ${emp.firstName} ${emp.lastName} - isActive: ${emp.isActive} (type: ${emp.isActive.runtimeType})');
      }
      
      // Filtrer les employés actifs
      final activeEmployees = employees.where((e) {
        final isActive = e.isActive;
        debugPrint('Filtrage: ${e.firstName} ${e.lastName} - isActive=$isActive (type: ${isActive.runtimeType})');
        return isActive;
      }).toList();
      
      debugPrint('Nombre d\'employés actifs après filtrage: ${activeEmployees.length}');
      
      // Si aucun employé actif mais qu'il y a des employés, afficher tous les employés pour debug
      if (activeEmployees.isEmpty && employees.isNotEmpty) {
        debugPrint('⚠️ ATTENTION: Aucun employé actif trouvé, mais ${employees.length} employé(s) chargé(s)');
        debugPrint('Affichage de tous les employés pour diagnostic...');
        // Temporairement, afficher tous les employés pour voir le problème
        setState(() {
          _employees = employees; // Afficher tous les employés pour debug
          _isLoading = false;
        });
      } else {
        setState(() {
          _employees = activeEmployees;
          _isLoading = false;
        });
      }
      
      if (_employees.isEmpty && mounted) {
        if (employees.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Aucun employé trouvé. Veuillez créer un employé d\'abord.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Aucun employé actif disponible. ${employees.length} employé(s) trouvé(s) mais tous sont inactifs.'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Erreur lors du chargement des employés: $e');
      debugPrint('Stack trace: $stackTrace');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des employés: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _assignedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _assignedDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedEmployee == null) {
      if (_selectedEmployee == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner un employé'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _isSubmitting = true);

    debugPrint('=== SUBMIT ASSIGN EMPLOYEE ===');
    debugPrint('Project ID: ${widget.projectId}');
    debugPrint('Selected Employee: ${_selectedEmployee?.fullName}');
    debugPrint('Employee ID: ${_selectedEmployee?.id}');
    debugPrint('Assigned Date: ${_assignedDate?.toIso8601String().split('T')[0]}');
    debugPrint('Notes: ${_notesController.text.trim()}');

    final result = await _projectEmployeeRepository.assignEmployeeToProject(
      projectId: widget.projectId,
      employeeId: _selectedEmployee!.id,
      assignedDate: _assignedDate?.toIso8601String().split('T')[0],
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    setState(() => _isSubmitting = false);

    if (result['success'] == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Employé affecté au projet avec succès'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
      Navigator.of(context).pop(true);
    } else if (mounted) {
      final errorMessage = result['message'] ?? 'Erreur lors de l\'affectation';
      debugPrint('Error message to display: $errorMessage');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
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
                Color(0xFFB41839),
                Color(0xFF3F1B3D),
              ],
            ),
          ),
        ),
        title: const Text(
          'Affecter un employé',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                              'Sélectionner un employé',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _employees.isEmpty
                                ? Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.orange[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.orange[200]!,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.info_outline,
                                            color: Colors.orange[700]),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Aucun employé actif disponible',
                                            style: TextStyle(
                                              color: Colors.orange[700],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : DropdownButtonFormField<EmployeeModel>(
                                    value: _selectedEmployee,
                                    decoration: InputDecoration(
                                      labelText: 'Employé *',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      prefixIcon: const Icon(Icons.person),
                                      hintText: 'Sélectionner un employé',
                                      helperText: '${_employees.length} employé(s) disponible(s)',
                                    ),
                                    isExpanded: true,
                                    menuMaxHeight: 300,
                                    items: _employees.map((employee) {
                                      final fullName =
                                          '${employee.firstName} ${employee.lastName}';
                                      final displayText = employee.position != null
                                          ? '$fullName - ${employee.position}'
                                          : fullName;
                                      return DropdownMenuItem<EmployeeModel>(
                                        value: employee,
                                        child: Text(
                                          displayText,
                                          style: const TextStyle(
                                            fontSize: 16,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      debugPrint('Employé sélectionné: ${value?.firstName} ${value?.lastName}');
                                      setState(() {
                                        _selectedEmployee = value;
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null) {
                                        return 'Veuillez sélectionner un employé';
                                      }
                                      return null;
                                    },
                                  ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
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
                            TextFormField(
                              readOnly: true,
                              controller: TextEditingController(
                                text: _assignedDate != null
                                    ? '${_assignedDate!.day}/${_assignedDate!.month}/${_assignedDate!.year}'
                                    : '',
                              ),
                              decoration: InputDecoration(
                                labelText: 'Date d\'affectation',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.calendar_today),
                                suffixIcon: const Icon(Icons.arrow_drop_down),
                              ),
                              onTap: _selectDate,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _notesController,
                              decoration: InputDecoration(
                                labelText: 'Notes',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.note),
                              ),
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
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
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'AFFECTER',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

