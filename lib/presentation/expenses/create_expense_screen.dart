import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'expense_provider.dart';
import '../materials/material_provider.dart';
import '../employees/employee_provider.dart';

class CreateExpenseScreen extends StatefulWidget {
  final int projectId;

  const CreateExpenseScreen({super.key, required this.projectId});

  @override
  State<CreateExpenseScreen> createState() => _CreateExpenseScreenState();
}

class _CreateExpenseScreenState extends State<CreateExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _supplierController = TextEditingController();
  final _invoiceNumberController = TextEditingController();
  final _notesController = TextEditingController();
  
  final ImagePicker _imagePicker = ImagePicker();
  
  String _type = 'materiaux';
  DateTime? _expenseDate;
  DateTime? _invoiceDate;
  DateTime? _paidDate;
  int? _selectedMaterialId;
  int? _selectedEmployeeId;
  bool _isPaid = false;
  File? _invoiceFile;

  final List<Map<String, String>> _expenseTypes = [
    {'value': 'materiaux', 'label': 'Matériaux'},
    {'value': 'transport', 'label': 'Transport'},
    {'value': 'main_oeuvre', 'label': 'Main-d\'œuvre'},
    {'value': 'location', 'label': 'Location machines'},
    {'value': 'autres', 'label': 'Autres'},
  ];

  @override
  void initState() {
    super.initState();
    _expenseDate = DateTime.now();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final materialProvider = Provider.of<MaterialProvider>(context, listen: false);
      final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
      
      if (materialProvider.materials.isEmpty) {
        materialProvider.loadMaterials();
      }
      if (employeeProvider.employees.isEmpty) {
        employeeProvider.loadEmployees();
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _supplierController.dispose();
    _invoiceNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }


  Future<void> _pickInvoiceFile() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _invoiceFile = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
          ),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _expenseDate == null) {
      return;
    }

    final expenseProvider =
        Provider.of<ExpenseProvider>(context, listen: false);

    // Construire les données en ne gardant que les valeurs non-null
    final data = <String, dynamic>{
      'type': _type,
      'title': _titleController.text.trim(),
      'amount': double.parse(_amountController.text.trim()),
      'expense_date': _expenseDate!.toIso8601String().split('T')[0],
      'is_paid': _isPaid,
    };

    // Ajouter les champs optionnels seulement s'ils ne sont pas vides
    if (_descriptionController.text.trim().isNotEmpty) {
      data['description'] = _descriptionController.text.trim();
    }
    if (_supplierController.text.trim().isNotEmpty) {
      data['supplier'] = _supplierController.text.trim();
    }
    if (_invoiceNumberController.text.trim().isNotEmpty) {
      data['invoice_number'] = _invoiceNumberController.text.trim();
    }
    if (_invoiceDate != null) {
      data['invoice_date'] = _invoiceDate!.toIso8601String().split('T')[0];
    }
    if (_type == 'materiaux' && _selectedMaterialId != null) {
      data['material_id'] = _selectedMaterialId;
    }
    if (_type == 'main_oeuvre' && _selectedEmployeeId != null) {
      data['employee_id'] = _selectedEmployeeId;
    }
    if (_notesController.text.trim().isNotEmpty) {
      data['notes'] = _notesController.text.trim();
    }
    if (_isPaid && _paidDate != null) {
      data['paid_date'] = _paidDate!.toIso8601String().split('T')[0];
    }

    final success = await expenseProvider.createExpense(
      projectId: widget.projectId,
      data: data,
      invoiceFile: _invoiceFile,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dépense créée avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else if (mounted) {
      final errorMessage = expenseProvider.errorMessage ?? 'Erreur lors de la création';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context, bool isExpenseDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isExpenseDate 
          ? (_expenseDate ?? DateTime.now())
          : (_invoiceDate ?? DateTime.now()),
      firstDate: DateTime(2000),
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
        if (isExpenseDate) {
          _expenseDate = picked;
        } else {
          _invoiceDate = picked;
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
          'Nouvelle dépense',
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
              // Type de dépense
              _DropdownField3D(
                value: _type,
                label: 'Type de dépense *',
                icon: Icons.category,
                items: _expenseTypes.map((type) {
                  return DropdownMenuItem(
                    value: type['value'],
                    child: Text(type['label']!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _type = value!;
                    _selectedMaterialId = null;
                    _selectedEmployeeId = null;
                  });
                },
              ),
              const SizedBox(height: 12),

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

              // Montant
              _FormField3D(
                controller: _amountController,
                label: 'Montant (FCFA) *',
                icon: Icons.currency_exchange,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le montant est requis';
                  }
                  if (double.tryParse(value.trim()) == null) {
                    return 'Montant invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Date de dépense
              _DateField3D(
                label: 'Date de dépense *',
                icon: Icons.calendar_today,
                value: _expenseDate,
                onTap: () => _selectDate(context, true),
              ),
              const SizedBox(height: 12),

              // Matériau (si type = matériaux)
              if (_type == 'materiaux') ...[
                Consumer<MaterialProvider>(
                  builder: (context, materialProvider, _) {
                    return _DropdownField3D(
                      value: _selectedMaterialId?.toString(),
                      label: 'Matériau',
                      icon: Icons.inventory_2,
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Aucun'),
                        ),
                        ...materialProvider.materials.map((material) {
                          return DropdownMenuItem(
                            value: material.id.toString(),
                            child: Text(material.name),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedMaterialId = value != null ? int.tryParse(value) : null;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],

              // Employé (si type = main-d'œuvre)
              if (_type == 'main_oeuvre') ...[
                Consumer<EmployeeProvider>(
                  builder: (context, employeeProvider, _) {
                    return _DropdownField3D(
                      value: _selectedEmployeeId?.toString(),
                      label: 'Employé',
                      icon: Icons.person,
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Aucun'),
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
                          _selectedEmployeeId = value != null ? int.tryParse(value) : null;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],

              // Fournisseur
              _FormField3D(
                controller: _supplierController,
                label: 'Fournisseur',
                icon: Icons.business,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),

              // Numéro de facture
              _FormField3D(
                controller: _invoiceNumberController,
                label: 'Numéro de facture',
                icon: Icons.numbers,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),

              // Date de facture
              _DateField3D(
                label: 'Date de facture',
                icon: Icons.event,
                value: _invoiceDate,
                onTap: () => _selectDate(context, false),
              ),
              const SizedBox(height: 12),

              // Fichier facture
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
                child: OutlinedButton.icon(
                  onPressed: _pickInvoiceFile,
                  icon: const Icon(Icons.attach_file),
                  label: Text(_invoiceFile != null
                      ? 'Facture sélectionnée'
                      : 'Joindre une facture'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              if (_invoiceFile != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[50],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.grey[300]!,
                              Colors.grey[400]!,
                            ],
                          ),
                        ),
                        child: const Icon(Icons.file_present, size: 16, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _invoiceFile!.path.split('/').last,
                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () {
                          setState(() {
                            _invoiceFile = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
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

              // Payé
              _Switch3D(
                title: 'Payée',
                subtitle: 'La dépense est payée',
                value: _isPaid,
                onChanged: (value) {
                  setState(() {
                    _isPaid = value;
                    if (value) {
                      _paidDate = DateTime.now();
                    }
                  });
                },
              ),
              const SizedBox(height: 24),

              // Bouton de soumission
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
                  child: const Text(
                    'CRÉER LA DÉPENSE',
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
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
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

