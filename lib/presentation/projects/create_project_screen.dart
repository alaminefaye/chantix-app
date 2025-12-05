import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'project_provider.dart';

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _clientNameController = TextEditingController();
  final _clientContactController = TextEditingController();
  final _budgetController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  
  String _selectedStatus = 'non_demarre';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _clientNameController.dispose();
    _clientContactController.dispose();
    _budgetController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
      
      final data = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'address': _addressController.text.trim(),
        'client_name': _clientNameController.text.trim(),
        'client_contact': _clientContactController.text.trim(),
        'budget': double.tryParse(_budgetController.text) ?? 0,
        'status': _selectedStatus,
        'start_date': _startDate != null 
            ? '${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}'
            : null,
        'end_date': _endDate != null
            ? '${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}'
            : null,
      };

      final success = await projectProvider.createProject(data);

      if (mounted) {
        if (success) {
          // Recharger les projets avant de naviguer
          await projectProvider.loadProjects();
          
          Navigator.of(context).pop(); // Retourner à l'écran précédent
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Projet créé avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                projectProvider.errorMessage ?? 'Erreur lors de la création',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate 
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? _startDate ?? DateTime.now()),
      firstDate: isStartDate ? DateTime.now() : (_startDate ?? DateTime.now()),
      lastDate: DateTime(2100),
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
          _startDateController.text = 
              '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
        } else {
          _endDate = picked;
          _endDateController.text = 
              '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
        }
      });
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
          'Nouveau Projet',
          style: TextStyle(
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
              _FormField3D(
                controller: _nameController,
                label: 'Nom du projet *',
                icon: Icons.title,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nom du projet';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _FormField3D(
                controller: _descriptionController,
                label: 'Description',
                icon: Icons.description,
                maxLines: 3,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              _FormField3D(
                controller: _addressController,
                label: 'Adresse',
                icon: Icons.location_on,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              _FormField3D(
                controller: _clientNameController,
                label: 'Nom du client',
                icon: Icons.person,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              _FormField3D(
                controller: _clientContactController,
                label: 'Contact client',
                icon: Icons.phone,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              _FormField3D(
                controller: _budgetController,
                label: 'Budget (FCFA) *',
                icon: Icons.currency_exchange,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le budget';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _DropdownField3D(
                value: _selectedStatus,
                label: 'Statut *',
                icon: Icons.flag,
                items: const [
                  DropdownMenuItem(value: 'non_demarre', child: Text('Non démarré')),
                  DropdownMenuItem(value: 'en_cours', child: Text('En cours')),
                  DropdownMenuItem(value: 'termine', child: Text('Terminé')),
                  DropdownMenuItem(value: 'bloque', child: Text('Bloqué')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
              ),
              const SizedBox(height: 12),
              _DateField3D(
                label: 'Date de début',
                icon: Icons.calendar_today,
                value: _startDate,
                onTap: () => _selectDate(context, true),
              ),
              const SizedBox(height: 12),
              _DateField3D(
                label: 'Date de fin',
                icon: Icons.event,
                value: _endDate,
                onTap: () => _selectDate(context, false),
              ),
              const SizedBox(height: 24),
              Consumer<ProjectProvider>(
                builder: (context, projectProvider, _) {
                  return Container(
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
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFB41839).withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: projectProvider.isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: projectProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Créer le projet',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
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
  final TextInputType? keyboardType;
  final int? maxLines;
  final String? Function(String?)? validator;
  final IconData icon;
  final TextInputAction? textInputAction;

  const _FormField3D({
    this.controller,
    required this.label,
    this.keyboardType,
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
        keyboardType: widget.keyboardType,
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
          // Fermer le clavier
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
                      colors: [
                        Color(0xFFB41839),
                        Color(0xFF3F1B3D),
                      ],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey[300]!,
                        Colors.grey[400]!,
                      ],
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
            child: Icon(
              widget.icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            borderSide: const BorderSide(
              color: Color(0xFFB41839),
              width: 2,
            ),
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
  final String value;
  final String label;
  final List<DropdownMenuItem<String>> items;
  final Function(String?)? onChanged;
  final IconData icon;

  const _DropdownField3D({
    required this.value,
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
      child: DropdownButtonFormField<String>(
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
                      colors: [
                        Color(0xFFB41839),
                        Color(0xFF3F1B3D),
                      ],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey[300]!,
                        Colors.grey[400]!,
                      ],
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
            child: Icon(
              widget.icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            borderSide: const BorderSide(
              color: Color(0xFFB41839),
              width: 2,
            ),
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
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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
              color: _isFocused 
                  ? const Color(0xFFB41839)
                  : Colors.grey[300]!,
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
                          colors: [
                            Color(0xFFB41839),
                            Color(0xFF3F1B3D),
                          ],
                        )
                      : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.grey[300]!,
                            Colors.grey[400]!,
                          ],
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
                child: Icon(
                  widget.icon,
                  color: Colors.white,
                  size: 20,
                ),
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
              Icon(
                Icons.calendar_month,
                color: Colors.grey[400],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
