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
                                          '${doctorData.specialty}',
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
                              color: _getSubscriptionColor(patient.subscription ?? 'free').withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getSubscriptionLabel(patient.subscription ?? 'free'),
                              style: TextStyle(
                                color: _getSubscriptionColor(patient.subscription ?? 'free'),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _getSubscriptionPrice(patient.subscription ?? 'free'),
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
                                  onPressed: () {},
                                  child: const Text('Gérer'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final result = await Navigator.pushNamed(
                                      context,
                                      AppRoutes.payment,
                                      arguments: {
                                        'subscription': 'premium',
                                        'fromUpgrade': true,
                                        'currentSubscription': patient.subscription ?? 'free',
                                      },
                                    );
                                    if (result == true) {
                                      setState(() {
                                        _patientFuture = _patientRepository.getPatient(patient.id);
                                      });
                                    }
                                  },
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
                    onTap: () {},
                    ),
                  ),
                  FadeInSlideUp(
                    delay: 2800,
                    child: ListTile(
                      leading: const Icon(Icons.description_outlined),
                      title: const Text('CGU & Confidentialité'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {},
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

  String _getSubscriptionLabel(String subscription) {
    switch (subscription.toLowerCase()) {
      case 'free':
        return '🆓 GRATUIT';
      case 'standard':
        return '📦 STANDARD';
      case 'premium':
        return '🌟 PREMIUM';
      default:
        return '📦 STANDARD';
    }
  }

  Color _getSubscriptionColor(String subscription) {
    switch (subscription.toLowerCase()) {
      case 'free':
        return AppTheme.successGreen;
      case 'standard':
        return AppTheme.primaryBlue;
      case 'premium':
        return const Color(0xFFFFB020); // Gold color
      default:
        return AppTheme.primaryBlue;
    }
  }

  String _getSubscriptionPrice(String subscription) {
    switch (subscription.toLowerCase()) {
      case 'free':
        return '0 F/mois';
      case 'standard':
        return '5000 F/mois';
      case 'premium':
        return '10000 F/mois';
      default:
        return '5000 F/mois';
    }
  }

  Future<void> _showChangeCardioDialog(BuildContext context) async {
    // Get all doctors
    final doctors = await _doctorRepository.getAllDoctors();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Changer de cardiologue'),
        content: SizedBox(
          width: double.maxFinite,
          child: doctors.isEmpty
              ? const Text('Aucun cardiologue disponible')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: doctors.length,
                  itemBuilder: (context, index) {
                    final doctor = doctors[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: doctor.profileImageUrl != null
                            ? NetworkImage(doctor.profileImageUrl!)
                            : null,
                        child: doctor.profileImageUrl == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text('Dr. ${doctor.firstName} ${doctor.lastName}'),
                      subtitle: Text(doctor.specialty),
                      onTap: () async {
                        Navigator.pop(dialogContext);

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

                          if (success) {
                            // Reload the doctor future
                            setState(() {
                              _doctorFuture = _doctorRepository.getDoctor(doctor.id);
                            });

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('✅ Cardiologue changé pour Dr. ${doctor.firstName} ${doctor.lastName}'),
                                  backgroundColor: AppTheme.successGreen,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                            }
                          } else {
                            if (mounted) {
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
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
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