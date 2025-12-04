import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'report_provider.dart';

class GenerateReportScreen extends StatefulWidget {
  final int projectId;

  const GenerateReportScreen({super.key, required this.projectId});

  @override
  State<GenerateReportScreen> createState() => _GenerateReportScreenState();
}

class _GenerateReportScreenState extends State<GenerateReportScreen> {
  String _type = 'journalier';
  DateTime? _reportDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _reportDate = DateTime.now();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_reportDate ?? DateTime.now())
          : (_endDate ?? DateTime.now().add(const Duration(days: 7))),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _reportDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _generateReport() async {
    if (_reportDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une date'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_type == 'hebdomadaire' && _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une date de fin pour le rapport hebdomadaire'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final reportProvider =
        Provider.of<ReportProvider>(context, listen: false);

    final result = await reportProvider.generateReport(
      type: _type,
      reportDate: _reportDate!.toIso8601String().split('T')[0],
      endDate: _endDate?.toIso8601String().split('T')[0],
    );

    if (mounted) {
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rapport généré avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'Erreur lors de la génération',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Générer un rapport'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Type de rapport
            DropdownButtonFormField<String>(
              value: _type,
              decoration: const InputDecoration(
                labelText: 'Type de rapport *',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'journalier',
                  child: Text('Rapport Journalier'),
                ),
                DropdownMenuItem(
                  value: 'hebdomadaire',
                  child: Text('Rapport Hebdomadaire'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _type = value!;
                  if (_type == 'journalier') {
                    _endDate = null;
                  }
                });
              },
            ),
            const SizedBox(height: 24),

            // Date du rapport / Date de début
            InkWell(
              onTap: () => _selectDate(context, true),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: _type == 'journalier'
                      ? 'Date du rapport *'
                      : 'Date de début *',
                  border: const OutlineInputBorder(),
                ),
                child: Text(
                  _reportDate != null
                      ? '${_reportDate!.day}/${_reportDate!.month}/${_reportDate!.year}'
                      : 'Sélectionner une date',
                  style: TextStyle(
                    color: _reportDate != null ? Colors.black : Colors.grey[600],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Date de fin (pour rapport hebdomadaire)
            if (_type == 'hebdomadaire') ...[
              InkWell(
                onTap: () => _selectDate(context, false),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date de fin *',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _endDate != null
                        ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                        : 'Sélectionner une date',
                    style: TextStyle(
                      color: _endDate != null ? Colors.black : Colors.grey[600],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Informations
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha((255 * 0.1).round()),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'Le rapport inclura:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildInfoItem('Pointages et présences'),
                  _buildInfoItem('Mises à jour d\'avancement'),
                  _buildInfoItem('Dépenses'),
                  _buildInfoItem('Tâches et planning'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Bouton de génération
            Consumer<ReportProvider>(
              builder: (context, reportProvider, _) {
                return ElevatedButton(
                  onPressed: reportProvider.isLoading ? null : _generateReport,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFFB41839),
                    foregroundColor: Colors.white,
                  ),
                  child: reportProvider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'GÉNÉRER LE RAPPORT',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 14, color: Colors.blue[700]),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }
}

