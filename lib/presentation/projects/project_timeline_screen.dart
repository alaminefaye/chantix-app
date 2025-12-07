import 'package:flutter/material.dart';
import '../../data/repositories/progress_repository.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/repositories/comment_repository.dart';

class ProjectTimelineScreen extends StatefulWidget {
  final int projectId;

  const ProjectTimelineScreen({super.key, required this.projectId});

  @override
  State<ProjectTimelineScreen> createState() => _ProjectTimelineScreenState();
}

class _ProjectTimelineScreenState extends State<ProjectTimelineScreen> {
  final ProgressRepository _progressRepository = ProgressRepository();
  final TaskRepository _taskRepository = TaskRepository();
  final ExpenseRepository _expenseRepository = ExpenseRepository();
  final CommentRepository _commentRepository = CommentRepository();

  List<TimelineEvent> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTimeline();
  }

  Future<void> _loadTimeline() async {
    setState(() => _isLoading = true);

    try {
      final events = <TimelineEvent>[];

      // Charger les mises à jour d'avancement
      final progressUpdates = await _progressRepository.getProgressUpdates(
        widget.projectId,
      );
      for (final update in progressUpdates) {
        events.add(TimelineEvent(
          type: TimelineEventType.progress,
          date: update.createdAt ?? DateTime.now().toIso8601String(),
          title: 'Mise à jour d\'avancement',
          description: update.description ?? '${update.progress}% d\'avancement',
          user: update.user?.name ?? 'Utilisateur',
          data: update,
        ));
      }

      // Charger les tâches
      final tasks = await _taskRepository.getTasks(projectId: widget.projectId);
      for (final task in tasks) {
        events.add(TimelineEvent(
          type: TimelineEventType.task,
          date: task.createdAt ?? DateTime.now().toIso8601String(),
          title: 'Tâche créée: ${task.title}',
          description: task.description ?? '',
          user: task.creator?.name ?? 'Système',
          data: task,
        ));
      }

      // Charger les dépenses
      final expenses = await _expenseRepository.getExpenses(projectId: widget.projectId);
      for (final expense in expenses) {
        events.add(TimelineEvent(
          type: TimelineEventType.expense,
          date: expense.createdAt ?? DateTime.now().toIso8601String(),
          title: 'Dépense: ${expense.title}',
          description: '${expense.amount.toStringAsFixed(2)} FCFA',
          user: expense.creator?.name ?? 'Utilisateur',
          data: expense,
        ));
      }

      // Charger les commentaires
      final comments = await _commentRepository.getComments(projectId: widget.projectId);
      for (final comment in comments) {
        events.add(TimelineEvent(
          type: TimelineEventType.comment,
          date: comment.createdAt ?? DateTime.now().toIso8601String(),
          title: 'Commentaire',
          description: comment.content,
          user: comment.user?.name ?? 'Utilisateur',
          data: comment,
        ));
      }

      // Trier par date décroissante
      events.sort((a, b) => b.date.compareTo(a.date));

      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
                Color(0xFFB41839),
                Color(0xFF3F1B3D),
              ],
            ),
          ),
        ),
        title: const Text(
          'Timeline',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _events.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.timeline_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun événement dans la timeline',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadTimeline,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _events.length,
                    itemBuilder: (context, index) {
                      final event = _events[index];
                      return _buildTimelineItem(event, index);
                    },
                  ),
                ),
    );
  }

  Widget _buildTimelineItem(TimelineEvent event, int index) {
    final isLast = index == _events.length - 1;
    final icon = _getIconForType(event.type);
    final color = _getColorForType(event.type);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ligne verticale
        Column(
          children: [
            Container(
              width: 2,
              height: 20,
              color: Colors.grey[300],
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 100,
                color: Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      _formatDate(event.date),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (event.description.isNotEmpty)
                  Text(
                    event.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      event.user,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  IconData _getIconForType(TimelineEventType type) {
    switch (type) {
      case TimelineEventType.progress:
        return Icons.trending_up;
      case TimelineEventType.task:
        return Icons.task;
      case TimelineEventType.expense:
        return Icons.attach_money;
      case TimelineEventType.comment:
        return Icons.comment;
    }
  }

  Color _getColorForType(TimelineEventType type) {
    switch (type) {
      case TimelineEventType.progress:
        return Colors.blue;
      case TimelineEventType.task:
        return Colors.green;
      case TimelineEventType.expense:
        return Colors.orange;
      case TimelineEventType.comment:
        return Colors.purple;
    }
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

enum TimelineEventType {
  progress,
  task,
  expense,
  comment,
}

class TimelineEvent {
  final TimelineEventType type;
  final String date;
  final String title;
  final String description;
  final String user;
  final dynamic data;

  TimelineEvent({
    required this.type,
    required this.date,
    required this.title,
    required this.description,
    required this.user,
    required this.data,
  });
}

