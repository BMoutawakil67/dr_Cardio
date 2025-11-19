import 'package:dr_cardio/models/medical_note_model.dart';
import 'package:dr_cardio/repositories/medical_note_repository.dart';
import 'package:dr_cardio/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:dr_cardio/config/app_theme.dart';
import 'package:dr_cardio/routes/app_routes.dart';

class PatientHistoryScreen extends StatefulWidget {
  const PatientHistoryScreen({super.key});

  @override
  State<PatientHistoryScreen> createState() => _PatientHistoryScreenState();
}

class _PatientHistoryScreenState extends State<PatientHistoryScreen> {
  final MedicalNoteRepository _medicalNoteRepository = MedicalNoteRepository();
  late Future<List<MedicalNote>> _medicalNotesFuture;
  String _selectedPeriod = '7J';
  String? _patientId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('patientId')) {
      _patientId = args['patientId'];
    } else {
      // Use logged in user ID as fallback
      _patientId = AuthService().currentUserId;
    }

    if (_patientId != null) {
      _medicalNotesFuture = _medicalNoteRepository.getMedicalNotesByPatient(_patientId!);
    } else {
      _medicalNotesFuture = Future.value([]);
    }
  }


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
            FutureBuilder<List<MedicalNote>>(
              future: _medicalNotesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _StatRow(label: 'Moyenne:', value: '-/-'),
                          const Divider(),
                          _StatRow(label: 'Min:', value: '-/-'),
                          const Divider(),
                          _StatRow(label: 'Max:', value: '-/-'),
                          const Divider(),
                          _StatRow(label: 'Mesures:', value: '0'),
                          const Divider(),
                          _StatRow(label: 'Tendance:', value: '-'),
                        ],
                      ),
                    ),
                  );
                }

                final notes = snapshot.data!;
                final systolicValues = notes.map((n) => n.systolic).toList();
                final diastolicValues = notes.map((n) => n.diastolic).toList();

                final avgSystolic =
                    (systolicValues.reduce((a, b) => a + b) / notes.length)
                        .round();
                final avgDiastolic =
                    (diastolicValues.reduce((a, b) => a + b) / notes.length)
                        .round();

                final minSystolic = systolicValues.reduce((a, b) => a < b ? a : b);
                final minDiastolic = diastolicValues.reduce((a, b) => a < b ? a : b);

                final maxSystolic = systolicValues.reduce((a, b) => a > b ? a : b);
                final maxDiastolic = diastolicValues.reduce((a, b) => a > b ? a : b);

                // Calculate trend (simple: compare first half vs second half)
                String trend = '-';
                if (notes.length >= 4) {
                  final halfIndex = notes.length ~/ 2;
                  final firstHalfAvg = notes
                          .sublist(0, halfIndex)
                          .map((n) => n.systolic)
                          .reduce((a, b) => a + b) /
                      halfIndex;
                  final secondHalfAvg = notes
                          .sublist(halfIndex)
                          .map((n) => n.systolic)
                          .reduce((a, b) => a + b) /
                      (notes.length - halfIndex);

                  if (secondHalfAvg < firstHalfAvg - 2) {
                    trend = '↓ En baisse';
                  } else if (secondHalfAvg > firstHalfAvg + 2) {
                    trend = '↑ En hausse';
                  } else {
                    trend = '→ Stable';
                  }
                }

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _StatRow(
                            label: 'Moyenne:',
                            value: '$avgSystolic/$avgDiastolic'),
                        const Divider(),
                        _StatRow(
                            label: 'Min:',
                            value: '$minSystolic/$minDiastolic'),
                        const Divider(),
                        _StatRow(
                            label: 'Max:',
                            value: '$maxSystolic/$maxDiastolic'),
                        const Divider(),
                        _StatRow(label: 'Mesures:', value: '${notes.length}'),
                        const Divider(),
                        _StatRow(label: 'Tendance:', value: trend),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Liste des mesures
            Text(
              '📋 Liste des mesures',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<MedicalNote>>(
              future: _medicalNotesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Erreur de chargement des notes médicales.'),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Aucune note médicale.'));
                }

                final notes = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return _MeasureCard(
                      date: '${note.date.day}/${note.date.month}/${note.date.year}',
                      systolic: note.systolic,
                      diastolic: note.diastolic,
                      pulse: note.heartRate,
                      status: 'Normal', // TODO: Implement status logic
                      statusColor: AppTheme.successGreen, // TODO: Implement color logic
                      context: note.context,
                    );
                  },
                );
              },
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