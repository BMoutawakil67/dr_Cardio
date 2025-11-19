import 'package:flutter/material.dart';
import 'package:dr_cardio/config/app_theme.dart';
import 'package:dr_cardio/widgets/animations/animated_widgets.dart';

class TermsPrivacyScreen extends StatelessWidget {
  const TermsPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CGU & Confidentialité'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Last Updated
            FadeInSlideUp(
              delay: 0,
              child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.primaryBlue),
                  SizedBox(width: 12),
                  Text(
                    'Dernière mise à jour: 19 Novembre 2025',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              ),
            ),
            const SizedBox(height: 24),

            // Terms of Use
            FadeInSlideUp(
              delay: 200,
              child: _buildSection(
              '📜 Conditions Générales d\'Utilisation',
              [
                _buildParagraph(
                  '1. Acceptation des conditions',
                  'En utilisant DocteurCardio, vous acceptez les présentes conditions générales d\'utilisation. Si vous n\'acceptez pas ces conditions, veuillez ne pas utiliser l\'application.',
                ),
                _buildParagraph(
                  '2. Description du service',
                  'DocteurCardio est une application de suivi de tension artérielle permettant aux patients de surveiller leur santé cardiovasculaire et de communiquer avec leur cardiologue.',
                ),
                _buildParagraph(
                  '3. Utilisation du service',
                  'Vous vous engagez à utiliser l\'application de manière responsable et à fournir des informations exactes. L\'application est destinée à un usage personnel et médical uniquement.',
                ),
                _buildParagraph(
                  '4. Responsabilités',
                  'DocteurCardio est un outil de suivi et ne remplace pas une consultation médicale. En cas d\'urgence, contactez immédiatement les services d\'urgence (185).',
                ),
              ],
              ),
            ),
            const SizedBox(height: 24),

            // Privacy Policy
            FadeInSlideUp(
              delay: 400,
              child: _buildSection(
              '🔒 Politique de Confidentialité',
              [
                _buildParagraph(
                  '1. Collecte des données',
                  'Nous collectons les données personnelles que vous nous fournissez: nom, prénom, email, numéro de téléphone, et vos mesures de tension artérielle.',
                ),
                _buildParagraph(
                  '2. Utilisation des données',
                  'Vos données sont utilisées uniquement pour:\n• Fournir le service de suivi médical\n• Permettre la communication avec votre cardiologue\n• Améliorer l\'application',
                ),
                _buildParagraph(
                  '3. Protection des données',
                  'Toutes vos données médicales sont cryptées et stockées de manière sécurisée. Nous respectons le secret médical et les normes RGPD.',
                ),
                _buildParagraph(
                  '4. Partage des données',
                  'Vos données ne sont partagées qu\'avec votre cardiologue traitant. Nous ne vendons jamais vos données à des tiers.',
                ),
                _buildParagraph(
                  '5. Vos droits',
                  'Vous avez le droit de:\n• Accéder à vos données\n• Modifier vos données\n• Supprimer vos données\n• Exporter vos données',
                ),
              ],
              ),
            ),
            const SizedBox(height: 24),

            // Data Security
            FadeInSlideUp(
              delay: 600,
              child: _buildSection(
              '🛡️ Sécurité des Données',
              [
                _buildParagraph(
                  'Cryptage',
                  'Toutes les communications entre l\'application et nos serveurs sont cryptées avec SSL/TLS.',
                ),
                _buildParagraph(
                  'Stockage sécurisé',
                  'Vos données médicales sont stockées sur des serveurs sécurisés hébergés en Côte d\'Ivoire, conformément aux réglementations locales.',
                ),
                _buildParagraph(
                  'Authentification',
                  'L\'accès à votre compte est protégé par un mot de passe. Nous vous recommandons d\'utiliser un mot de passe fort.',
                ),
              ],
              ),
            ),
            const SizedBox(height: 24),

            // Contact
            FadeInSlideUp(
              delay: 800,
              child: Card(
              color: AppTheme.primaryBlue.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📧 Questions sur vos données?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pour toute question concernant vos données personnelles ou cette politique de confidentialité, contactez-nous:',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Email: privacy@docteurcardio.com\nTéléphone: +225 27 XX XX XX XX',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildParagraph(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.greyMedium,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
