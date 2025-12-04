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
      appBar: AppBar(
        title: Text(widget.material == null
            ? 'Nouveau matériau'
            : 'Modifier le matériau'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
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
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Catégorie',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _unitController.text.isEmpty ? null : _unitController.text,
                decoration: const InputDecoration(
                  labelText: 'Unité',
                  border: OutlineInputBorder(),
                ),
                items: _units.map((unit) {
                  return DropdownMenuItem(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    _unitController.text = value;
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _unitPriceController,
                decoration: const InputDecoration(
                  labelText: 'Prix unitaire (FCFA)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _supplierController,
                decoration: const InputDecoration(
                  labelText: 'Fournisseur',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _referenceController,
                decoration: const InputDecoration(
                  labelText: 'Référence',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stockQuantityController,
                decoration: const InputDecoration(
                  labelText: 'Stock actuel',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _minStockController,
                decoration: const InputDecoration(
                  labelText: 'Stock minimum',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Actif'),
                subtitle: const Text('Le matériau est actif'),
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
                  widget.material == null ? 'CRÉER' : 'MODIFIER',
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

