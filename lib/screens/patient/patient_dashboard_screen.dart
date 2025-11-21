import 'package:dr_cardio/models/medical_note_model.dart';
import 'package:dr_cardio/models/patient_model.dart';
import 'package:dr_cardio/repositories/medical_note_repository.dart';
import 'package:dr_cardio/repositories/patient_repository.dart';
import 'package:dr_cardio/services/auth_service.dart';
import 'package:dr_cardio/services/unified_connectivity_service.dart';
import 'package:flutter/material.dart';
import 'package:dr_cardio/routes/app_routes.dart';
import 'package:dr_cardio/config/app_theme.dart';
import 'package:dr_cardio/widgets/animations/animated_widgets.dart';
import 'package:dr_cardio/widgets/navigation/shared_bottom_navigation.dart';
import 'package:dr_cardio/widgets/offline/offline_aware_widget.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';

class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  final PatientRepository _patientRepository = PatientRepository();
  final MedicalNoteRepository _medicalNoteRepository = MedicalNoteRepository();

  late Future<Patient?> _patientFuture;
  late Future<List<MedicalNote>> _medicalNotesFuture;
  late Stream<List<MedicalNote>> _medicalNotesStream;

  @override
  void initState() {
    super.initState();
    _loadData();
    _setupMedicalNotesStream();
  }

  void _loadData() {
    final patientId = AuthService().currentUserId ?? 'patient-001';
    _patientFuture = _patientRepository.getPatient(patientId);
    _medicalNotesFuture =
        _medicalNoteRepository.getMedicalNotesByPatient(patientId);
  }

  void _setupMedicalNotesStream() {
    final patientId = AuthService().currentUserId ?? 'patient-001';
    // Utiliser asBroadcastStream() pour permettre plusieurs listeners (StreamBuilders)
    _medicalNotesStream = _medicalNoteRepository
        .watchMedicalNotesByPatient(patientId)
        .asBroadcastStream();
  }

  void _refreshData() {
    setState(() {
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        title: const Text('DocteurCardio (Patient)'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.patientNotifications);
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: PulseAnimation(
                  duration: const Duration(seconds: 2),
                  minScale: 0.95,
                  maxScale: 1.05,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppTheme.secondaryRed,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: const Text(
                      '3', // TODO: Replace with dynamic notification count
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: 100,
            right: -50,
            child: Opacity(
              opacity: 0.05,
              child: Icon(
                Icons.favorite,
                size: 200,
                color: AppTheme.primaryBlue,
              ),
            ),
          ),
          Positioned(
            bottom: 150,
            left: -30,
            child: Opacity(
              opacity: 0.03,
              child: Icon(
                Icons.monitor_heart,
                size: 150,
                color: AppTheme.primaryBlue,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Salutation
                FadeInSlideUp(
                  delay: 0,
                  child: FutureBuilder<Patient?>(
                  future: _patientFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        '👋 Bonjour, ${snapshot.data!.firstName}',
                        style: Theme.of(context).textTheme.headlineMedium,
                      );
                    }
                    return Text(
                      '👋 Bonjour',
                      style: Theme.of(context).textTheme.headlineMedium,
                    );
                  },
                  ),
                ),
                const SizedBox(height: 4),
                FadeInSlideUp(
                  delay: 200,
                  child: FutureBuilder<List<MedicalNote>>(
                  future: _medicalNotesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      final lastNote = snapshot.data!.first;
                      final formattedDate = DateFormat('dd/MM/yyyy, HH:mm')
                          .format(lastNote.date);
                      return Text(
                        'Dernière mesure: $formattedDate',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      );
                    }
                    return Text(
                      'Aucune mesure enregistrée',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    );
                  },
                  ),
                ),
                const SizedBox(height: 20),

                // Carte dernière mesure
                FadeInSlideUp(
                  delay: 400,
                  child: StreamBuilder<List<MedicalNote>>(
                  stream: _medicalNotesStream,
                  builder: (context, snapshot) {
                    // Afficher le loader seulement si on n'a pas de données ET qu'on est en waiting
                    if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                      return Card(
                        child: Container(
                          height: 200,
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(),
                        ),
                      );
                    }
                    // Si on a des données, afficher la dernière mesure
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      return _LastMeasureCard(note: snapshot.data!.first);
                    }
                    // Sinon, afficher l'état vide
                    return const _LastMeasureCard(); // Show empty state
                  },
                  ),
                ),
                const SizedBox(height: 20),

                // Actions rapides
                FadeInSlideUp(
                  delay: 600,
                  child: _SectionHeader(title: '⚡ Actions rapides'),
                ),
                const SizedBox(height: 16),
                FadeInSlideUp(
                  delay: 800,
                  child: Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                        icon: Icons.camera_alt_outlined,
                        label: 'Photo\nTension',
                        onTap: () {
                          Navigator.pushNamed(
                              context, AppRoutes.recordPressurePhoto);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.edit_outlined,
                        label: 'Manuel\nSaisie',
                        onTap: () {
                          Navigator.pushNamed(
                              context, AppRoutes.recordPressureManual);
                        },
                      ),
                    ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Tendance
                FadeInSlideUp(
                  delay: 1000,
                  child: _SectionHeader(title: '📈 Tendance (7 jours)'),
                ),
                const SizedBox(height: 16),
                FadeInSlideUp(
                  delay: 1200,
                  child: StreamBuilder<List<MedicalNote>>(
                    stream: _medicalNotesStream,
                    builder: (context, snapshot) {
                      final notes = snapshot.data ?? [];
                      // Prendre les 7 dernières mesures
                      final last7Notes = notes.take(7).toList().reversed.toList();

                      return _AnimatedCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              if (last7Notes.isEmpty)
                                Container(
                                  height: 120,
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.show_chart, size: 40, color: Colors.grey.shade400),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Aucune mesure enregistrée',
                                        style: TextStyle(color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                _TrendMiniChart(notes: last7Notes),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  final patientId = AuthService().currentUserId;
                                  if (patientId != null) {
                                    Navigator.pushNamed(context, AppRoutes.patientHistory, arguments: {'patientId': patientId});
                                  }
                                },
                                child: const Text('📊 Voir l\'historique complet'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Messages
                FadeInSlideUp(
                  delay: 1400,
                  child: _MessagePreviewCard(),
                ),
                const SizedBox(height: 16),

                // Prochain RDV (Téléconsultation - nécessite connexion)
                FadeInSlideUp(
                  delay: 1600,
                  child: _TeleconsultationCard(),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const PatientBottomNav(currentIndex: 0),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFD6DFE8).withOpacity(0.5),
                const Color(0xFFD6DFE8),
                const Color(0xFFD6DFE8).withOpacity(0.5),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AnimatedCard extends StatelessWidget {
  final Widget child;

  const _AnimatedCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 300),
        tween: Tween<double>(begin: 0.98, end: 1.0),
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFFFFF), Color(0xFFF9FBFF)],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _LastMeasureCard extends StatelessWidget {
  final MedicalNote? note;

  const _LastMeasureCard({this.note});

  @override
  Widget build(BuildContext context) {
    final String systolic = note?.systolic.toString() ?? '-';
    final String diastolic = note?.diastolic.toString() ?? '-';
    final String heartRate = note?.heartRate.toString() ?? '-';
    final String date = note != null
        ? DateFormat('dd/MM/yyyy, HH:mm').format(note!.date)
        : 'N/A';

    return _AnimatedCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📊 DERNIÈRE MESURE',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  systolic,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                ),
                Text(
                  ' / ',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
                Text(
                  diastolic,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Systolique / Diastolique',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                '💓 $heartRate bpm',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF3DB9CE),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            if (note != null)
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.successGreen.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '🟢 Normal', // TODO: Implement logic for status
                    style: TextStyle(
                      color: AppTheme.successGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                date,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade500,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressableButton(
      onPressed: onTap,
      child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: const Color(0xFFE4E7EB).withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFFFFF), Color(0xFFF9FBFF)],
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    icon,
                    size: 36,
                    color: const Color(0xFF6C63FF),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}

class _TeleconsultationCard extends StatefulWidget {
  @override
  State<_TeleconsultationCard> createState() => _TeleconsultationCardState();
}

class _TeleconsultationCardState extends State<_TeleconsultationCard> {
  final UnifiedConnectivityService _connectivityService = UnifiedConnectivityService();
  late bool _isOnline;
  StreamSubscription<bool>? _subscription;

  @override
  void initState() {
    super.initState();
    _isOnline = _connectivityService.isOnline;
    _subscription = _connectivityService.connectionChange.listen((isOnline) {
      if (mounted) {
        setState(() {
          _isOnline = isOnline;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _showOfflineMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.white),
            SizedBox(width: 12),
            Text('Téléconsultation non disponible hors ligne'),
          ],
        ),
        backgroundColor: AppTheme.warningOrange,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _isOnline ? 1.0 : 0.4,
      child: _AnimatedCard(
        child: ListTile(
          leading: Icon(
            Icons.calendar_today_outlined,
            color: _isOnline ? null : Colors.grey,
          ),
          title: Row(
            children: [
              Text(
                'Prochain RDV: 05 Nov',
                style: TextStyle(
                  color: _isOnline ? null : Colors.grey,
                ),
              ),
              if (!_isOnline) ...[
                const SizedBox(width: 8),
                const Icon(Icons.wifi_off, size: 16, color: Colors.grey),
              ],
            ],
          ),
          subtitle: Text(
            'Téléconsultation 10h00',
            style: TextStyle(
              color: _isOnline ? null : Colors.grey,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: _isOnline
              ? () {
                  // Navigation vers la téléconsultation
                }
              : _showOfflineMessage,
        ),
      ),
    );
  }
}

class _MessagePreviewCard extends StatefulWidget {
  @override
  State<_MessagePreviewCard> createState() => _MessagePreviewCardState();
}

class _MessagePreviewCardState extends State<_MessagePreviewCard> {
  final UnifiedConnectivityService _connectivityService = UnifiedConnectivityService();
  late bool _isOnline;
  StreamSubscription<bool>? _subscription;

  @override
  void initState() {
    super.initState();
    _isOnline = _connectivityService.isOnline;
    _subscription = _connectivityService.connectionChange.listen((isOnline) {
      if (mounted) {
        setState(() {
          _isOnline = isOnline;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _showOfflineMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.white),
            SizedBox(width: 12),
            Text('Messages non disponible hors ligne'),
          ],
        ),
        backgroundColor: AppTheme.warningOrange,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _isOnline ? 1.0 : 0.4,
      child: _AnimatedCard(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color(0xFF31C48D).withOpacity(0.1),
            child: Icon(
              Icons.person,
              color: _isOnline ? const Color(0xFF31C48D) : Colors.grey,
            ),
          ),
          title: Row(
            children: [
              Text(
                '💬 Messages (2 nouveaux)',
                style: TextStyle(
                  color: _isOnline ? null : Colors.grey,
                ),
              ),
              if (!_isOnline) ...[
                const SizedBox(width: 8),
                const Icon(Icons.wifi_off, size: 16, color: Colors.grey),
              ],
            ],
          ),
          subtitle: Text(
            'Dr. Kouassi vous a écrit',
            style: TextStyle(
              color: _isOnline ? null : Colors.grey,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: _isOnline
              ? () => Navigator.pushNamed(context, AppRoutes.patientMessages)
              : _showOfflineMessage,
        ),
      ),
    );
  }
}

/// Mini graphique de tendance pour le dashboard
class _TrendMiniChart extends StatelessWidget {
  final List<MedicalNote> notes;

  const _TrendMiniChart({required this.notes});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Légende
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('Systolique', Colors.red),
            const SizedBox(width: 20),
            _buildLegendItem('Diastolique', AppTheme.primaryBlue),
          ],
        ),
        const SizedBox(height: 12),
        // Graphique
        SizedBox(
          height: 120,
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
                    reservedSize: 22,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < notes.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            DateFormat('dd/MM').format(notes[index].date),
                            style: TextStyle(
                              fontSize: 9,
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
                    reservedSize: 35,
                    interval: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                // Ligne Systolique (rouge)
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
                        radius: 3,
                        color: Colors.white,
                        strokeWidth: 2,
                        strokeColor: Colors.red,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.red.withOpacity(0.1),
                  ),
                ),
                // Ligne Diastolique (bleu)
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
                        radius: 3,
                        color: Colors.white,
                        strokeWidth: 2,
                        strokeColor: AppTheme.primaryBlue,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                  ),
                ),
              ],
              minY: 50,
              maxY: 180,
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (touchedSpot) => Colors.blueGrey.shade800,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final isSystolic = spot.barIndex == 0;
                      return LineTooltipItem(
                        '${isSystolic ? "Sys" : "Dia"}: ${spot.y.toInt()}',
                        TextStyle(
                          color: isSystolic ? Colors.red.shade200 : Colors.blue.shade200,
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
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}

