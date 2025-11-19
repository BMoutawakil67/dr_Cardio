import 'package:dr_cardio/models/doctor_model.dart';
import 'package:dr_cardio/models/patient_model.dart';
import 'package:dr_cardio/repositories/doctor_repository.dart';
import 'package:dr_cardio/repositories/patient_repository.dart';
import 'package:flutter/material.dart';
import 'package:dr_cardio/routes/app_routes.dart';
import 'package:dr_cardio/config/app_theme.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  final DoctorRepository _doctorRepository = DoctorRepository();
  final PatientRepository _patientRepository = PatientRepository();

  late Future<Doctor?> _doctorFuture;
  late Future<List<Patient>> _patientsFuture;

  @override
  void initState() {
    super.initState();
    // TODO: Replace with actual doctor ID from auth
    _doctorFuture = _doctorRepository.getDoctor('doctor-001'); 
    _patientsFuture = _patientRepository.getAllPatients();
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
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
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
                  child: const Text(
                    '5', // TODO: Replace with dynamic alert count
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
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
            FutureBuilder<List<Patient>>(
              future: _patientsFuture,
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
                final patientCount = snapshot.data?.length ?? 0;
                return Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        value: patientCount.toString(),
                        label: 'Patients',
                        icon: Icons.people_outline,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        value: '3', // TODO: Replace with dynamic alert count
                        label: 'Alertes',
                        icon: Icons.warning_amber_outlined,
                        color: AppTheme.warningOrange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        value: '12', // TODO: Replace with dynamic message count
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

            _AlertCard(
              patientName: 'Jean Dupont',
              reading: '18/11',
              time: 'Il y a 15 min',
              severity: 'high',
            ),
            const SizedBox(height: 12),
            _AlertCard(
              patientName: 'Marie Koffi',
              reading: '16/10',
              time: 'Il y a 2h',
              severity: 'medium',
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
      bottomNavigationBar: _DoctorBottomNav(currentIndex: 0),
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
  final String patientName;
  final String reading;
  final String time;
  final String severity;

  const _AlertCard({
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
                Navigator.pushNamed(context, AppRoutes.patientFile);
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

class _DoctorBottomNav extends StatelessWidget {
  final int currentIndex;

  const _DoctorBottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, AppRoutes.doctorDashboard);
            break;
          case 1:
            Navigator.pushNamed(context, AppRoutes.doctorPatients);
            break;
          case 2:
            Navigator.pushNamed(context, AppRoutes.doctorMessages);
            break;
          case 3:
            Navigator.pushNamed(context, AppRoutes.doctorRevenue);
            break;
          case 4:
            Navigator.pushNamed(context, AppRoutes.doctorProfile);
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
          activeIcon: Icon(Icons.people),
          label: 'Patients',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message_outlined),
          activeIcon: Icon(Icons.message),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics_outlined),
          activeIcon: Icon(Icons.analytics),
          label: 'Stats',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}