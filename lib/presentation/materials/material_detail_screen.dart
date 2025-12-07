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
          'Détails du matériau',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Consumer<MaterialProvider>(
            builder: (context, materialProvider, _) {
              final material = materialProvider.selectedMaterial;
              if (material == null) return const SizedBox.shrink();

              return IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
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
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                material.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (material.isLowStock)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withAlpha((255 * 0.1).round()),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Stock faible',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (material.category != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Catégorie: ${material.category}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

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
                const SizedBox(height: 12),

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
                const SizedBox(height: 12),

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
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

