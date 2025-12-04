import 'package:flutter/material.dart';
import '../materials/materials_screen.dart';
import '../employees/employees_screen.dart';
import '../expenses/expenses_screen.dart';
import '../tasks/tasks_screen.dart';
import '../comments/comments_screen.dart';
import '../reports/reports_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plus'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Gestion'),
          _buildMenuItem(
            context,
            icon: Icons.inventory_2,
            title: 'Matériaux',
            subtitle: 'Gérer le catalogue et les stocks',
            color: Colors.blue,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const MaterialsScreen(),
                ),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.people,
            title: 'Employés',
            subtitle: 'Gérer les employés et équipes',
            color: Colors.green,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const EmployeesScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Financier'),
          _buildMenuItem(
            context,
            icon: Icons.attach_money,
            title: 'Dépenses',
            subtitle: 'Suivre les dépenses par projet',
            color: Colors.orange,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ExpensesScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Organisation'),
          _buildMenuItem(
            context,
            icon: Icons.task,
            title: 'Tâches',
            subtitle: 'Gérer les tâches et le planning',
            color: Colors.purple,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const TasksScreen(),
                ),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.comment,
            title: 'Commentaires',
            subtitle: 'Discussions et échanges',
            color: Colors.teal,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CommentsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Rapports'),
          _buildMenuItem(
            context,
            icon: Icons.description,
            title: 'Rapports',
            subtitle: 'Générer et consulter les rapports',
            color: Colors.indigo,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ReportsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withAlpha((255 * 0.1).round()),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey[400],
        ),
        onTap: onTap,
      ),
    );
  }
}

