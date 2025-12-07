import 'package:flutter/material.dart';
import '../../data/models/project_material_model.dart';
import '../../data/repositories/project_material_repository.dart';

class EditProjectMaterialScreen extends StatefulWidget {
  final int projectId;
  final ProjectMaterialModel projectMaterial;

  const EditProjectMaterialScreen({
    super.key,
    required this.projectId,
    required this.projectMaterial,
  });

  @override
  State<EditProjectMaterialScreen> createState() =>
      _EditProjectMaterialScreenState();
}

class _EditProjectMaterialScreenState
    extends State<EditProjectMaterialScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityOrderedController = TextEditingController();
  final _quantityDeliveredController = TextEditingController();
  final _quantityUsedController = TextEditingController();
  final _notesController = TextEditingController();
  final ProjectMaterialRepository _repository = ProjectMaterialRepository();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _quantityOrderedController.text =
        widget.projectMaterial.quantityOrdered.toStringAsFixed(2);
    _quantityDeliveredController.text =
        widget.projectMaterial.quantityDelivered.toStringAsFixed(2);
    _quantityUsedController.text =
        widget.projectMaterial.quantityUsed.toStringAsFixed(2);
    _notesController.text = widget.projectMaterial.notes ?? '';
  }

  @override
  void dispose() {
    _quantityOrderedController.dispose();
    _quantityDeliveredController.dispose();
    _quantityUsedController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    final result = await _repository.updateProjectMaterial(
      projectId: widget.projectId,
      materialId: widget.projectMaterial.material.id,
      quantityOrdered: double.tryParse(_quantityOrderedController.text.trim()),
      quantityDelivered:
          double.tryParse(_quantityDeliveredController.text.trim()),
      quantityUsed: double.tryParse(_quantityUsedController.text.trim()),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    setState(() => _isSubmitting = false);

    if (result['success'] == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Matériau mis à jour avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Erreur lors de la mise à jour'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final material = widget.projectMaterial.material;
    final isOverConsumption = widget.projectMaterial.isOverConsumption;

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
        title: Text(
          'Modifier: ${material.name}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
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
                      Text(
                        'Quantité prévue: ${widget.projectMaterial.quantityPlanned.toStringAsFixed(2)} ${material.unit ?? 'unité'}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _quantityOrderedController,
                        decoration: InputDecoration(
                          labelText: 'Quantité commandée',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.shopping_cart),
                          suffixText: material.unit ?? 'unité',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            final quantity = double.tryParse(value.trim());
                            if (quantity == null || quantity < 0) {
                              return 'Veuillez entrer une quantité valide';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _quantityDeliveredController,
                        decoration: InputDecoration(
                          labelText: 'Quantité livrée',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.local_shipping),
                          suffixText: material.unit ?? 'unité',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            final quantity = double.tryParse(value.trim());
                            if (quantity == null || quantity < 0) {
                              return 'Veuillez entrer une quantité valide';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _quantityUsedController,
                        decoration: InputDecoration(
                          labelText: 'Quantité utilisée',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isOverConsumption
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.construction,
                            color: isOverConsumption ? Colors.red : null,
                          ),
                          suffixText: material.unit ?? 'unité',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            final quantity = double.tryParse(value.trim());
                            if (quantity == null || quantity < 0) {
                              return 'Veuillez entrer une quantité valide';
                            }
                          }
                          return null;
                        },
                      ),
                      if (isOverConsumption) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red[300]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.warning, color: Colors.red[700], size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Surconsommation détectée',
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                          'MODIFIER',
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

