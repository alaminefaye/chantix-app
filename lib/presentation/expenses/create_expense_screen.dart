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

  Future<void> _selectDate(BuildContext context, bool isExpenseDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isExpenseDate 
          ? (_expenseDate ?? DateTime.now())
          : (_invoiceDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
        ),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _expenseDate == null) {
      return;
    }

    final expenseProvider =
        Provider.of<ExpenseProvider>(context, listen: false);

    final data = {
      'type': _type,
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      'amount': double.parse(_amountController.text.trim()),
      'expense_date': _expenseDate!.toIso8601String().split('T')[0],
      'supplier': _supplierController.text.trim().isEmpty
          ? null
          : _supplierController.text.trim(),
      'invoice_number': _invoiceNumberController.text.trim().isEmpty
          ? null
          : _invoiceNumberController.text.trim(),
      'invoice_date': _invoiceDate?.toIso8601String().split('T')[0],
      'material_id': _type == 'materiaux' ? _selectedMaterialId : null,
      'employee_id': _type == 'main_oeuvre' ? _selectedEmployeeId : null,
      'notes': _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      'is_paid': _isPaid,
      'paid_date': _isPaid && _paidDate != null
          ? _paidDate!.toIso8601String().split('T')[0]
          : null,
    };

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            expenseProvider.errorMessage ?? 'Erreur lors de la création',
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
        title: const Text('Nouvelle dépense'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Type de dépense
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(
                  labelText: 'Type de dépense *',
                  border: OutlineInputBorder(),
                ),
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
              const SizedBox(height: 16),

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

              // Montant
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Montant (FCFA) *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
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
              const SizedBox(height: 16),

              // Date de dépense
              InkWell(
                onTap: () => _selectDate(context, true),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date de dépense *',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _expenseDate != null
                        ? '${_expenseDate!.day}/${_expenseDate!.month}/${_expenseDate!.year}'
                        : 'Sélectionner une date',
                    style: TextStyle(
                      color: _expenseDate != null ? Colors.black : Colors.grey[600],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Matériau (si type = matériaux)
              if (_type == 'materiaux') ...[
                Consumer<MaterialProvider>(
                  builder: (context, materialProvider, _) {
                    return DropdownButtonFormField<int?>(
                      value: _selectedMaterialId,
                      decoration: const InputDecoration(
                        labelText: 'Matériau',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Aucun'),
                        ),
                        ...materialProvider.materials.map((material) {
                          return DropdownMenuItem(
                            value: material.id,
                            child: Text(material.name),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedMaterialId = value;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Employé (si type = main-d'œuvre)
              if (_type == 'main_oeuvre') ...[
                Consumer<EmployeeProvider>(
                  builder: (context, employeeProvider, _) {
                    return DropdownButtonFormField<int?>(
                      value: _selectedEmployeeId,
                      decoration: const InputDecoration(
                        labelText: 'Employé',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Aucun'),
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
              ],

              // Fournisseur
              TextFormField(
                controller: _supplierController,
                decoration: const InputDecoration(
                  labelText: 'Fournisseur',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Numéro de facture
              TextFormField(
                controller: _invoiceNumberController,
                decoration: const InputDecoration(
                  labelText: 'Numéro de facture',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Date de facture
              InkWell(
                onTap: () => _selectDate(context, false),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date de facture',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _invoiceDate != null
                        ? '${_invoiceDate!.day}/${_invoiceDate!.month}/${_invoiceDate!.year}'
                        : 'Sélectionner une date',
                    style: TextStyle(
                      color: _invoiceDate != null ? Colors.black : Colors.grey[600],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Fichier facture
              OutlinedButton.icon(
                onPressed: _pickInvoiceFile,
                icon: const Icon(Icons.attach_file),
                label: Text(_invoiceFile != null
                    ? 'Facture sélectionnée'
                    : 'Joindre une facture'),
              ),
              if (_invoiceFile != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.file_present, size: 16),
                    const SizedBox(width: 8),
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
              ],
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
              const SizedBox(height: 16),

              // Payé
              SwitchListTile(
                title: const Text('Payée'),
                subtitle: const Text('La dépense est payée'),
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
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFFB41839),
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'CRÉER LA DÉPENSE',
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

