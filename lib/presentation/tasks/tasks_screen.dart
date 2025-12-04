import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'task_provider.dart';
import '../../data/models/task_model.dart';
import '../../data/models/project_model.dart';
import '../projects/project_provider.dart';
import 'create_task_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String _filter = 'all'; // all, a_faire, en_cours, termine, bloque, overdue

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      
      if (projectProvider.projects.isEmpty) {
        projectProvider.loadProjects();
      }
      
      taskProvider.loadTasks();
    });
  }

  List<TaskModel> _getFilteredTasks(List<TaskModel> tasks) {
    switch (_filter) {
      case 'a_faire':
        return tasks.where((t) => t.status == 'a_faire').toList();
      case 'en_cours':
        return tasks.where((t) => t.status == 'en_cours').toList();
      case 'termine':
        return tasks.where((t) => t.status == 'termine').toList();
      case 'bloque':
        return tasks.where((t) => t.status == 'bloque').toList();
      case 'overdue':
        return tasks.where((t) => t.isOverdue).toList();
      default:
        return tasks;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tâches'),
        actions: [
          Consumer<TaskProvider>(
            builder: (context, taskProvider, _) {
              if (taskProvider.selectedProjectId == null) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CreateTaskScreen(
                        projectId: taskProvider.selectedProjectId!,
                      ),
                    ),
                  ).then((_) {
                    taskProvider.loadTasks();
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
                return Consumer<TaskProvider>(
                  builder: (context, taskProvider, _) {
                    if (projectProvider.projects.isEmpty) {
                      return const Text('Aucun projet disponible');
                    }

                    return DropdownButtonFormField<ProjectModel>(
                      value: projectProvider.projects.firstWhere(
                        (p) => p.id == taskProvider.selectedProjectId,
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
                        taskProvider.setSelectedProject(project?.id);
                        taskProvider.loadTasks();
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
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Toutes', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('À faire', 'a_faire'),
                  const SizedBox(width: 8),
                  _buildFilterChip('En cours', 'en_cours'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Terminé', 'termine'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Bloqué', 'bloque'),
                  const SizedBox(width: 8),
                  _buildFilterChip('En retard', 'overdue'),
                ],
              ),
            ),
          ),

          // Liste
          Expanded(
            child: Consumer<TaskProvider>(
              builder: (context, taskProvider, _) {
                if (taskProvider.selectedProjectId == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.task, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Sélectionnez un projet pour voir les tâches',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (taskProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (taskProvider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          taskProvider.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            taskProvider.clearError();
                            taskProvider.loadTasks();
                          },
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }

                final filteredTasks = _getFilteredTasks(taskProvider.tasks);

                if (filteredTasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.task_alt, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text(
                          'Aucune tâche trouvée',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => taskProvider.loadTasks(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
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
                              color: task.statusColor.withAlpha((255 * 0.1).round()),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.task,
                              color: task.statusColor,
                            ),
                          ),
                          title: Text(
                            task.title,
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
                                      color: task.statusColor.withAlpha((255 * 0.1).round()),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      task.statusLabel,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: task.statusColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: task.priorityColor.withAlpha((255 * 0.1).round()),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      task.priorityLabel,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: task.priorityColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (task.deadline != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      task.isOverdue
                                          ? Icons.warning
                                          : task.isDueSoon
                                              ? Icons.schedule
                                              : Icons.calendar_today,
                                      size: 12,
                                      color: task.isOverdue
                                          ? Colors.red
                                          : task.isDueSoon
                                              ? Colors.orange
                                              : Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Échéance: ${_formatDate(task.deadline!)}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: task.isOverdue
                                            ? Colors.red
                                            : task.isDueSoon
                                                ? Colors.orange
                                                : Colors.grey[600],
                                        fontWeight: task.isOverdue || task.isDueSoon
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (task.assignedEmployee != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Assigné à: ${task.assignedEmployee!.fullName}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: task.progress / 100,
                                  minHeight: 6,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    task.statusColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${task.progress}%',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: Colors.grey[400],
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

  Widget _buildFilterChip(String label, String value) {
    return ChoiceChip(
      label: Text(label),
      selected: _filter == value,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _filter = value;
          });
        }
      },
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


