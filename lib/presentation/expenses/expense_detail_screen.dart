import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'expense_provider.dart';

class ExpenseDetailScreen extends StatefulWidget {
  final int expenseId;

  const ExpenseDetailScreen({super.key, required this.expenseId});

  @override
  State<ExpenseDetailScreen> createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends State<ExpenseDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExpenseProvider>(
        context,
        listen: false,
      ).loadExpense(widget.expenseId);
    });
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'materiaux':
        return Colors.blue;
      case 'transport':
        return Colors.orange;
      case 'main_oeuvre':
        return Colors.green;
      case 'location':
        return Colors.purple;
      case 'autres':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '-';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
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
          'Détails de la dépense',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, _) {
          if (expenseProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final expense = expenseProvider.selectedExpense;
          if (expense == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Dépense non trouvée',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB41839),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text(
                      'Retour',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          final typeColor = _getTypeColor(expense.type);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête avec titre et type
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
                                expense.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: typeColor.withAlpha((255 * 0.1).round()),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                expense.typeLabel,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: typeColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: expense.isPaid
                                    ? Colors.green.withAlpha(
                                        (255 * 0.1).round(),
                                      )
                                    : Colors.red.withAlpha((255 * 0.1).round()),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                expense.isPaid ? 'Payée' : 'Non payée',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: expense.isPaid
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${expense.amount.toStringAsFixed(0)} FCFA',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFB41839),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Informations générales
                _buildSectionTitle('Informations générales'),
                _buildInfoCard([
                  _buildInfoRow('Titre', expense.title),
                  _buildInfoRow('Type', expense.typeLabel),
                  _buildInfoRow(
                    'Montant',
                    '${expense.amount.toStringAsFixed(0)} FCFA',
                  ),
                  _buildInfoRow(
                    'Date de la dépense',
                    _formatDate(expense.expenseDate),
                  ),
                  _buildInfoRow(
                    'Statut',
                    expense.isPaid ? 'Payée' : 'Non payée',
                  ),
                  if (expense.isPaid && expense.paidDate != null)
                    _buildInfoRow(
                      'Date de paiement',
                      _formatDate(expense.paidDate),
                    ),
                ]),
                const SizedBox(height: 12),

                // Description
                if (expense.description != null) ...[
                  _buildSectionTitle('Description'),
                  _buildInfoCard([
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        expense.description!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                ],

                // Matériau ou Employé
                if (expense.material != null || expense.employee != null) ...[
                  _buildSectionTitle('Associations'),
                  _buildInfoCard([
                    if (expense.material != null)
                      _buildInfoRow('Matériau', expense.material!.name),
                    if (expense.employee != null)
                      _buildInfoRow('Employé', expense.employee!.fullName),
                  ]),
                  const SizedBox(height: 12),
                ],

                // Informations de facturation
                if (expense.supplier != null ||
                    expense.invoiceNumber != null ||
                    expense.invoiceDate != null) ...[
                  _buildSectionTitle('Informations de facturation'),
                  _buildInfoCard([
                    if (expense.supplier != null)
                      _buildInfoRow('Fournisseur', expense.supplier!),
                    if (expense.invoiceNumber != null)
                      _buildInfoRow(
                        'Numéro de facture',
                        expense.invoiceNumber!,
                      ),
                    if (expense.invoiceDate != null)
                      _buildInfoRow(
                        'Date de facture',
                        _formatDate(expense.invoiceDate),
                      ),
                  ]),
                  const SizedBox(height: 12),
                ],

                // Notes
                if (expense.notes != null) ...[
                  _buildSectionTitle('Notes'),
                  _buildInfoCard([
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        expense.notes!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                ],

                // Informations système
                _buildSectionTitle('Informations système'),
                _buildInfoCard([
                  if (expense.createdAt != null)
                    _buildInfoRow('Créée le', _formatDate(expense.createdAt)),
                  if (expense.updatedAt != null)
                    _buildInfoRow(
                      'Modifiée le',
                      _formatDate(expense.updatedAt),
                    ),
                  if (expense.creator != null)
                    _buildInfoRow(
                      'Créée par',
                      expense.creator!.name.isNotEmpty
                          ? expense.creator!.name
                          : expense.creator!.email,
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
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: children),
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
            width: 130,
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
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}




