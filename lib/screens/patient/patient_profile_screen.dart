import 'package:dr_cardio/models/doctor_model.dart';
import 'package:dr_cardio/models/patient_model.dart';
import 'package:dr_cardio/repositories/doctor_repository.dart';
import 'package:dr_cardio/repositories/patient_repository.dart';
import 'package:dr_cardio/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:dr_cardio/config/app_theme.dart';
import 'package:dr_cardio/routes/app_routes.dart';
import 'package:dr_cardio/widgets/animations/animated_widgets.dart';
import 'package:dr_cardio/widgets/navigation/shared_bottom_navigation.dart';

class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  final PatientRepository _patientRepository = PatientRepository();
  final DoctorRepository _doctorRepository = DoctorRepository();

  late Future<Patient?> _patientFuture;
  late Future<Doctor?> _doctorFuture;

  // Subscription state
  String _subscriptionPlan = 'STANDARD';
  int _subscriptionPrice = 5000;

  @override
  void initState() {
    super.initState();
    final patientId = AuthService().currentUserId ?? 'patient-001';
    _patientFuture = _patientRepository.getPatient(patientId);
    // TODO: Add doctor assignment logic
    // For now, using hardcoded doctor ID from mock data
    _doctorFuture = _doctorRepository.getDoctor('doctor-001');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.patientEditProfile);
            },
          ),
        ],
      ),
      body: FutureBuilder<Patient?>(
          future: _patientFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return const Center(child: Text('Impossible de charger le profil.'));
            }

            final patient = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Photo de profil
                  FadeInSlideUp(
                    delay: 0,
                    child: CircleAvatar(
                    radius: 50,
                    backgroundImage: patient.profileImageUrl != null
                        ? NetworkImage(patient.profileImageUrl!)
                        : null,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: patient.profileImageUrl == null
                        ? const Icon(Icons.person, size: 50, color: Colors.white)
                        : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeInSlideUp(
                    delay: 200,
                    child: Text(
                      '${patient.firstName} ${patient.lastName}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  FadeInSlideUp(
                    delay: 400,
                    child: Text(
                      patient.email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Informations personnelles
                  FadeInSlideUp(
                    delay: 600,
                    child: _SectionTitle(title: '📋 Informations personnelles'),
                  ),
                  FadeInSlideUp(
                    delay: 800,
                    child: Card(
                    child: Column(
                      children: [
                        _InfoTile(
                          label: '📅 Âge',
                          value: '${DateTime.now().year - patient.birthDate.year} ans',
                        ),
                        const Divider(height: 1),
                        _InfoTile(label: '👤 Genre', value: patient.gender),
                        const Divider(height: 1),
                        _InfoTile(label: '📍 Adresse', value: patient.address),
                        const Divider(height: 1),
                        _InfoTile(label: '📞 Téléphone', value: patient.phoneNumber),
                      ],
                    ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Mon cardiologue
                  FadeInSlideUp(
                    delay: 1000,
                    child: _SectionTitle(title: '👨‍⚕️ Mon cardiologue'),
                  ),
                  FadeInSlideUp(
                    delay: 1200,
                    child: FutureBuilder<Doctor?>(
                    future: _doctorFuture,
                    builder: (context, doctorSnapshot) {
                      if (doctorSnapshot.connectionState ==
                              ConnectionState.waiting) {
                        return const Card(child: Center(child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        )));
                      }
                      if (doctorSnapshot.hasError || !doctorSnapshot.hasData) {
                        return const Card(
                            child: ListTile(title: Text('Aucun cardiologue assigné.')));
                      }
                      final doctorData = doctorSnapshot.data!;
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: doctorData.profileImageUrl != null
                                        ? NetworkImage(doctorData.profileImageUrl!)
                                        : null,
                                    child: doctorData.profileImageUrl == null
                                        ? const Icon(Icons.person)
                                        : null,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Dr. ${doctorData.firstName} ${doctorData.lastName}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          doctorData.specialty,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall?.copyWith(
                                                fontStyle: FontStyle.italic,
                                              ),
                                        ),
                                        Text(
                                          '📍 ${doctorData.address}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        // Open chat with current cardiologist
                                        Navigator.pushNamed(
                                          context,
                                          AppRoutes.patientChat,
                                          arguments: {
                                            'name': 'Dr. ${doctorData.firstName} ${doctorData.lastName}',
                                            'avatar': Icons.person,
                                            'doctorId': doctorData.id,
                                          },
                                        );
                                      },
                                      icon: const Icon(Icons.chat_outlined, size: 18),
                                      label: const Text('Contacter'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _showChangeCardioDialog(context),
                                      icon: const Icon(Icons.swap_horiz, size: 18),
                                      label: const Text('Changer'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Abonnement
                  FadeInSlideUp(
                    delay: 1400,
                    child: _SectionTitle(title: '💳 Abonnement'),
                  ),
                  FadeInSlideUp(
                    delay: 1600,
                    child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _subscriptionPlan == 'PREMIUM'
                                  ? Colors.amber.withValues(alpha: 0.2)
                                  : AppTheme.primaryBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_subscriptionPlan == 'PREMIUM')
                                  const Icon(Icons.star, size: 16, color: Colors.amber),
                                if (_subscriptionPlan == 'PREMIUM')
                                  const SizedBox(width: 4),
                                Text(
                                  _subscriptionPlan == 'PREMIUM' ? '⭐ PREMIUM' : '📦 STANDARD',
                                  style: TextStyle(
                                    color: _subscriptionPlan == 'PREMIUM'
                                        ? Colors.amber[700]
                                        : AppTheme.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '$_subscriptionPrice F/mois',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Prochain: 27 Nov 2025',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _showManageSubscriptionDialog(context),
                                  child: const Text('Gérer'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _showUpgradeSubscriptionDialog(context),
                                  child: const Text('Améliorer'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Paramètres
                  FadeInSlideUp(
                    delay: 1800,
                    child: _SectionTitle(title: '⚙️ Paramètres'),
                  ),
                  FadeInSlideUp(
                    delay: 2000,
                    child: Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.description_outlined),
                          title: const Text('Documents médicaux'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.patientDocuments);
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.notifications_outlined),
                          title: const Text('Notifications & Rappels'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.patientSettings);
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.security_outlined),
                          title: const Text('Sécurité & Confidentialité'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {},
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.language_outlined),
                          title: const Text('Langue'),
                          subtitle: const Text('Français'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {},
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.dark_mode_outlined),
                          title: const Text('Mode sombre'),
                          trailing: Switch(
                            value: false,
                            onChanged: (value) {},
                          ),
                        ),
                      ],
                    ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Statistiques
                  FadeInSlideUp(
                    delay: 2200,
                    child: _SectionTitle(title: '📊 Mes statistiques'),
                  ),
                  FadeInSlideUp(
                    delay: 2400,
                    child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _InfoTile(label: '• 247 mesures enregistrées', value: ''),
                          _InfoTile(label: '• Membre depuis 3 mois', value: ''),
                          _InfoTile(label: '• Streak: 🔥 12 jours', value: ''),
                        ],
                      ),
                    ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Actions
                  FadeInSlideUp(
                    delay: 2600,
                    child: ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text('Aide & Support'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.helpSupport);
                    },
                    ),
                  ),
                  FadeInSlideUp(
                    delay: 2800,
                    child: ListTile(
                      leading: const Icon(Icons.description_outlined),
                      title: const Text('CGU & Confidentialité'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.termsPrivacy);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeInSlideUp(
                    delay: 3000,
                    child: OutlinedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Déconnexion'),
                          content: const Text(
                              'Êtes-vous sûr de vouloir vous déconnecter ?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Annuler'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Fermer le dialog
                                // Retour à l'écran de choix de profil
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  AppRoutes.profileChoice,
                                  (route) => false,
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.secondaryRed,
                              ),
                              child: const Text('Se déconnecter'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Déconnexion'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.secondaryRed,
                      side: const BorderSide(color: AppTheme.secondaryRed),
                    ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          }),
      bottomNavigationBar: const PatientBottomNav(currentIndex: 4),
    );
  }

  Future<void> _showChangeCardioDialog(BuildContext context) async {
    // Get all doctors from Hive
    var doctors = await _doctorRepository.getAllDoctors();

    // If no doctors in Hive, use mock data (same as registration screen)
    if (doctors.isEmpty) {
      doctors = [
        Doctor(
          id: 'doctor-mock-001',
          firstName: 'Jean',
          lastName: 'Kouassi',
          email: 'kouassi@example.com',
          phoneNumber: '+225 07 XX XX XX XX',
          specialty: 'Cardiologue',
          address: 'Cotonou, Bénin',
          profileImageUrl: null,
        ),
        Doctor(
          id: 'doctor-mock-002',
          firstName: 'Amina',
          lastName: 'Diallo',
          email: 'diallo@example.com',
          phoneNumber: '+225 05 XX XX XX XX',
          specialty: 'Cardiologue',
          address: 'Porto-Novo, Bénin',
          profileImageUrl: null,
        ),
        Doctor(
          id: 'doctor-mock-003',
          firstName: 'Paul',
          lastName: 'Mensah',
          email: 'mensah@example.com',
          phoneNumber: '+228 90 XX XX XX XX',
          specialty: 'Cardiologue',
          address: 'Lomé, Togo',
          profileImageUrl: null,
        ),
      ];
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600, maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.medical_services, color: Colors.white),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Changer de cardiologue',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(dialogContext),
                    ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(16),
                        itemCount: doctors.length,
                        itemBuilder: (context, index) {
                          final doctor = doctors[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () async {
                                Navigator.pop(dialogContext);

                                // Afficher loader
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );

                                // Get current patient
                                final patientId = AuthService().currentUserId ?? 'patient-001';
                                final currentPatient = await _patientRepository.getPatient(patientId);

                                if (currentPatient != null) {
                                  // Update patient's assigned doctor
                                  final updatedPatient = currentPatient.copyWith(
                                    assignedDoctorId: doctor.id,
                                  );

                                  // Save to database
                                  final success = await _patientRepository.updatePatient(updatedPatient);

                                  if (mounted) {
                                    Navigator.pop(context); // Fermer loader

                                    if (success) {
                                      // Reload the doctor future
                                      setState(() {
                                        _doctorFuture = _doctorRepository.getDoctor(doctor.id);
                                      });

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('✅ Cardiologue changé pour Dr. ${doctor.firstName} ${doctor.lastName}'),
                                          backgroundColor: AppTheme.successGreen,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Text('❌ Erreur lors du changement de cardiologue'),
                                          backgroundColor: AppTheme.errorRed,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    // Avatar
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                                      backgroundImage: doctor.profileImageUrl != null
                                          ? NetworkImage(doctor.profileImageUrl!)
                                          : null,
                                      child: doctor.profileImageUrl == null
                                          ? const Icon(Icons.person, size: 30, color: AppTheme.primaryBlue)
                                          : null,
                                    ),
                                    const SizedBox(width: 16),
                                    // Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Dr. ${doctor.firstName} ${doctor.lastName}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.medical_services,
                                                size: 14,
                                                color: AppTheme.primaryBlue,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                doctor.specialty,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          if (doctor.address.isNotEmpty)
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.location_on_outlined,
                                                  size: 14,
                                                  color: Colors.grey,
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    doctor.address,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                    // Arrow
                                    const Icon(
                                      Icons.chevron_right,
                                      color: AppTheme.primaryBlue,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showManageSubscriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Gérer mon abonnement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Abonnement actuel: STANDARD',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('3000 F/mois'),
            const SizedBox(height: 16),
            const Text(
              'Que souhaitez-vous faire?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.pause_circle_outline, color: AppTheme.warningOrange),
              title: const Text('Suspendre temporairement'),
              onTap: () {
                Navigator.pop(dialogContext);
                _confirmSuspendSubscription(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel_outlined, color: AppTheme.secondaryRed),
              title: const Text('Résilier définitivement'),
              onTap: () {
                Navigator.pop(dialogContext);
                _confirmCancelSubscription(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _confirmSuspendSubscription(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.pause_circle_outline, color: AppTheme.warningOrange),
            SizedBox(width: 12),
            Text('Suspendre l\'abonnement'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Votre abonnement sera suspendu pendant 1 mois.'),
            SizedBox(height: 8),
            Text('Vous pourrez le réactiver à tout moment.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('✅ Abonnement suspendu jusqu\'au 27 Déc 2025'),
                  backgroundColor: AppTheme.warningOrange,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.warningOrange,
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  void _confirmCancelSubscription(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.secondaryRed),
            SizedBox(width: 12),
            Text('Résilier l\'abonnement'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Êtes-vous sûr de vouloir résilier votre abonnement?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('⚠️ Vous perdrez:'),
            Text('• Suivi quotidien de votre tension'),
            Text('• Communication avec votre cardiologue'),
            Text('• Historique des mesures'),
            Text('• Alertes automatiques'),
            SizedBox(height: 12),
            Text(
              'L\'abonnement restera actif jusqu\'au 27 Nov 2025.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('❌ Abonnement résilié. Actif jusqu\'au 27 Nov 2025'),
                  backgroundColor: AppTheme.secondaryRed,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  duration: const Duration(seconds: 4),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryRed,
            ),
            child: const Text('Résilier'),
          ),
        ],
      ),
    );
  }

  void _showUpgradeSubscriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.upgrade, color: AppTheme.primaryBlue),
            SizedBox(width: 12),
            Text('Améliorer votre abonnement'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Abonnement actuel: $_subscriptionPlan',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('$_subscriptionPrice F/mois'),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryBlue.withOpacity(0.1),
                      AppTheme.primaryBlue.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryBlue),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.star, color: AppTheme.primaryBlue),
                        SizedBox(width: 8),
                        Text(
                          'PREMIUM',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '10000 F/mois',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Fonctionnalités supplémentaires:'),
                    const SizedBox(height: 8),
                    _buildFeature('✅ Consultations illimitées'),
                    _buildFeature('✅ Priorité dans les réponses'),
                    _buildFeature('✅ Rapports détaillés mensuels'),
                    _buildFeature('✅ Rappels personnalisés'),
                    _buildFeature('✅ Export des données'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.successGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '💰 Différence: 5000 F/mois',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.successGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Plus tard'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _processUpgrade(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
            ),
            child: const Text('Passer à PREMIUM'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  void _processUpgrade(BuildContext context) async {
    // Naviguer vers la page de paiement (même page que lors de l'inscription)
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.payment,
      arguments: {
        'subscription': 'premium', // Use 'premium' to match payment_screen.dart
        'fromRegistration': false, // Indicate this is an upgrade, not registration
      },
    );

    // Si le paiement est réussi
    if (result == true && mounted) {
      setState(() {
        _subscriptionPlan = 'PREMIUM';
        _subscriptionPrice = 10000;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('🎉 Félicitations! Vous êtes maintenant PREMIUM'),
          backgroundColor: AppTheme.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          if (value.isNotEmpty)
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
        ],
      ),
    );
  }
}