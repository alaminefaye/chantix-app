import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'material_provider.dart';
import 'create_material_screen.dart';

class MaterialDetailScreen extends StatefulWidget {
  final int materialId;

  const MaterialDetailScreen({super.key, required this.materialId});

  @override
  State<MaterialDetailScreen> createState() => _MaterialDetailScreenState();
}

class _MaterialDetailScreenState extends State<MaterialDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MaterialProvider>(context, listen: false)
          .loadMaterial(widget.materialId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du matériau'),
        actions: [
          Consumer<MaterialProvider>(
            builder: (context, materialProvider, _) {
              final material = materialProvider.selectedMaterial;
              if (material == null) return const SizedBox.shrink();

              return IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CreateMaterialScreen(
                        material: material,
                      ),
                    ),
                  ).then((_) {
                    materialProvider.loadMaterial(widget.materialId);
                  });
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<MaterialProvider>(
        builder: (context, materialProvider, _) {
          if (materialProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final material = materialProvider.selectedMaterial;
          if (material == null) {
            return const Center(
              child: Text('Matériau non trouvé'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                material.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (material.isLowStock)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withAlpha((255 * 0.1).round()),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Stock faible',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (material.category != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Catégorie: ${material.category}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Informations générales
                _buildSectionTitle('Informations générales'),
                _buildInfoCard([
                  _buildInfoRow('Nom', material.name),
                  if (material.description != null)
                    _buildInfoRow('Description', material.description!),
                  if (material.reference != null)
                    _buildInfoRow('Référence', material.reference!),
                  if (material.supplier != null)
                    _buildInfoRow('Fournisseur', material.supplier!),
                ]),
                const SizedBox(height: 16),

                // Stock et prix
                _buildSectionTitle('Stock et prix'),
                _buildInfoCard([
                  _buildInfoRow(
                    'Stock actuel',
                    '${material.stockQuantity?.toStringAsFixed(2) ?? 'N/A'} ${material.unit ?? 'unité'}',
                  ),
                  if (material.minStock != null)
                    _buildInfoRow(
                      'Stock minimum',
                      '${material.minStock!.toStringAsFixed(2)} ${material.unit ?? 'unité'}',
                    ),
                  if (material.unitPrice != null)
                    _buildInfoRow(
                      'Prix unitaire',
                      '${material.unitPrice!.toStringAsFixed(2)} FCFA/${material.unit ?? 'unité'}',
                    ),
                  if (material.unit != null)
                    _buildInfoRow('Unité', material.unit!),
                ]),
                const SizedBox(height: 16),

                // Statut
                _buildSectionTitle('Statut'),
                _buildInfoCard([
                  _buildInfoRow(
                    'Statut',
                    material.isActive ? 'Actif' : 'Inactif',
                  ),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

