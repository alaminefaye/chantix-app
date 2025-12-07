import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/progress_update_model.dart';
import '../progress/progress_provider.dart';
import '../progress/create_progress_update_screen.dart';
import '../progress/progress_update_detail_screen.dart';

class ProjectProgressUpdatesScreen extends StatefulWidget {
  final int projectId;

  const ProjectProgressUpdatesScreen({super.key, required this.projectId});

  @override
  State<ProjectProgressUpdatesScreen> createState() =>
      _ProjectProgressUpdatesScreenState();
}

class _ProjectProgressUpdatesScreenState
    extends State<ProjectProgressUpdatesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProgressProvider>(context, listen: false)
          .loadProgressUpdates(widget.projectId);
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
                Color(0xFFB41839),
                Color(0xFF3F1B3D),
              ],
            ),
          ),
        ),
        title: const Text(
          'Mises à jour',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CreateProgressUpdateScreen(
                    projectId: widget.projectId,
                  ),
                ),
              );
              if (result == true && mounted) {
                Provider.of<ProgressProvider>(context, listen: false)
                    .loadProgressUpdates(widget.projectId);
              }
            },
          ),
        ],
      ),
      body: Consumer<ProgressProvider>(
        builder: (context, progressProvider, _) {
          if (progressProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (progressProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    progressProvider.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      progressProvider.loadProgressUpdates(widget.projectId);
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final updates = progressProvider.progressUpdates;

          if (updates.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.update_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune mise à jour',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                progressProvider.loadProgressUpdates(widget.projectId),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: updates.length,
              itemBuilder: (context, index) {
                final update = updates[index];
                return _buildUpdateCard(update);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildUpdateCard(ProgressUpdateModel update) {
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFB41839),
                Color(0xFF3F1B3D),
              ],
            ),
          ),
          child: Text(
            '${update.progress}%',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        title: Text(
          update.description ?? 'Mise à jour d\'avancement',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (update.user != null) ...[
              const SizedBox(height: 4),
              Text(
                'Par ${update.user!.name}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
            if (update.createdAt != null) ...[
              const SizedBox(height: 4),
              Text(
                _formatDate(update.createdAt!),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProgressUpdateDetailScreen(
                update: update,
                projectId: widget.projectId,
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}

