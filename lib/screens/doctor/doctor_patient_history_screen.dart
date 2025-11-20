import 'package:flutter/material.dart';
import 'package:dr_cardio/config/app_theme.dart';
import 'package:dr_cardio/routes/app_routes.dart';

class DoctorPatientHistoryScreen extends StatefulWidget {
  const DoctorPatientHistoryScreen({super.key});

  @override
  State<DoctorPatientHistoryScreen> createState() =>
      _DoctorPatientHistoryScreenState();
}

class _DoctorPatientHistoryScreenState
    extends State<DoctorPatientHistoryScreen> {
  String _selectedPeriod = '30j';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique complet'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildChart(),
                  _buildMeasureList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: '7j', label: Text('7j')),
              ButtonSegment(value: '30j', label: Text('30j')),
              ButtonSegment(value: '90j', label: Text('90j')),
            ],
            selected: {_selectedPeriod},
            onSelectionChanged: (newSelection) {
              setState(() {
                _selectedPeriod = newSelection.first;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text('Graphique de l\'historique'),
      ),
    );
  }

  Widget _buildMeasureList() {
    final measures = List.generate(
        15,
        (index) => {
              'date': 'Aujourd\'hui',
              'time': '${18 - index}:00',
              'systole': 120 + index,
              'diastole': 80 + (index % 5),
              'pulse': 70 + index,
            });

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: measures.length,
      itemBuilder: (context, index) {
        final measure = measures[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getMeasureColor(
                          measure['systole'] as int,
                          measure['diastole'] as int,
                        ).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.favorite,
                        color: _getMeasureColor(
                          measure['systole'] as int,
                          measure['diastole'] as int,
                        ),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${measure['systole']}/${measure['diastole']} mmHg',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Pouls: ${measure['pulse']} bpm',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          measure['date'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          measure['time'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _respondToMeasure(context, measure),
                      icon: const Icon(Icons.message, size: 18),
                      label: const Text('Répondre'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => _viewMeasureDetails(context, measure),
                      icon: const Icon(Icons.info_outline, size: 18),
                      label: const Text('Détails'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryBlue,
                        side: const BorderSide(color: AppTheme.primaryBlue),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getMeasureColor(int systole, int diastole) {
    // Hypotension (basse)
    if (systole < 90 || diastole < 60) {
      return AppTheme.warningOrange;
    }
    // Hypertension (élevée)
    if (systole >= 140 || diastole >= 90) {
      return AppTheme.errorRed;
    }
    // Préhypertension
    if (systole >= 130 || diastole >= 85) {
      return AppTheme.warningOrange;
    }
    // Normal
    return AppTheme.successGreen;
  }

  void _respondToMeasure(BuildContext context, Map<String, dynamic> measure) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.message, color: AppTheme.primaryBlue),
            SizedBox(width: 12),
            Text('Répondre à la mesure'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.favorite,
                        color: _getMeasureColor(
                          measure['systole'] as int,
                          measure['diastole'] as int,
                        ),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${measure['systole']}/${measure['diastole']} mmHg',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pouls: ${measure['pulse']} bpm',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${measure['date']} à ${measure['time']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Voulez-vous envoyer un message au patient concernant cette mesure ?',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Redirect to chat screen
              Navigator.pushNamed(
                context,
                AppRoutes.doctorChat,
                arguments: {
                  'preFillMessage':
                      'Concernant votre mesure de ${measure['systole']}/${measure['diastole']} mmHg du ${measure['date']} à ${measure['time']}: ',
                },
              );
            },
            icon: const Icon(Icons.send),
            label: const Text('Envoyer un message'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  void _viewMeasureDetails(BuildContext context, Map<String, dynamic> measure) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: AppTheme.primaryBlue),
            SizedBox(width: 12),
            Text('Détails de la mesure'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
              'Systolique',
              '${measure['systole']} mmHg',
              _getMeasureColor(
                measure['systole'] as int,
                measure['diastole'] as int,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              'Diastolique',
              '${measure['diastole']} mmHg',
              _getMeasureColor(
                measure['systole'] as int,
                measure['diastole'] as int,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Pouls', '${measure['pulse']} bpm', AppTheme.primaryBlue),
            const SizedBox(height: 12),
            _buildDetailRow('Date', measure['date'] as String, AppTheme.greyMedium),
            const SizedBox(height: 12),
            _buildDetailRow('Heure', measure['time'] as String, AppTheme.greyMedium),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getMeasureColor(
                  measure['systole'] as int,
                  measure['diastole'] as int,
                ).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getMeasureColor(
                    measure['systole'] as int,
                    measure['diastole'] as int,
                  ).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getMeasureStatusIcon(
                      measure['systole'] as int,
                      measure['diastole'] as int,
                    ),
                    color: _getMeasureColor(
                      measure['systole'] as int,
                      measure['diastole'] as int,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _getMeasureStatus(
                        measure['systole'] as int,
                        measure['diastole'] as int,
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _getMeasureColor(
                          measure['systole'] as int,
                          measure['diastole'] as int,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Fermer'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(dialogContext);
              _respondToMeasure(context, measure);
            },
            icon: const Icon(Icons.message),
            label: const Text('Répondre'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  IconData _getMeasureStatusIcon(int systole, int diastole) {
    if (systole < 90 || diastole < 60) {
      return Icons.arrow_downward;
    }
    if (systole >= 140 || diastole >= 90) {
      return Icons.warning;
    }
    if (systole >= 130 || diastole >= 85) {
      return Icons.info;
    }
    return Icons.check_circle;
  }

  String _getMeasureStatus(int systole, int diastole) {
    if (systole < 90 || diastole < 60) {
      return 'Hypotension - Tension basse';
    }
    if (systole >= 140 || diastole >= 90) {
      return 'Hypertension - Tension élevée';
    }
    if (systole >= 130 || diastole >= 85) {
      return 'Préhypertension - Attention';
    }
    return 'Tension normale';
  }
}
