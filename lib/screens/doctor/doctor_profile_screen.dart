import 'package:dr_cardio/config/app_theme.dart';
import 'package:dr_cardio/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:dr_cardio/models/doctor_model.dart';
import 'package:dr_cardio/repositories/doctor_repository.dart';
import 'package:dr_cardio/services/auth_service.dart';
import 'package:dr_cardio/widgets/navigation/shared_bottom_navigation.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  final DoctorRepository _doctorRepository = DoctorRepository();
  Doctor? _doctor;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDoctor();
  }

  Future<void> _loadDoctor() async {
    final doctorId = AuthService().currentUserId ?? 'doctor-001';
    final doctor = await _doctorRepository.getDoctor(doctorId);

    if (mounted) {
      setState(() {
        _doctor = doctor;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_doctor == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mon Profil')),
        body: const Center(child: Text('Erreur: Profil non trouvé')),
        bottomNavigationBar: const DoctorBottomNav(currentIndex: 4),
      );
    }

    final doctor = _doctor!; // Safe because we checked for null above

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final result = await Navigator.pushNamed(
                context,
                AppRoutes.doctorEditProfile,
                arguments: doctor,
              );
              if (result == true) {
                // Reload doctor from Hive after successful update
                await _loadDoctor();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header avec photo et nom
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryBlue,
                    AppTheme.primaryBlue.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      color: Colors.white,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Dr. ${doctor.firstName} ${doctor.lastName}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doctor.specialty,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '15 ans d\'expérience',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // QR Code Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Text(
                        '📱 Mon Code QR Professionnel',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppTheme.greyMedium),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.qr_code,
                            size: 150,
                            color: AppTheme.greyMedium,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Scannez ce code pour accéder à mon profil',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.greyMedium,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              Share.share(
                                  'QR Code du Dr. Mamadou KOUASSI\nURL: https://drcardio.ci/dr/kouassi');
                            },
                            icon: const Icon(Icons.share),
                            label: const Text('Partager'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Fonctionnalité disponible prochainement'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.download),
                            label: const Text('Télécharger'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Informations professionnelles
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ℹ️ Informations professionnelles',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('Spécialité', doctor.specialty),
                      const Divider(),
                      _buildInfoRow('Email', doctor.email),
                      const Divider(),
                      _buildInfoRow('Téléphone', doctor.phoneNumber),
                      const Divider(),
                      _buildInfoRow('Adresse', doctor.address),
                    ],
                  ),
                ),
              ),
            ),

            // Horaires de consultation
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '🕐 Horaires de consultation',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textColor,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Modifier les horaires'),
                                  content: const Text(
                                      'Cette fonctionnalité vous permettra de modifier vos horaires de consultation.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildScheduleRow('Lundi - Vendredi', '08:00 - 17:00'),
                      const SizedBox(height: 8),
                      _buildScheduleRow('Samedi', '08:00 - 12:00'),
                      const SizedBox(height: 8),
                      _buildScheduleRow('Dimanche', 'Fermé'),
                    ],
                  ),
                ),
              ),
            ),

            // Statistiques
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard('45', 'Patients actifs'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard('247', 'Consultations'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard('4.8 ⭐', 'Évaluation'),
                  ),
                ],
              ),
            ),

            // Paramètres du compte
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.notifications_outlined),
                      title: const Text('Notifications'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.security_outlined),
                      title: const Text('Sécurité'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.language_outlined),
                      title: const Text('Langue'),
                      trailing: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Français'),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.help_outline),
                      title: const Text('Aide & Support'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),

            // Abonnement
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.star, color: AppTheme.warningOrange),
                          SizedBox(width: 8),
                          Text(
                            'Abonnement actuel: Solo',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Passez à l\'offre Clinique pour gérer plusieurs médecins et bénéficier de fonctionnalités avancées.',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Row(
                                  children: [
                                    Icon(Icons.upgrade,
                                        color: AppTheme.primaryBlue),
                                    SizedBox(width: 12),
                                    Text(
                                      'Offre Clinique',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryBlue,
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Annuler'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Redirection vers le paiement...'),
                                          backgroundColor: AppTheme.primaryBlue,
                                        ),
                                      );
                                    },
                                    child: const Text('Souscrire'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Text('Passer à l\'offre Clinique'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Aide et Support
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.help_outline, color: AppTheme.primaryBlue),
                      title: const Text('Aide & Support'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.helpSupport);
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.description_outlined, color: AppTheme.primaryBlue),
                      title: const Text('CGU & Confidentialité'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.termsPrivacy);
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Déconnexion
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Déconnexion'),
                        content: const Text(
                            'Êtes-vous sûr de vouloir vous déconnecter?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                  '/', (route) => false);
                            },
                            style: TextButton.styleFrom(
                                foregroundColor: AppTheme.secondaryRed),
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
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: const DoctorBottomNav(currentIndex: 4),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.greyMedium,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleRow(String day, String hours) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          day,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textColor,
          ),
        ),
        Text(
          hours,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: hours == 'Fermé'
                ? AppTheme.secondaryRed
                : AppTheme.successGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
