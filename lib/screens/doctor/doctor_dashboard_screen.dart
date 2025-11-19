import 'package:dr_cardio/models/doctor_model.dart';
import 'package:dr_cardio/models/medical_note_model.dart';
import 'package:dr_cardio/models/patient_model.dart';
import 'package:dr_cardio/repositories/doctor_repository.dart';
import 'package:dr_cardio/repositories/medical_note_repository.dart';
import 'package:dr_cardio/repositories/patient_repository.dart';
import 'package:flutter/material.dart';
import 'package:dr_cardio/routes/app_routes.dart';
import 'package:dr_cardio/config/app_theme.dart';
import 'package:dr_cardio/widgets/navigation/shared_bottom_navigation.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  final DoctorRepository _doctorRepository = DoctorRepository();
  final PatientRepository _patientRepository = PatientRepository();
  final MedicalNoteRepository _medicalNoteRepository = MedicalNoteRepository();

  late Future<Doctor?> _doctorFuture;
  late Future<List<Patient>> _patientsFuture;
  late Future<List<MedicalNote>> _allNotesFuture;

  @override
  void initState() {
    super.initState();
    // TODO: Replace with actual doctor ID from auth
    _doctorFuture = _doctorRepository.getDoctor('doctor-001');
    _patientsFuture = _patientRepository.getAllPatients();
    _allNotesFuture = _medicalNoteRepository.getAllMedicalNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        title: const Text('DocteurCardio'),
        actions: [
          FutureBuilder<List<MedicalNote>>(
            future: _allNotesFuture,
            builder: (context, snapshot) {
              final allNotes = snapshot.data ?? [];
              final alertCount = allNotes.where((note) {
                final isRecent = DateTime.now().difference(note.date).inDays <= 7;
                final isHigh = note.systolic >= 16 || note.diastolic >= 10;
                return isRecent && isHigh;
              }).length;

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {},
                  ),
                  if (alertCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
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
                        child: Text(
                          alertCount > 9 ? '9+' : alertCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Salutation
            FutureBuilder<Doctor?>(
              future: _doctorFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return Text(
                    '👨‍⚕️ Bonjour Dr.',
                    style: Theme.of(context).textTheme.headlineMedium,
                  );
                }
                final doctor = snapshot.data!;
                return Text(
                  '👨‍⚕️ Bonjour Dr. ${doctor.lastName}',
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              },
            ),
            const SizedBox(height: 24),

            // Vue d'ensemble
            Text(
              '📊 Vue d\'ensemble',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<dynamic>>(
              future: Future.wait([_patientsFuture, _allNotesFuture]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Row(
                    children: [
                      Expanded(child: _StatCard(value: '-', label: 'Patients', icon: Icons.people_outline)),
                      SizedBox(width: 12),
                      Expanded(child: _StatCard(value: '-', label: 'Alertes', icon: Icons.warning_amber_outlined, color: AppTheme.warningOrange)),
                      SizedBox(width: 12),
                      Expanded(child: _StatCard(value: '-', label: 'Messages', icon: Icons.message_outlined)),
                    ],
                  );
                }
                final patients = (snapshot.data?[0] as List<Patient>?) ?? [];
                final allNotes = (snapshot.data?[1] as List<MedicalNote>?) ?? [];

                // Calculate alerts (high blood pressure: systolic >= 16 or diastolic >= 10)
                final recentAlerts = allNotes.where((note) {
                  final isRecent = DateTime.now().difference(note.date).inDays <= 7;
                  final isHigh = note.systolic >= 16 || note.diastolic >= 10;
                  return isRecent && isHigh;
                }).length;

                return Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        value: patients.length.toString(),
                        label: 'Patients',
                        icon: Icons.people_outline,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        value: recentAlerts.toString(),
                        label: 'Alertes',
                        icon: Icons.warning_amber_outlined,
                        color: AppTheme.warningOrange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        value: '-', // TODO: Requires MessagesRepository
                        label: 'Messages',
                        icon: Icons.message_outlined,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Revenus
            Text(
              '💰 Revenus ce mois',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      '90,000 F CFA', // TODO: Replace with dynamic revenue
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: 0.75, // TODO: Replace with dynamic progress
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '75% de l\'objectif', // TODO: Replace with dynamic goal
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Alertes prioritaires
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '⚠️ Alertes prioritaires',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.doctorPatients);
                  },
                  child: const Text('Voir tout'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            FutureBuilder<List<dynamic>>(
              future: Future.wait([_allNotesFuture, _patientsFuture]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allNotes = (snapshot.data?[0] as List<MedicalNote>?) ?? [];
                final patients = (snapshot.data?[1] as List<Patient>?) ?? [];

                // Get high priority alerts (recent high blood pressure)
                final alerts = allNotes.where((note) {
                  final isRecent = DateTime.now().difference(note.date).inDays <= 7;
                  final isHigh = note.systolic >= 16 || note.diastolic >= 10;
                  return isRecent && isHigh;
                }).toList();

                // Sort by date (most recent first)
                alerts.sort((a, b) => b.date.compareTo(a.date));

                // Take top 3
                final topAlerts = alerts.take(3).toList();

                if (topAlerts.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Text('✅ Aucune alerte prioritaire'),
                      ),
                    ),
                  );
                }

                return Column(
                  children: topAlerts.map((note) {
                    final patient = patients.firstWhere(
                      (p) => p.id == note.patientId,
                      orElse: () => Patient(
                        id: note.patientId,
                        firstName: 'Patient',
                        lastName: 'Inconnu',
                        email: '',
                        phoneNumber: '',
                        address: '',
                        birthDate: DateTime.now(),
                        gender: '',
                      ),
                    );

                    final duration = DateTime.now().difference(note.date);
                    String timeAgo;
                    if (duration.inMinutes < 60) {
                      timeAgo = 'Il y a ${duration.inMinutes} min';
                    } else if (duration.inHours < 24) {
                      timeAgo = 'Il y a ${duration.inHours}h';
                    } else {
                      timeAgo = 'Il y a ${duration.inDays}j';
                    }

                    final severity = note.systolic >= 18 || note.diastolic >= 11
                        ? 'high'
                        : 'medium';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _AlertCard(
                        patientId: patient.id,
                        patientName: '${patient.firstName} ${patient.lastName}',
                        reading: '${note.systolic}/${note.diastolic}',
                        time: timeAgo,
                        severity: severity,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 24),

            // Agenda
            Text(
              '📅 Aujourd\'hui',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.video_call_outlined),
                    title: const Text('10:00 - Téléconsultation'),
                    subtitle: const Text('avec Jean Dupont'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.event_outlined),
                    title: const Text('15:00 - Consultation'),
                    subtitle: const Text('Marie Koffi'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Patients récents
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.doctorPatients);
              },
              child: const Text('📊 Voir tous les patients'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const DoctorBottomNav(currentIndex: 0),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color? color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: color ?? Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final String patientId;
  final String patientName;
  final String reading;
  final String time;
  final String severity;

  const _AlertCard({
    required this.patientId,
    required this.patientName,
    required this.reading,
    required this.time,
    required this.severity,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        severity == 'high' ? AppTheme.secondaryRed : AppTheme.warningOrange;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patientName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tension: $reading',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    time,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.patientFile,
                  arguments: {'patientId': patientId},
                );
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('VOIR'),
            ),
          ],
        ),
      ),
    );
  }
}

