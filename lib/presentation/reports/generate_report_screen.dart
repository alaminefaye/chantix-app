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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFB41839), // Couleur principale
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
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
          'Générer un rapport',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Type de rapport
            _DropdownField3D(
              value: _type,
              label: 'Type de rapport *',
              icon: Icons.assessment,
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
            const SizedBox(height: 12),

            // Date du rapport / Date de début
            _DateField3D(
              label: _type == 'journalier'
                  ? 'Date du rapport *'
                  : 'Date de début *',
              icon: Icons.calendar_today,
              value: _reportDate,
              onTap: () => _selectDate(context, true),
            ),
            const SizedBox(height: 12),

            // Date de fin (pour rapport hebdomadaire)
            if (_type == 'hebdomadaire') ...[
              _DateField3D(
                label: 'Date de fin *',
                icon: Icons.event,
                value: _endDate,
                onTap: () => _selectDate(context, false),
              ),
              const SizedBox(height: 12),
            ],

            // Informations
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue[50]!,
                    Colors.blue[100]!,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF2196F3),
                              Color(0xFF1976D2),
                            ],
                          ),
                        ),
                        child: const Icon(Icons.info_outline, size: 16, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Le rapport inclura:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
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
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFB41839),
                        Color(0xFF3F1B3D),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFB41839).withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: reportProvider.isLoading ? null : _generateReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
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
                              color: Colors.white,
                            ),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF4CAF50),
                  Color(0xFF388E3C),
                ],
              ),
            ),
            child: const Icon(Icons.check, size: 12, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.blue[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Dropdown avec design 3D amélioré
class _DropdownField3D extends StatefulWidget {
  final String? value;
  final String label;
  final List<DropdownMenuItem<String>> items;
  final Function(String?)? onChanged;
  final IconData icon;

  const _DropdownField3D({
    this.value,
    required this.label,
    required this.items,
    required this.onChanged,
    required this.icon,
  });

  @override
  State<_DropdownField3D> createState() => _DropdownField3DState();
}

class _DropdownField3DState extends State<_DropdownField3D> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _isFocused 
                ? const Color(0xFFB41839).withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: _isFocused ? 15 : 10,
            offset: const Offset(0, 4),
            spreadRadius: _isFocused ? 1 : 0,
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        initialValue: widget.value,
        decoration: InputDecoration(
          labelText: widget.label,
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: _isFocused
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFB41839),
                        Color(0xFF3F1B3D),
                      ],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey[300]!,
                        Colors.grey[400]!,
                      ],
                    ),
              boxShadow: [
                BoxShadow(
                  color: _isFocused
                      ? const Color(0xFFB41839).withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              widget.icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFB41839),
              width: 2,
            ),
          ),
          labelStyle: TextStyle(
            color: _isFocused ? const Color(0xFFB41839) : Colors.grey[600],
            fontWeight: _isFocused ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        items: widget.items,
        onChanged: (value) {
          setState(() => _isFocused = false);
          widget.onChanged?.call(value);
        },
        onTap: () => setState(() => _isFocused = true),
      ),
    );
  }
}

// Champ de date avec design 3D et calendrier
class _DateField3D extends StatefulWidget {
  final String label;
  final IconData icon;
  final DateTime? value;
  final VoidCallback onTap;

  const _DateField3D({
    required this.label,
    required this.icon,
    required this.value,
    required this.onTap,
  });

  @override
  State<_DateField3D> createState() => _DateField3DState();
}

class _DateField3DState extends State<_DateField3D> {
  bool _isFocused = false;

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => _isFocused = true);
        widget.onTap();
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            setState(() => _isFocused = false);
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _isFocused 
                  ? const Color(0xFFB41839).withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.06),
              blurRadius: _isFocused ? 15 : 10,
              offset: const Offset(0, 4),
              spreadRadius: _isFocused ? 1 : 0,
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            border: Border.all(
              color: _isFocused 
                  ? const Color(0xFFB41839)
                  : Colors.grey[300]!,
              width: _isFocused ? 2 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: _isFocused
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFB41839),
                            Color(0xFF3F1B3D),
                          ],
                        )
                      : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.grey[300]!,
                            Colors.grey[400]!,
                          ],
                        ),
                  boxShadow: [
                    BoxShadow(
                      color: _isFocused
                          ? const Color(0xFFB41839).withValues(alpha: 0.3)
                          : Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  widget.icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 12,
                        color: _isFocused 
                            ? const Color(0xFFB41839)
                            : Colors.grey[600],
                        fontWeight: _isFocused 
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.value != null 
                          ? _formatDate(widget.value)
                          : 'Sélectionner une date',
                      style: TextStyle(
                        fontSize: 16,
                        color: widget.value != null 
                            ? Colors.black87
                            : Colors.grey[400],
                        fontWeight: widget.value != null 
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.calendar_month,
                color: Colors.grey[400],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

