import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'task_provider.dart';
import '../employees/employee_provider.dart';

class CreateTaskScreen extends StatefulWidget {
  final int projectId;

  const CreateTaskScreen({super.key, required this.projectId});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _status = 'a_faire';
  String _priority = 'moyenne';
  DateTime? _startDate;
  DateTime? _deadline;
  int _progress = 0;
  int? _selectedEmployeeId;

  final List<Map<String, String>> _statuses = [
    {'value': 'a_faire', 'label': 'À faire'},
    {'value': 'en_cours', 'label': 'En cours'},
    {'value': 'termine', 'label': 'Terminé'},
    {'value': 'bloque', 'label': 'Bloqué'},
  ];

  final List<Map<String, String>> _priorities = [
    {'value': 'basse', 'label': 'Basse'},
    {'value': 'moyenne', 'label': 'Moyenne'},
    {'value': 'haute', 'label': 'Haute'},
    {'value': 'urgente', 'label': 'Urgente'},
  ];

  final List<String> _categories = [
    'Maçonnerie',
    'Fondations',
    'Électricité',
    'Plomberie',
    'Peinture',
    'Menuiserie',
    'Carrelage',
    'Isolation',
    'Autres',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
      if (employeeProvider.employees.isEmpty) {
        employeeProvider.loadEmployees();
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate 
          ? (_startDate ?? DateTime.now())
          : (_deadline ?? DateTime.now().add(const Duration(days: 7))),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _deadline = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    final data = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      'category': _categoryController.text.trim().isEmpty
          ? null
          : _categoryController.text.trim(),
      'status': _status,
      'priority': _priority,
      'start_date': _startDate?.toIso8601String().split('T')[0],
      'deadline': _deadline?.toIso8601String().split('T')[0],
      'progress': _progress,
      'assigned_to': _selectedEmployeeId,
      'notes': _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    };

    final success = await taskProvider.createTask(
      projectId: widget.projectId,
      data: data,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tâche créée avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            taskProvider.errorMessage ?? 'Erreur lors de la création',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle tâche'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Titre
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le titre est requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Catégorie
              DropdownButtonFormField<String>(
                value: _categoryController.text.isEmpty ? null : _categoryController.text,
                decoration: const InputDecoration(
                  labelText: 'Catégorie',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Aucune')),
                  ..._categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }),
                ],
                onChanged: (value) {
                  _categoryController.text = value ?? '';
                },
              ),
              const SizedBox(height: 16),

              // Statut
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Statut *',
                  border: OutlineInputBorder(),
                ),
                items: _statuses.map((status) {
                  return DropdownMenuItem(
                    value: status['value'],
                    child: Text(status['label']!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _status = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Priorité
              DropdownButtonFormField<String>(
                value: _priority,
                decoration: const InputDecoration(
                  labelText: 'Priorité *',
                  border: OutlineInputBorder(),
                ),
                items: _priorities.map((priority) {
                  return DropdownMenuItem(
                    value: priority['value'],
                    child: Text(priority['label']!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _priority = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Date de début
              InkWell(
                onTap: () => _selectDate(context, true),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date de début',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _startDate != null
                        ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                        : 'Sélectionner une date',
                    style: TextStyle(
                      color: _startDate != null ? Colors.black : Colors.grey[600],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Date d'échéance
              InkWell(
                onTap: () => _selectDate(context, false),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date d\'échéance',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _deadline != null
                        ? '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}'
                        : 'Sélectionner une date',
                    style: TextStyle(
                      color: _deadline != null ? Colors.black : Colors.grey[600],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Assignation
              Consumer<EmployeeProvider>(
                builder: (context, employeeProvider, _) {
                  return DropdownButtonFormField<int?>(
                    value: _selectedEmployeeId,
                    decoration: const InputDecoration(
                      labelText: 'Assigner à',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Non assigné'),
                      ),
                      ...employeeProvider.employees.map((employee) {
                        return DropdownMenuItem(
                          value: employee.id,
                          child: Text(employee.fullName),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedEmployeeId = value;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 16),

              // Progression
              Text(
                'Progression: $_progress%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Slider(
                value: _progress.toDouble(),
                min: 0,
                max: 100,
                divisions: 100,
                label: '$_progress%',
                activeColor: const Color(0xFFB41839),
                onChanged: (value) {
                  setState(() {
                    _progress = value.toInt();
                  });
                },
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Bouton de soumission
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFFB41839),
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'CRÉER LA TÂCHE',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
