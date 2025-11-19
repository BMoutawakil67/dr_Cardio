import 'package:dr_cardio/models/medical_note.dart';
import 'package:dr_cardio/models/patient.dart';
import 'package:dr_cardio/repositories/medical_note_repository.dart';
import 'package:dr_cardio/repositories/patient_repository.dart';
import 'package:flutter/material.dart';
import 'package:dr_cardio/routes/app_routes.dart';
import 'package:dr_cardio/config/app_theme.dart';
import 'package:intl/intl.dart';

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
  final String _patientId = 'patient-001'; // TODO: Replace with actual patient ID

  @override
  void initState() {
    super.initState();
    _patientFuture = _patientRepository.getPatient(_patientId);
    _medicalNotesFuture =
        _medicalNoteRepository.getMedicalNotesByPatientId(_patientId);
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
        title: const Text('DocteurCardio'),
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
                FutureBuilder<Patient?>(
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
                const SizedBox(height: 4),
                FutureBuilder<List<MedicalNote>>(
                  future: _medicalNotesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      final lastNote = snapshot.data!.first;
                      final formattedDate = DateFormat('dd MMM, HH:mm', 'fr_FR')
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
                const SizedBox(height: 20),

                // Carte dernière mesure
                FutureBuilder<List<MedicalNote>>(
                  future: _medicalNotesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      return _LastMeasureCard(note: snapshot.data!.first);
                    }
                    return const _LastMeasureCard(); // Show empty state
                  },
                ),
                const SizedBox(height: 20),

                // Actions rapides
                _SectionHeader(title: '⚡ Actions rapides'),
                const SizedBox(height: 16),
                Row(
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
                const SizedBox(height: 20),

                // Tendance
                _SectionHeader(title: '📈 Tendance (7 jours)'),
                const SizedBox(height: 16),
                _AnimatedCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Container(
                          height: 120,
                          alignment: Alignment.center,
                          child: const Text('[Mini graphique]'),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.patientHistory, arguments: {'patientId': _patientId});
                          },
                          child: const Text('📊 Voir l\'historique complet'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Messages
                _MessagePreviewCard(),
                const SizedBox(height: 16),

                // Prochain RDV
                _AnimatedCard(
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today_outlined),
                    title: const Text('Prochain RDV: 05 Nov'),
                    subtitle: const Text('Téléconsultation 10h00'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _PatientBottomNav(currentIndex: 0),
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
        ? DateFormat('dd MMM yyyy, HH:mm', 'fr_FR').format(note!.date)
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
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 200),
        tween: Tween<double>(begin: 1.0, end: 1.0),
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
            side: BorderSide(
              color: const Color(0xFFE4E7EB).withOpacity(0.5),
              width: 1,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            onTapDown: (_) {},
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
        ),
      ),
    );
  }
}

class _MessagePreviewCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _AnimatedCard(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF31C48D).withOpacity(0.1),
          child: Icon(
            Icons.person,
            color: const Color(0xFF31C48D),
          ),
        ),
        title: const Text('💬 Messages (2 nouveaux)'),
        subtitle: const Text('Dr. Kouassi vous a écrit'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.patientMessages);
        },
      ),
    );
  }
}

class _PatientBottomNav extends StatelessWidget {
  final int currentIndex;

  const _PatientBottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      elevation: 8,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, AppRoutes.patientDashboard);
            break;
          case 1:
            Navigator.pushNamed(context, AppRoutes.patientHistory);
            break;
          case 2:
            Navigator.pushNamed(context, AppRoutes.recordPressurePhoto);
            break;
          case 3:
            Navigator.pushNamed(context, AppRoutes.patientMessages);
            break;
          case 4:
            Navigator.pushNamed(context, AppRoutes.patientProfile);
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
          icon: Icon(Icons.analytics_outlined),
          activeIcon: Icon(Icons.analytics),
          label: 'Historique',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.camera_alt_outlined),
          activeIcon: Icon(Icons.camera_alt),
          label: 'Mesure',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message_outlined),
          activeIcon: Icon(Icons.message),
          label: 'Messages',
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