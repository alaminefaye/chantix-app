import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'material_provider.dart';
import '../../data/models/material_model.dart';
import 'create_material_screen.dart';
import 'material_detail_screen.dart';

class MaterialsScreen extends StatefulWidget {
  const MaterialsScreen({super.key});

  @override
  State<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends State<MaterialsScreen> {
  String _filter = 'all'; // all, active, low_stock

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MaterialProvider>(context, listen: false).loadMaterials();
    });
  }

  List<MaterialModel> _getFilteredMaterials(List<MaterialModel> materials) {
    switch (_filter) {
      case 'active':
        return materials.where((m) => m.isActive).toList();
      case 'low_stock':
        return materials.where((m) => m.isLowStock).toList();
      default:
        return materials;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matériaux'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CreateMaterialScreen(),
                ),
              ).then((_) {
                Provider.of<MaterialProvider>(context, listen: false)
                    .loadMaterials();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtres
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Tous'),
                    selected: _filter == 'all',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _filter = 'all';
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Actifs'),
                    selected: _filter == 'active',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _filter = 'active';
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Stock faible'),
                    selected: _filter == 'low_stock',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _filter = 'low_stock';
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          // Liste
          Expanded(
            child: Consumer<MaterialProvider>(
              builder: (context, materialProvider, _) {
                if (materialProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (materialProvider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          materialProvider.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            materialProvider.clearError();
                            materialProvider.loadMaterials();
                          },
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }

                final filteredMaterials =
                    _getFilteredMaterials(materialProvider.materials);

                if (filteredMaterials.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.inventory_2,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'Aucun matériau trouvé',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const CreateMaterialScreen(),
                              ),
                            );
                          },
                          child: const Text('Créer un matériau'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => materialProvider.loadMaterials(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredMaterials.length,
                    itemBuilder: (context, index) {
                      final material = filteredMaterials[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: material.isLowStock
                                  ? Colors.red.withAlpha((255 * 0.1).round())
                                  : Colors.blue.withAlpha((255 * 0.1).round()),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.inventory_2,
                              color: material.isLowStock
                                  ? Colors.red
                                  : Colors.blue,
                            ),
                          ),
                          title: Text(
                            material.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (material.category != null)
                                Text(
                                  'Catégorie: ${material.category}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    'Stock: ${material.stockQuantity?.toStringAsFixed(2) ?? 'N/A'} ${material.unit ?? ''}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  if (material.unitPrice != null) ...[
                                    const Text(' • ',
                                        style: TextStyle(color: Colors.grey)),
                                    Text(
                                      '${material.unitPrice!.toStringAsFixed(2)} FCFA/${material.unit ?? 'unité'}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (material.isLowStock)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withAlpha(
                                          (255 * 0.1).round()),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Stock faible',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: Colors.grey[400],
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MaterialDetailScreen(
                                  materialId: material.id,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


