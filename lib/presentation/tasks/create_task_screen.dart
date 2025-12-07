import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'task_provider.dart';
import '../employees/employee_provider.dart';
import '../../data/models/task_model.dart';

class CreateTaskScreen extends StatefulWidget {
  final int projectId;
  final TaskModel? task;

  const CreateTaskScreen({super.key, required this.projectId, this.task});

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
    // Initialize with task data if editing
    if (widget.task != null) {
      final task = widget.task!;
      _titleController.text = task.title;
      _descriptionController.text = task.description ?? '';
      _categoryController.text = task.category ?? '';
      _status = task.status;
      _priority = task.priority;
      _progress = task.progress;
      _selectedEmployeeId = task.assignedTo;
      _notesController.text = task.notes ?? '';

      if (task.startDate != null) {
        try {
          _startDate = DateTime.parse(task.startDate!);
        } catch (e) {
          // Ignore parse errors
        }
      }

      if (task.deadline != null) {
        try {
          _deadline = DateTime.parse(task.deadline!);
        } catch (e) {
          // Ignore parse errors
        }
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final employeeProvider = Provider.of<EmployeeProvider>(
        context,
        listen: false,
      );
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFB41839), // Couleur principale
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
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

    final bool success;
    if (widget.task != null) {
      // Update existing task
      success = await taskProvider.updateTask(
        id: widget.task!.id,
        projectId: widget.projectId,
        data: data,
      );
    } else {
      // Create new task
      success = await taskProvider.createTask(
        projectId: widget.projectId,
        data: data,
      );
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.task != null
                ? 'Tâche mise à jour avec succès'
                : 'Tâche créée avec succès',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            taskProvider.errorMessage ??
                (widget.task != null
                    ? 'Erreur lors de la mise à jour'
                    : 'Erreur lors de la création'),
          ),
          backgroundColor: Colors.red,
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
                Color(0xFFB41839), // Rouge
                Color(0xFF3F1B3D), // Violet foncé
              ],
            ),
          ),
        ),
        title: Text(
          widget.task != null ? 'Modifier la tâche' : 'Nouvelle tâche',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Titre
              _FormField3D(
                controller: _titleController,
                label: 'Titre *',
                icon: Icons.title,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le titre est requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Description
              _FormField3D(
                controller: _descriptionController,
                label: 'Description',
                icon: Icons.description,
                maxLines: 3,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),

              // Catégorie
              _DropdownField3D(
                value: _categoryController.text.isEmpty
                    ? null
                    : _categoryController.text,
                label: 'Catégorie',
                icon: Icons.category,
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
                  setState(() {
                    _categoryController.text = value ?? '';
                  });
                },
              ),
              const SizedBox(height: 12),

              // Statut
              _DropdownField3D(
                value: _status,
                label: 'Statut *',
                icon: Icons.flag,
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
              const SizedBox(height: 12),

              // Priorité
              _DropdownField3D(
                value: _priority,
                label: 'Priorité *',
                icon: Icons.priority_high,
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
              const SizedBox(height: 12),

              // Date de début
              _DateField3D(
                label: 'Date de début',
                icon: Icons.calendar_today,
                value: _startDate,
                onTap: () => _selectDate(context, true),
              ),
              const SizedBox(height: 12),

              // Date d'échéance
              _DateField3D(
                label: 'Date d\'échéance',
                icon: Icons.event,
                value: _deadline,
                onTap: () => _selectDate(context, false),
              ),
              const SizedBox(height: 12),

              // Assignation
              Consumer<EmployeeProvider>(
                builder: (context, employeeProvider, _) {
                  return _DropdownField3D(
                    value: _selectedEmployeeId?.toString(),
                    label: 'Assigner à',
                    icon: Icons.person,
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Non assigné'),
                      ),
                      ...employeeProvider.employees.map((employee) {
                        return DropdownMenuItem(
                          value: employee.id.toString(),
                          child: Text(employee.fullName),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedEmployeeId = value != null
                            ? int.tryParse(value)
                            : null;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 12),

              // Progression
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Colors.grey[300]!, Colors.grey[400]!],
                            ),
                          ),
                          child: const Icon(
                            Icons.trending_up,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Progression: $_progress%',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
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
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Notes
              _FormField3D(
                controller: _notesController,
                label: 'Notes',
                icon: Icons.note,
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 24),

              // Bouton de soumission
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFB41839), Color(0xFF3F1B3D)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFB41839).withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    widget.task != null
                        ? 'MODIFIER LA TÂCHE'
                        : 'CRÉER LA TÂCHE',
                    style: const TextStyle(
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

// Champ de formulaire avec design 3D amélioré
class _FormField3D extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final int? maxLines;
  final String? Function(String?)? validator;
  final IconData icon;
  final TextInputAction? textInputAction;

  const _FormField3D({
    this.controller,
    required this.label,
    this.maxLines,
    this.validator,
    required this.icon,
    this.textInputAction,
  });

  @override
  State<_FormField3D> createState() => _FormField3DState();
}

class _FormField3DState extends State<_FormField3D> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _isFocused
                ? const Color(0xFFB41839).withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: _isFocused ? 15 : 10,
            offset: const Offset(0, 4),
            spreadRadius: _isFocused ? 1 : 0,
          ),
        ],
      ),
      child: TextFormField(
        controller: widget.controller,
        maxLines: widget.maxLines ?? 1,
        validator: widget.validator,
        textInputAction: widget.textInputAction ?? TextInputAction.next,
        onTap: () => setState(() => _isFocused = true),
        onChanged: (value) {
          if (!_isFocused) {
            setState(() => _isFocused = true);
          }
        },
        onFieldSubmitted: (value) {
          setState(() => _isFocused = false);
          FocusScope.of(context).unfocus();
        },
        onEditingComplete: () => setState(() => _isFocused = false),
        decoration: InputDecoration(
          labelText: widget.label,
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: _isFocused
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFB41839), Color(0xFF3F1B3D)],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.grey[300]!, Colors.grey[400]!],
                    ),
              boxShadow: [
                BoxShadow(
                  color: _isFocused
                      ? const Color(0xFFB41839).withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(widget.icon, color: Colors.white, size: 20),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFB41839), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          labelStyle: TextStyle(
            color: _isFocused ? const Color(0xFFB41839) : Colors.grey[600],
            fontWeight: _isFocused ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// Dropdown avec design 3D amélioré
class _DropdownField3D extends StatefulWidget {
  final String? value;
  final String label;
  final List<DropdownMenuItem<String?>> items;
  final Function(String?)? onChanged;
  final IconData icon;

  const _DropdownField3D({
    this.value,
    required this.label,
    required this.items,
    required this.onChanged,
    required this.icon,
  });

  @override
  State<_DropdownField3D> createState() => _DropdownField3DState();
}

class _DropdownField3DState extends State<_DropdownField3D> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _isFocused
                ? const Color(0xFFB41839).withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: _isFocused ? 15 : 10,
            offset: const Offset(0, 4),
            spreadRadius: _isFocused ? 1 : 0,
          ),
        ],
      ),
      child: DropdownButtonFormField<String?>(
        initialValue: widget.value,
        decoration: InputDecoration(
          labelText: widget.label,
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: _isFocused
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFB41839), Color(0xFF3F1B3D)],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.grey[300]!, Colors.grey[400]!],
                    ),
              boxShadow: [
                BoxShadow(
                  color: _isFocused
                      ? const Color(0xFFB41839).withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(widget.icon, color: Colors.white, size: 20),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFB41839), width: 2),
          ),
          labelStyle: TextStyle(
            color: _isFocused ? const Color(0xFFB41839) : Colors.grey[600],
            fontWeight: _isFocused ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        items: widget.items,
        onChanged: (value) {
          setState(() => _isFocused = false);
          widget.onChanged?.call(value);
        },
        onTap: () => setState(() => _isFocused = true),
      ),
    );
  }
}

// Champ de date avec design 3D et calendrier
class _DateField3D extends StatefulWidget {
  final String label;
  final IconData icon;
  final DateTime? value;
  final VoidCallback onTap;

  const _DateField3D({
    required this.label,
    required this.icon,
    required this.value,
    required this.onTap,
  });

  @override
  State<_DateField3D> createState() => _DateField3DState();
}

class _DateField3DState extends State<_DateField3D> {
  bool _isFocused = false;

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => _isFocused = true);
        widget.onTap();
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            setState(() => _isFocused = false);
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _isFocused
                  ? const Color(0xFFB41839).withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.06),
              blurRadius: _isFocused ? 15 : 10,
              offset: const Offset(0, 4),
              spreadRadius: _isFocused ? 1 : 0,
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            border: Border.all(
              color: _isFocused ? const Color(0xFFB41839) : Colors.grey[300]!,
              width: _isFocused ? 2 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: _isFocused
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFB41839), Color(0xFF3F1B3D)],
                        )
                      : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.grey[300]!, Colors.grey[400]!],
                        ),
                  boxShadow: [
                    BoxShadow(
                      color: _isFocused
                          ? const Color(0xFFB41839).withValues(alpha: 0.3)
                          : Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(widget.icon, color: Colors.white, size: 20),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 12,
                        color: _isFocused
                            ? const Color(0xFFB41839)
                            : Colors.grey[600],
                        fontWeight: _isFocused
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.value != null
                          ? _formatDate(widget.value)
                          : 'Sélectionner une date',
                      style: TextStyle(
                        fontSize: 16,
                        color: widget.value != null
                            ? Colors.black87
                            : Colors.grey[400],
                        fontWeight: widget.value != null
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.calendar_month, color: Colors.grey[400], size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
