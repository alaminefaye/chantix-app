import 'package:flutter/material.dart';
import '../../data/models/project_material_model.dart';
import '../../data/repositories/project_material_repository.dart';
import 'add_project_material_screen.dart';
import 'edit_project_material_screen.dart';

class ProjectMaterialsTab extends StatefulWidget {
  final int projectId;

  const ProjectMaterialsTab({super.key, required this.projectId});

  @override
  State<ProjectMaterialsTab> createState() => _ProjectMaterialsTabState();
}

class _ProjectMaterialsTabState extends State<ProjectMaterialsTab> {
  final ProjectMaterialRepository _repository = ProjectMaterialRepository();
  List<ProjectMaterialModel> _materials = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  Future<void> _loadMaterials() async {
    setState(() => _isLoading = true);
    final materials = await _repository.getProjectMaterials(widget.projectId);
    setState(() {
      _materials = materials;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadMaterials,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Matériaux du projet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AddProjectMaterialScreen(
                          projectId: widget.projectId,
                        ),
                      ),
                    );
                    if (result == true) {
                      _loadMaterials();
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB41839),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _materials.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucun matériau associé à ce projet',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Appuyez sur "Ajouter" pour en ajouter',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _materials.length,
                        itemBuilder: (context, index) {
                          final projectMaterial = _materials[index];
                          return _MaterialCard(
                            projectMaterial: projectMaterial,
                            onEdit: () async {
                              final result = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => EditProjectMaterialScreen(
                                    projectId: widget.projectId,
                                    projectMaterial: projectMaterial,
                                  ),
                                ),
                              );
                              if (result == true) {
                                _loadMaterials();
                              }
                            },
                            onDelete: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Confirmer la suppression'),
                                  content: Text(
                                    'Voulez-vous retirer "${projectMaterial.material.name}" du projet ?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Annuler'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      child: const Text('Supprimer'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                final success = await _repository
                                    .removeMaterialFromProject(
                                  widget.projectId,
                                  projectMaterial.material.id,
                                );
                                if (success && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Matériau retiré du projet'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  _loadMaterials();
                                } else if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Erreur lors de la suppression'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _MaterialCard extends StatelessWidget {
  final ProjectMaterialModel projectMaterial;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MaterialCard({
    required this.projectMaterial,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final material = projectMaterial.material;
    final isOverConsumption = projectMaterial.isOverConsumption;
    final isLowRemaining = projectMaterial.quantityRemaining <
        (projectMaterial.quantityPlanned * 0.1);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        material.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (material.category != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            material.category!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Modifier'),
                        ],
                      ),
                      onTap: () => Future.delayed(
                        const Duration(milliseconds: 100),
                        onEdit,
                      ),
                    ),
                    PopupMenuItem(
                      child: const Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Supprimer', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                      onTap: () => Future.delayed(
                        const Duration(milliseconds: 100),
                        onDelete,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _QuantityInfo(
                    label: 'Prévu',
                    value: projectMaterial.quantityPlanned,
                    unit: material.unit ?? 'unité',
                  ),
                ),
                Expanded(
                  child: _QuantityInfo(
                    label: 'Commandé',
                    value: projectMaterial.quantityOrdered,
                    unit: material.unit ?? 'unité',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuantityInfo(
                    label: 'Livré',
                    value: projectMaterial.quantityDelivered,
                    unit: material.unit ?? 'unité',
                  ),
                ),
                Expanded(
                  child: _QuantityInfo(
                    label: 'Utilisé',
                    value: projectMaterial.quantityUsed,
                    unit: material.unit ?? 'unité',
                    isWarning: isOverConsumption,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _QuantityInfo(
              label: 'Restant',
              value: projectMaterial.quantityRemaining,
              unit: material.unit ?? 'unité',
              isWarning: isLowRemaining,
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
          ],
        ),
      ),
    );
  }
}

class _QuantityInfo extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final bool isWarning;

  const _QuantityInfo({
    required this.label,
    required this.value,
    required this.unit,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${value.toStringAsFixed(2)} $unit',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isWarning ? Colors.red : Colors.black,
          ),
        ),
      ],
    );
  }
}

