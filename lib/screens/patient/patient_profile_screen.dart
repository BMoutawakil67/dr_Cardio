import 'package:dr_cardio/models/doctor_model.dart';
import 'package:dr_cardio/models/patient_model.dart';
import 'package:dr_cardio/repositories/doctor_repository.dart';
import 'package:dr_cardio/repositories/patient_repository.dart';
import 'package:flutter/material.dart';
import 'package:dr_cardio/config/app_theme.dart';
import 'package:dr_cardio/routes/app_routes.dart';

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

  final String _patientId = 'patient-001'; // TODO: Replace with actual patient ID

  @override
  void initState() {
    super.initState();
    _patientFuture = _patientRepository.getPatient(_patientId);
    // TODO: This assumes the patient has a doctorId. Handle cases where it might be null.
    _patientFuture.then((patient) {
      if (patient != null && patient.doctorId != null) {
        setState(() {
          _doctorFuture = _doctorRepository.getDoctor(patient.doctorId!);
        });
      }
    });
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
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: patient.avatarUrl != null
                        ? NetworkImage(patient.avatarUrl!)
                        : null,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: patient.avatarUrl == null
                        ? const Icon(Icons.person, size: 50, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${patient.firstName} ${patient.lastName}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    patient.email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 32),

                  // Informations personnelles
                  _SectionTitle(title: '📋 Informations personnelles'),
                  Card(
                    child: Column(
                      children: [
                        _InfoTile(label: '📅 Âge', value: '${patient.age} ans'),
                        const Divider(height: 1),
                        _InfoTile(label: '⚖️ Poids', value: '${patient.weight} kg'),
                        const Divider(height: 1),
                        _InfoTile(label: '📏 Taille', value: '${patient.height} m'),
                        const Divider(height: 1),
                        _InfoTile(label: '🩺 IMC', value: '24.5'), // TODO: Calculate IMC
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Mon cardiologue
                  _SectionTitle(title: '👨‍⚕️ Mon cardiologue'),
                  FutureBuilder<Doctor?>(
                    future: _doctorFuture,
                    builder: (context, doctorSnapshot) {
                      if (doctorSnapshot.connectionState ==
                              ConnectionState.waiting &&
                          patient.doctorId != null) {
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
                                    backgroundImage: doctorData.avatarUrl != null
                                        ? NetworkImage(doctorData.avatarUrl!)
                                        : null,
                                    child: doctorData.avatarUrl == null
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
                                          '📍 ${doctorData.location}',
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
                                    child: OutlinedButton(
                                      onPressed: () {},
                                      child: const Text('Contacter'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {},
                                      child: const Text('Changer'),
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
                  const SizedBox(height: 24),

                  // Abonnement
                  _SectionTitle(title: '💳 Abonnement'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '📦 STANDARD',
                              style: TextStyle(
                                color: AppTheme.primaryBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '3000 F/mois',
                            style: TextStyle(
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
                                  onPressed: () {},
                                  child: const Text('Améliorer'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Paramètres
                  _SectionTitle(title: '⚙️ Paramètres'),
                  Card(
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
                  const SizedBox(height: 24),

                  // Statistiques
                  _SectionTitle(title: '📊 Mes statistiques'),
                  Card(
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
                  const SizedBox(height: 24),

                  // Actions
                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text('Aide & Support'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: const Text('CGU & Confidentialité'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
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
                  const SizedBox(height: 32),
                ],
              ),
            );
          }),
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