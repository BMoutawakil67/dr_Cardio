import 'package:dr_cardio/models/medical_note_model.dart';
import 'package:dr_cardio/repositories/medical_note_repository.dart';
import 'package:dr_cardio/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:dr_cardio/config/app_theme.dart';
import 'package:dr_cardio/routes/app_routes.dart';
import 'package:dr_cardio/widgets/navigation/shared_bottom_navigation.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class PatientHistoryScreen extends StatefulWidget {
  const PatientHistoryScreen({super.key});

  @override
  State<PatientHistoryScreen> createState() => _PatientHistoryScreenState();
}

class _PatientHistoryScreenState extends State<PatientHistoryScreen> {
  final MedicalNoteRepository _medicalNoteRepository = MedicalNoteRepository();
  Stream<List<MedicalNote>>? _medicalNotesStream;
  String _selectedPeriod = '7J';
  String? _patientId;
  bool _isInitialized = false;
  int _streamKey = 0; // Clé pour forcer la recréation du stream

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // N'initialiser qu'une seule fois
    if (_isInitialized) return;
    _isInitialized = true;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('patientId')) {
      _patientId = args['patientId'];
    } else {
      // Use logged in user ID as fallback
      _patientId = AuthService().currentUserId;
    }

    _initStream();
  }

  void _initStream() {
    if (_patientId != null) {
      _medicalNotesStream = _medicalNoteRepository
          .watchMedicalNotesByPatient(_patientId!)
          .asBroadcastStream();
    }
  }

  void _refreshStream() {
    setState(() {
      _streamKey++;
      _initStream();
    });
  }

  List<MedicalNote> _filterNotesByPeriod(List<MedicalNote> notes) {
    final now = DateTime.now();
    DateTime startDate;

    switch (_selectedPeriod) {
      case '7J':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case '1M':
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case '3M':
        startDate = DateTime(now.year, now.month - 3, now.day);
        break;
      case '6M':
        startDate = DateTime(now.year, now.month - 6, now.day);
        break;
      case '1An':
        startDate = DateTime(now.year - 1, now.month, now.day);
        break;
      default:
        startDate = now.subtract(const Duration(days: 7));
    }

    return notes.where((note) => note.date.isAfter(startDate)).toList();
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
                    StreamBuilder<List<MedicalNote>>(
                      stream: _medicalNotesStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                          return Container(
                            height: 200,
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator(),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Container(
                            height: 200,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.show_chart, size: 48, color: Colors.grey.shade400),
                                const SizedBox(height: 8),
                                Text(
                                  'Aucune mesure enregistrée',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          );
                        }

                        final notes = _filterNotesByPeriod(snapshot.data!);
                        return _HistoryChart(notes: notes.reversed.toList());
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _LegendItem(
                          color: Colors.red,
                          label: 'Systolique',
                        ),
                        const SizedBox(width: 16),
                        _LegendItem(
                          color: AppTheme.primaryBlue,
                          label: 'Diastolique',
                        ),
                        const SizedBox(width: 16),
                        _LegendItem(
                          color: const Color(0xFF3DB9CE),
                          label: 'Pouls',
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
            StreamBuilder<List<MedicalNote>>(
              stream: _medicalNotesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
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
            StreamBuilder<List<MedicalNote>>(
              stream: _medicalNotesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
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
                      noteId: note.id,
                      doctorId: note.doctorId,
                      date: '${note.date.day}/${note.date.month}/${note.date.year}',
                      systolic: note.systolic,
                      diastolic: note.diastolic,
                      pulse: note.heartRate,
                      status: 'Normal', // TODO: Implement status logic
                      statusColor: AppTheme.successGreen, // TODO: Implement color logic
                      context: note.context,
                      onRefresh: _refreshStream,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const PatientBottomNav(currentIndex: 1),
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

/// Graphique complet pour l'historique des mesures
class _HistoryChart extends StatelessWidget {
  final List<MedicalNote> notes;

  const _HistoryChart({required this.notes});

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Text('Aucune donnée', style: TextStyle(color: Colors.grey.shade600)),
      );
    }

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 20,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.shade200,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: notes.length > 10 ? (notes.length / 5).ceilToDouble() : 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < notes.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        DateFormat('dd/MM').format(notes[index].date),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: 30,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
              left: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          lineBarsData: [
            // Systolique (rouge)
            LineChartBarData(
              spots: notes.asMap().entries.map((e) =>
                FlSpot(e.key.toDouble(), e.value.systolic.toDouble())
              ).toList(),
              isCurved: true,
              curveSmoothness: 0.3,
              color: Colors.red,
              barWidth: 2.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: Colors.red,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.red.withOpacity(0.08),
              ),
            ),
            // Diastolique (bleu)
            LineChartBarData(
              spots: notes.asMap().entries.map((e) =>
                FlSpot(e.key.toDouble(), e.value.diastolic.toDouble())
              ).toList(),
              isCurved: true,
              curveSmoothness: 0.3,
              color: AppTheme.primaryBlue,
              barWidth: 2.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: AppTheme.primaryBlue,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.primaryBlue.withOpacity(0.08),
              ),
            ),
            // Pouls (cyan)
            LineChartBarData(
              spots: notes.asMap().entries.map((e) =>
                FlSpot(e.key.toDouble(), e.value.heartRate.toDouble())
              ).toList(),
              isCurved: true,
              curveSmoothness: 0.3,
              color: const Color(0xFF3DB9CE),
              barWidth: 2,
              dashArray: [5, 3],
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: Colors.white,
                    strokeWidth: 1.5,
                    strokeColor: const Color(0xFF3DB9CE),
                  );
                },
              ),
            ),
          ],
          minY: 40,
          maxY: 200,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => Colors.blueGrey.shade800,
              tooltipRoundedRadius: 8,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  String label;
                  Color color;
                  switch (spot.barIndex) {
                    case 0:
                      label = 'Sys';
                      color = Colors.red.shade200;
                      break;
                    case 1:
                      label = 'Dia';
                      color = Colors.blue.shade200;
                      break;
                    case 2:
                      label = 'Pouls';
                      color = Colors.cyan.shade200;
                      break;
                    default:
                      label = '';
                      color = Colors.white;
                  }
                  return LineTooltipItem(
                    '$label: ${spot.y.toInt()}',
                    TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _MeasureCard extends StatelessWidget {
  final String noteId;
  final String doctorId;
  final String date;
  final int systolic;
  final int diastolic;
  final int pulse;
  final String status;
  final Color statusColor;
  final String? context;
  final String? warning;
  final VoidCallback? onRefresh;

  const _MeasureCard({
    required this.noteId,
    required this.doctorId,
    required this.date,
    required this.systolic,
    required this.diastolic,
    required this.pulse,
    required this.status,
    required this.statusColor,
    this.context,
    this.warning,
    this.onRefresh,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.patientMessages,
                      arguments: {
                        'doctorId': doctorId,
                        'measureReference': {
                          'noteId': noteId,
                          'date': date,
                          'systolic': systolic,
                          'diastolic': diastolic,
                          'pulse': pulse,
                        },
                      },
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: const Text('Discuter'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.measureDetail,
                      arguments: {
                        'noteId': noteId,
                        'date': date,
                        'systolic': systolic,
                        'diastolic': diastolic,
                        'pulse': pulse,
                        'status': status,
                        'context': this.context,
                      },
                    ).then((_) {
                      if (onRefresh != null) onRefresh!();
                    });
                  },
                  child: const Text('Détails >'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}