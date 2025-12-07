import 'package:flutter/material.dart';
import '../../data/models/material_model.dart';
import '../../data/repositories/material_repository.dart';
import '../../data/repositories/project_material_repository.dart';

class AddProjectMaterialScreen extends StatefulWidget {
  final int projectId;

  const AddProjectMaterialScreen({super.key, required this.projectId});

  @override
  State<AddProjectMaterialScreen> createState() =>
      _AddProjectMaterialScreenState();
}

class _AddProjectMaterialScreenState extends State<AddProjectMaterialScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  final MaterialRepository _materialRepository = MaterialRepository();
  final ProjectMaterialRepository _projectMaterialRepository =
      ProjectMaterialRepository();

  List<MaterialModel> _materials = [];
  MaterialModel? _selectedMaterial;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadMaterials() async {
    setState(() => _isLoading = true);
    final materials = await _materialRepository.getMaterials();
    setState(() {
      _materials = materials.where((m) => m.isActive).toList();
      _isLoading = false;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedMaterial == null) {
      if (_selectedMaterial == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner un matériau'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _isSubmitting = true);

    final result = await _projectMaterialRepository.addMaterialToProject(
      projectId: widget.projectId,
      materialId: _selectedMaterial!.id,
      quantityPlanned: double.parse(_quantityController.text.trim()),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    setState(() => _isSubmitting = false);

    if (result['success'] == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Matériau ajouté au projet avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Erreur lors de l\'ajout'),
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
              colors: [Color(0xFFB41839), Color(0xFF3F1B3D)],
            ),
          ),
        ),
        title: const Text(
          'Ajouter un matériau',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                            const Text(
                              'Sélectionner un matériau',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<MaterialModel>(
                              value: _selectedMaterial,
                              isDense: false,
                              isExpanded: true,
                              menuMaxHeight: 300,
                              decoration: InputDecoration(
                                labelText: 'Matériau *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.inventory),
                              ),
                              items: _materials.map((material) {
                                return DropdownMenuItem(
                                  value: material,
                                  child: SizedBox(
                                    height: 48,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        material.category != null
                                            ? '${material.name} (${material.category})'
                                            : material.name,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                              selectedItemBuilder: (context) {
                                return _materials.map((material) {
                                  return Text(
                                    material.category != null
                                        ? '${material.name} (${material.category})'
                                        : material.name,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  );
                                }).toList();
                              },
                              onChanged: (value) {
                                setState(() {
                                  _selectedMaterial = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Veuillez sélectionner un matériau';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
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
                            TextFormField(
                              controller: _quantityController,
                              decoration: InputDecoration(
                                labelText: 'Quantité prévue *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.numbers),
                                suffixText: _selectedMaterial?.unit ?? 'unité',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'La quantité est requise';
                                }
                                final quantity = double.tryParse(value.trim());
                                if (quantity == null || quantity < 0) {
                                  return 'Veuillez entrer une quantité valide';
                                }
                                return null;
                              },
                            ),
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
                          colors: [Color(0xFFB41839), Color(0xFF3F1B3D)],
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'AJOUTER',
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
