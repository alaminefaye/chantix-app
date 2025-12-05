import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'employee_provider.dart';
import '../../data/models/employee_model.dart';

class CreateEmployeeScreen extends StatefulWidget {
  final EmployeeModel? employee;

  const CreateEmployeeScreen({super.key, this.employee});

  @override
  State<CreateEmployeeScreen> createState() => _CreateEmployeeScreenState();
}

class _CreateEmployeeScreenState extends State<CreateEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _positionController = TextEditingController();
  final _employeeNumberController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _hireDate;
  DateTime? _birthDate;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.employee != null) {
      final e = widget.employee!;
      _firstNameController.text = e.firstName;
      _lastNameController.text = e.lastName;
      _emailController.text = e.email ?? '';
      _phoneController.text = e.phone ?? '';
      _positionController.text = e.position ?? '';
      _employeeNumberController.text = e.employeeNumber ?? '';
      _hourlyRateController.text = e.hourlyRate?.toStringAsFixed(2) ?? '';
      _addressController.text = e.address ?? '';
      _cityController.text = e.city ?? '';
      _countryController.text = e.country ?? '';
      _idNumberController.text = e.idNumber ?? '';
      _notesController.text = e.notes ?? '';
      _hireDate = e.hireDate != null ? DateTime.parse(e.hireDate!) : null;
      _birthDate = e.birthDate != null ? DateTime.parse(e.birthDate!) : null;
      _isActive = e.isActive;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _positionController.dispose();
    _employeeNumberController.dispose();
    _hourlyRateController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _idNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final employeeProvider = Provider.of<EmployeeProvider>(
      context,
      listen: false,
    );

    final data = {
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'email': _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      'phone': _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      'position': _positionController.text.trim().isEmpty
          ? null
          : _positionController.text.trim(),
      'employee_number': _employeeNumberController.text.trim().isEmpty
          ? null
          : _employeeNumberController.text.trim(),
      'hourly_rate': _hourlyRateController.text.trim().isEmpty
          ? null
          : double.tryParse(_hourlyRateController.text.trim()),
      'address': _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      'city': _cityController.text.trim().isEmpty
          ? null
          : _cityController.text.trim(),
      'country': _countryController.text.trim().isEmpty
          ? null
          : _countryController.text.trim(),
      'id_number': _idNumberController.text.trim().isEmpty
          ? null
          : _idNumberController.text.trim(),
      'notes': _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      'hire_date': _hireDate?.toIso8601String().split('T')[0],
      'birth_date': _birthDate?.toIso8601String().split('T')[0],
      'is_active': _isActive,
    };

    final success = widget.employee == null
        ? await employeeProvider.createEmployee(data)
        : await employeeProvider.updateEmployee(widget.employee!.id, data);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.employee == null
                ? 'Employé créé avec succès'
                : 'Employé mis à jour avec succès',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            employeeProvider.errorMessage ?? 'Erreur lors de l\'opération',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context, bool isHireDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isHireDate
          ? (_hireDate ?? DateTime.now())
          : (_birthDate ?? DateTime(1990)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
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
        if (isHireDate) {
          _hireDate = picked;
        } else {
          _birthDate = picked;
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
        title: Text(
          widget.employee == null ? 'Nouvel employé' : 'Modifier l\'employé',
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
              // Informations personnelles
              const Text(
                'Informations personnelles',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _FormField3D(
                controller: _firstNameController,
                label: 'Prénom *',
                icon: Icons.person,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le prénom est requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _FormField3D(
                controller: _lastNameController,
                label: 'Nom *',
                icon: Icons.badge,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le nom est requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _FormField3D(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              _FormField3D(
                controller: _phoneController,
                label: 'Téléphone',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              _DateField3D(
                label: 'Date de naissance',
                icon: Icons.cake,
                value: _birthDate,
                onTap: () => _selectDate(context, false),
              ),
              const SizedBox(height: 12),
              _FormField3D(
                controller: _idNumberController,
                label: 'Numéro d\'identité',
                icon: Icons.credit_card,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 24),

              // Informations professionnelles
              const Text(
                'Informations professionnelles',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _FormField3D(
                controller: _employeeNumberController,
                label: 'Numéro d\'employé',
                icon: Icons.numbers,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              _FormField3D(
                controller: _positionController,
                label: 'Poste',
                icon: Icons.work,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              _DateField3D(
                label: 'Date d\'embauche',
                icon: Icons.calendar_today,
                value: _hireDate,
                onTap: () => _selectDate(context, true),
              ),
              const SizedBox(height: 12),
              _FormField3D(
                controller: _hourlyRateController,
                label: 'Taux horaire (FCFA)',
                icon: Icons.currency_exchange,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 24),

              // Adresse
              const Text(
                'Adresse',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _FormField3D(
                controller: _addressController,
                label: 'Adresse',
                icon: Icons.location_on,
                maxLines: 2,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              _FormField3D(
                controller: _cityController,
                label: 'Ville',
                icon: Icons.location_city,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              _FormField3D(
                controller: _countryController,
                label: 'Pays',
                icon: Icons.public,
                textInputAction: TextInputAction.next,
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
              const SizedBox(height: 12),
              _Switch3D(
                title: 'Actif',
                subtitle: 'L\'employé est actif',
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
              const SizedBox(height: 24),
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
                    widget.employee == null ? 'CRÉER' : 'MODIFIER',
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

// Switch avec design 3D amélioré
class _Switch3D extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _Switch3D({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 1.1,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: const Color(0xFFB41839),
              activeTrackColor: const Color(0xFF3F1B3D),
            ),
          ),
        ],
      ),
    );
  }
}
