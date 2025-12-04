import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'expense_provider.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/project_model.dart';
import '../projects/project_provider.dart';
import 'create_expense_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  String _filter = 'all'; // all, paid, unpaid

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
      final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
      
      if (projectProvider.projects.isEmpty) {
        projectProvider.loadProjects();
      }
      
      expenseProvider.loadExpenses();
    });
  }

  List<ExpenseModel> _getFilteredExpenses(List<ExpenseModel> expenses) {
    switch (_filter) {
      case 'paid':
        return expenses.where((e) => e.isPaid).toList();
      case 'unpaid':
        return expenses.where((e) => !e.isPaid).toList();
      default:
        return expenses;
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dépenses'),
        actions: [
          Consumer<ExpenseProvider>(
            builder: (context, expenseProvider, _) {
              if (expenseProvider.selectedProjectId == null) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CreateExpenseScreen(
                        projectId: expenseProvider.selectedProjectId!,
                      ),
                    ),
                  ).then((_) {
                    expenseProvider.loadExpenses();
                  });
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Sélection du projet
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFB41839).withAlpha((255 * 0.1).round()),
                  const Color(0xFF3F1B3D).withAlpha((255 * 0.1).round()),
                ],
              ),
            ),
            child: Consumer<ProjectProvider>(
              builder: (context, projectProvider, _) {
                return Consumer<ExpenseProvider>(
                  builder: (context, expenseProvider, _) {
                    if (projectProvider.projects.isEmpty) {
                      return const Text('Aucun projet disponible');
                    }

                    return DropdownButtonFormField<ProjectModel>(
                      value: projectProvider.projects.firstWhere(
                        (p) => p.id == expenseProvider.selectedProjectId,
                        orElse: () => projectProvider.projects.first,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Sélectionner un projet',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: projectProvider.projects.map((project) {
                        return DropdownMenuItem<ProjectModel>(
                          value: project,
                          child: Text(project.name),
                        );
                      }).toList(),
                      onChanged: (project) {
                        expenseProvider.setSelectedProject(project?.id);
                        expenseProvider.loadExpenses();
                      },
                    );
                  },
                );
              },
            ),
          ),

          // Filtres
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Toutes'),
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
                    label: const Text('Payées'),
                    selected: _filter == 'paid',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _filter = 'paid';
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Non payées'),
                    selected: _filter == 'unpaid',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _filter = 'unpaid';
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
            child: Consumer<ExpenseProvider>(
              builder: (context, expenseProvider, _) {
                if (expenseProvider.selectedProjectId == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Sélectionnez un projet pour voir les dépenses',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (expenseProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (expenseProvider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          expenseProvider.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            expenseProvider.clearError();
                            expenseProvider.loadExpenses();
                          },
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }

                final filteredExpenses =
                    _getFilteredExpenses(expenseProvider.expenses);

                if (filteredExpenses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text(
                          'Aucune dépense trouvée',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => expenseProvider.loadExpenses(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredExpenses.length,
                    itemBuilder: (context, index) {
                      final expense = filteredExpenses[index];
                      final typeColor = _getTypeColor(expense.type);
                      
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
                              color: typeColor.withAlpha((255 * 0.1).round()),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.receipt,
                              color: typeColor,
                            ),
                          ),
                          title: Text(
                            expense.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: typeColor.withAlpha((255 * 0.1).round()),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      expense.typeLabel,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: typeColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (expense.isPaid)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withAlpha((255 * 0.1).round()),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'Payée',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(expense.expenseDate),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${expense.amount.toStringAsFixed(0)} FCFA',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFB41839),
                                ),
                              ),
                              if (expense.supplier != null)
                                Text(
                                  expense.supplier!,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[500],
                                  ),
                                ),
                            ],
                          ),
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}


