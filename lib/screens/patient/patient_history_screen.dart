import 'package:flutter/material.dart';
import 'package:dr_cardio/config/app_theme.dart';
import 'package:dr_cardio/routes/app_routes.dart';

class PatientHistoryScreen extends StatefulWidget {
  const PatientHistoryScreen({super.key});

  @override
  State<PatientHistoryScreen> createState() => _PatientHistoryScreenState();
}

class _PatientHistoryScreenState extends State<PatientHistoryScreen> {
  String _selectedPeriod = '7J';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Recherche
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Paramètres d'export
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filtres de période
            Text(
              'Filtrer par période:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['7J', '1M', '3M', '6M', '1An'].map((period) {
                  final isSelected = _selectedPeriod == period;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(period),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedPeriod = period;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Graphique
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📊 GRAPHIQUE',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 200,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('[Graphique interactif]'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _LegendItem(
                          color: AppTheme.primaryBlue,
                          label: 'Systolique',
                        ),
                        const SizedBox(width: 16),
                        _LegendItem(
                          color: AppTheme.secondaryRed,
                          label: 'Diastolique',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Statistiques
            Text(
              '📈 Statistiques',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _StatRow(label: 'Moyenne:', value: '14/9'),
                    const Divider(),
                    _StatRow(label: 'Min:', value: '12/8'),
                    const Divider(),
                    _StatRow(label: 'Max:', value: '16/10'),
                    const Divider(),
                    _StatRow(label: 'Mesures:', value: '24'),
                    const Divider(),
                    _StatRow(label: 'Tendance:', value: '↘ Stable'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Liste des mesures
            Text(
              '📋 Liste des mesures',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),

            _MeasureCard(
              date: '27 Oct, 18:30',
              systolic: 14,
              diastolic: 9,
              pulse: 72,
              status: 'Normal',
              statusColor: AppTheme.successGreen,
              context: '💊 Losartan pris',
            ),
            const SizedBox(height: 12),
            _MeasureCard(
              date: '27 Oct, 08:15',
              systolic: 13,
              diastolic: 8,
              pulse: 68,
              status: 'Normal',
              statusColor: AppTheme.successGreen,
            ),
            const SizedBox(height: 12),
            _MeasureCard(
              date: '26 Oct, 19:00',
              systolic: 16,
              diastolic: 10,
              pulse: 80,
              status: 'Légèrement élevée',
              statusColor: AppTheme.warningOrange,
              warning: '⚠️ Légèrement élevée',
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 4,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _MeasureCard extends StatelessWidget {
  final String date;
  final int systolic;
  final int diastolic;
  final int pulse;
  final String status;
  final Color statusColor;
  final String? context;
  final String? warning;

  const _MeasureCard({
    required this.date,
    required this.systolic,
    required this.diastolic,
    required this.pulse,
    required this.status,
    required this.statusColor,
    this.context,
    this.warning,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '$systolic / $diastolic',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(width: 16),
                Text(
                  '💓 $pulse bpm',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            if (this.context != null) ...[
              const SizedBox(height: 8),
              Text(
                this.context!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (warning != null) ...[
              const SizedBox(height: 8),
              Text(
                warning!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.measureDetail,
                    arguments: {
                      'date': date,
                      'systolic': systolic,
                      'diastolic': diastolic,
                      'pulse': pulse,
                      'status': status,
                      'context': this.context,
                    },
                  );
                },
                child: const Text('Détails >'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
