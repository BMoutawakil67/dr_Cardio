import 'package:flutter/material.dart';
import 'package:dr_cardio/config/app_theme.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aide & Support'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📞 Contactez-nous',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildContactTile(
                      Icons.email_outlined,
                      'Email',
                      'support@docteurcardio.com',
                    ),
                    const Divider(),
                    _buildContactTile(
                      Icons.phone_outlined,
                      'Téléphone',
                      '+225 27 XX XX XX XX',
                    ),
                    const Divider(),
                    _buildContactTile(
                      Icons.access_time,
                      'Horaires',
                      'Lun-Ven: 8h-18h',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // FAQ Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '❓ Questions Fréquentes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFAQItem(
                      'Comment prendre ma tension correctement?',
                      'Asseyez-vous confortablement, reposez votre bras sur une table, attendez 5 minutes avant de mesurer.',
                    ),
                    const Divider(),
                    _buildFAQItem(
                      'Quand dois-je prendre ma tension?',
                      'Idéalement le matin avant le petit-déjeuner et le soir avant le dîner.',
                    ),
                    const Divider(),
                    _buildFAQItem(
                      'Comment contacter mon cardiologue?',
                      'Allez dans l\'onglet Messages et sélectionnez votre cardiologue pour lui envoyer un message.',
                    ),
                    const Divider(),
                    _buildFAQItem(
                      'Mes données sont-elles sécurisées?',
                      'Oui, toutes vos données médicales sont cryptées et stockées de manière sécurisée.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Guide Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📚 Guides d\'utilisation',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildGuideTile('Prendre ma tension', Icons.favorite_outlined),
                    _buildGuideTile('Consulter mon historique', Icons.history),
                    _buildGuideTile('Contacter mon médecin', Icons.chat_outlined),
                    _buildGuideTile('Modifier mon profil', Icons.person_outlined),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Emergency Card
            Card(
              color: AppTheme.secondaryRed.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(
                      Icons.emergency,
                      color: AppTheme.secondaryRed,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Urgence Médicale',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondaryRed,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'En cas d\'urgence médicale, appelez immédiatement le 185 (SAMU)',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement emergency call
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Appelez le 185 pour une urgence'),
                            backgroundColor: AppTheme.secondaryRed,
                          ),
                        );
                      },
                      icon: const Icon(Icons.phone),
                      label: const Text('Appeler le 185'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryRed,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryBlue),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.greyMedium,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            answer,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.greyMedium,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuideTile(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryBlue),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // TODO: Navigate to guide
      },
    );
  }
}
