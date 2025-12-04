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

  Future<void> _selectDate(BuildContext context, bool isHireDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isHireDate ? (_hireDate ?? DateTime.now()) : (_birthDate ?? DateTime(1990)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final employeeProvider =
        Provider.of<EmployeeProvider>(context, listen: false);

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
          content: Text(widget.employee == null
              ? 'Employé créé avec succès'
              : 'Employé mis à jour avec succès'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.employee == null
            ? 'Nouvel employé'
            : 'Modifier l\'employé'),
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
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'Prénom *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le prénom est requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le nom est requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context, false),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date de naissance',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _birthDate != null
                        ? '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}'
                        : 'Sélectionner une date',
                    style: TextStyle(
                      color: _birthDate != null ? Colors.black : Colors.grey[600],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _idNumberController,
                decoration: const InputDecoration(
                  labelText: 'Numéro d\'identité',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // Informations professionnelles
              const Text(
                'Informations professionnelles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _employeeNumberController,
                decoration: const InputDecoration(
                  labelText: 'Numéro d\'employé',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _positionController,
                decoration: const InputDecoration(
                  labelText: 'Poste',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context, true),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date d\'embauche',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _hireDate != null
                        ? '${_hireDate!.day}/${_hireDate!.month}/${_hireDate!.year}'
                        : 'Sélectionner une date',
                    style: TextStyle(
                      color: _hireDate != null ? Colors.black : Colors.grey[600],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _hourlyRateController,
                decoration: const InputDecoration(
                  labelText: 'Taux horaire (FCFA)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),

              // Adresse
              const Text(
                'Adresse',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Adresse',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'Ville',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _countryController,
                decoration: const InputDecoration(
                  labelText: 'Pays',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Actif'),
                subtitle: const Text('L\'employé est actif'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFFB41839),
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  widget.employee == null ? 'CRÉER' : 'MODIFIER',
                  style: const TextStyle(
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

