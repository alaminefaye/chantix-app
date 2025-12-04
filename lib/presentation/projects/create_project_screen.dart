import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'project_provider.dart';
import 'projects_screen.dart';

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _clientNameController = TextEditingController();
  final _clientContactController = TextEditingController();
  final _budgetController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  
  String _selectedStatus = 'non_demarre';

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _clientNameController.dispose();
    _clientContactController.dispose();
    _budgetController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
      
      final data = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'address': _addressController.text.trim(),
        'client_name': _clientNameController.text.trim(),
        'client_contact': _clientContactController.text.trim(),
        'budget': double.tryParse(_budgetController.text) ?? 0,
        'status': _selectedStatus,
        'start_date': _startDateController.text.isNotEmpty ? _startDateController.text : null,
        'end_date': _endDateController.text.isNotEmpty ? _endDateController.text : null,
      };

      final success = await projectProvider.createProject(data);

      if (mounted) {
        if (success) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const ProjectsScreen()),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Projet créé avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                projectProvider.errorMessage ?? 'Erreur lors de la création',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau Projet'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du projet *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nom du projet';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Adresse',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _clientNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du client',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _clientContactController,
                decoration: const InputDecoration(
                  labelText: 'Contact client',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _budgetController,
                decoration: const InputDecoration(
                  labelText: 'Budget (FCFA) *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le budget';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Statut *',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'non_demarre', child: Text('Non démarré')),
                  DropdownMenuItem(value: 'en_cours', child: Text('En cours')),
                  DropdownMenuItem(value: 'termine', child: Text('Terminé')),
                  DropdownMenuItem(value: 'bloque', child: Text('Bloqué')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _startDateController,
                decoration: const InputDecoration(
                  labelText: 'Date de début',
                  border: OutlineInputBorder(),
                  hintText: 'YYYY-MM-DD',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _endDateController,
                decoration: const InputDecoration(
                  labelText: 'Date de fin',
                  border: OutlineInputBorder(),
                  hintText: 'YYYY-MM-DD',
                ),
              ),
              const SizedBox(height: 32),
              Consumer<ProjectProvider>(
                builder: (context, projectProvider, _) {
                  return ElevatedButton(
                    onPressed: projectProvider.isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: projectProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Créer le projet',
                            style: TextStyle(fontSize: 16),
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

