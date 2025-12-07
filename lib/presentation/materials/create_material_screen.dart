import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'material_provider.dart';
import '../../data/models/material_model.dart';

class CreateMaterialScreen extends StatefulWidget {
  final MaterialModel? material;

  const CreateMaterialScreen({super.key, this.material});

  @override
  State<CreateMaterialScreen> createState() => _CreateMaterialScreenState();
}

class _CreateMaterialScreenState extends State<CreateMaterialScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _unitController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _supplierController = TextEditingController();
  final _referenceController = TextEditingController();
  final _stockQuantityController = TextEditingController();
  final _minStockController = TextEditingController();
  bool _isActive = true;

  final List<String> _units = [
    'kg',
    'm',
    'm²',
    'm³',
    'L',
    'Pièce',
    'Unité',
    'Lot',
  ];

  final List<Map<String, String>> _categories = [
    {'value': 'ciment', 'label': 'Ciment'},
    {'value': 'acier', 'label': 'Acier'},
    {'value': 'bois', 'label': 'Bois'},
    {'value': 'electricite', 'label': 'Électricité'},
    {'value': 'plomberie', 'label': 'Plomberie'},
    {'value': 'peinture', 'label': 'Peinture'},
    {'value': 'autres', 'label': 'Autres'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.material != null) {
      final m = widget.material!;
      _nameController.text = m.name;
      _descriptionController.text = m.description ?? '';
      _categoryController.text = m.category ?? '';
      _unitController.text = m.unit ?? '';
      _unitPriceController.text = m.unitPrice?.toStringAsFixed(2) ?? '';
      _supplierController.text = m.supplier ?? '';
      _referenceController.text = m.reference ?? '';
      _stockQuantityController.text = m.stockQuantity?.toStringAsFixed(2) ?? '';
      _minStockController.text = m.minStock?.toStringAsFixed(2) ?? '';
      _isActive = m.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _unitController.dispose();
    _unitPriceController.dispose();
    _supplierController.dispose();
    _referenceController.dispose();
    _stockQuantityController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final materialProvider =
        Provider.of<MaterialProvider>(context, listen: false);

    final data = {
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      'category': _categoryController.text.trim().isEmpty
          ? null
          : _categoryController.text.trim(),
      'unit': _unitController.text.trim().isEmpty
          ? null
          : _unitController.text.trim(),
      'unit_price': _unitPriceController.text.trim().isEmpty
          ? null
          : double.tryParse(_unitPriceController.text.trim()),
      'supplier': _supplierController.text.trim().isEmpty
          ? null
          : _supplierController.text.trim(),
      'reference': _referenceController.text.trim().isEmpty
          ? null
          : _referenceController.text.trim(),
      'stock_quantity': _stockQuantityController.text.trim().isEmpty
          ? null
          : double.tryParse(_stockQuantityController.text.trim()),
      'min_stock': _minStockController.text.trim().isEmpty
          ? null
          : double.tryParse(_minStockController.text.trim()),
      'is_active': _isActive,
    };

    final success = widget.material == null
        ? await materialProvider.createMaterial(data)
        : await materialProvider.updateMaterial(widget.material!.id, data);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.material == null
              ? 'Matériau créé avec succès'
              : 'Matériau mis à jour avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            materialProvider.errorMessage ?? 'Erreur lors de l\'opération',
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
          widget.material == null
              ? 'Nouveau matériau'
              : 'Modifier le matériau',
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
              _FormField3D(
                controller: _nameController,
                label: 'Nom *',
                icon: Icons.label,
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
                controller: _descriptionController,
                label: 'Description',
                icon: Icons.description,
                maxLines: 3,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              _DropdownField3D(
                value: _categoryController.text.isEmpty ? null : _categoryController.text,
                label: 'Catégorie',
                icon: Icons.category,
                items: [
                  const DropdownMenuItem(value: null, child: Text('Sélectionner une catégorie')),
                  ..._categories.map((category) {
                    return DropdownMenuItem(
                      value: category['value'],
                      child: Text(category['label']!),
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
              _DropdownField3D(
                value: _unitController.text.isEmpty ? null : _unitController.text,
                label: 'Unité',
                icon: Icons.straighten,
                items: _units.map((unit) {
                  return DropdownMenuItem(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _unitController.text = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              _FormField3D(
                controller: _unitPriceController,
                label: 'Prix unitaire (FCFA)',
                icon: Icons.currency_exchange,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              _FormField3D(
                controller: _supplierController,
                label: 'Fournisseur',
                icon: Icons.business,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              _FormField3D(
                controller: _referenceController,
                label: 'Référence',
                icon: Icons.qr_code,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              _FormField3D(
                controller: _stockQuantityController,
                label: 'Stock actuel',
                icon: Icons.inventory,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              _FormField3D(
                controller: _minStockController,
                label: 'Stock minimum',
                icon: Icons.warning,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 12),
              _Switch3D(
                title: 'Actif',
                subtitle: 'Le matériau est actif',
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
                  child: Text(
                    widget.material == null ? 'CRÉER' : 'MODIFIER',
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
  final List<DropdownMenuItem<String>> items;
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
      child: DropdownButtonFormField<String>(
        value: widget.value,
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
        hint: widget.value == null ? Text(
          'Sélectionner une catégorie',
          style: TextStyle(color: Colors.grey[600]),
        ) : null,
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

