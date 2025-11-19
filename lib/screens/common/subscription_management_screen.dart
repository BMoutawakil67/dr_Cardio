import 'package:flutter/material.dart';
import 'package:dr_cardio/config/app_theme.dart';

class SubscriptionManagementScreen extends StatelessWidget {
  const SubscriptionManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gérer mon abonnement'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Plan
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.workspace_premium,
                            color: AppTheme.primaryBlue,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Plan Actuel',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.greyMedium,
                                ),
                              ),
                              Text(
                                'Plan Solo',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.successGreen,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Actif',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    _buildInfoRow('Prix', '10,000 FCFA/mois'),
                    _buildInfoRow('Date de renouvellement', '19 Décembre 2025'),
                    _buildInfoRow('Méthode de paiement', 'Orange Money'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Features
            const Text(
              'Fonctionnalités incluses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildFeatureTile('✓', 'Suivi illimité de tension', true),
                    _buildFeatureTile('✓', 'Communication avec cardiologue', true),
                    _buildFeatureTile('✓', 'Historique complet', true),
                    _buildFeatureTile('✓', 'Graphiques et statistiques', true),
                    _buildFeatureTile('✓', 'Rappels personnalisés', true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Upgrade Card
            Card(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.arrow_upward,
                          color: AppTheme.primaryBlue,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Plan Clinique',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Passez au plan Clinique pour bénéficier de:',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureTile('✓', 'Nombre illimité de patients', false),
                    _buildFeatureTile('✓', 'Multi-praticiens', false),
                    _buildFeatureTile('✓', 'Statistiques avancées', false),
                    _buildFeatureTile('✓', 'Export de données', false),
                    _buildFeatureTile('✓', 'Support prioritaire', false),
                    const SizedBox(height: 16),
                    const Text(
                      '25,000 FCFA/mois',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _showUpgradeDialog(context);
                        },
                        child: const Text('Passer au Plan Clinique'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Actions
            const Text(
              'Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.payment, color: AppTheme.primaryBlue),
                    title: const Text('Modifier le moyen de paiement'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      _showPaymentMethodDialog(context);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.history, color: AppTheme.primaryBlue),
                    title: const Text('Historique de paiement'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      _showPaymentHistory(context);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.cancel, color: AppTheme.secondaryRed),
                    title: const Text(
                      'Résilier mon abonnement',
                      style: TextStyle(color: AppTheme.secondaryRed),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      _showCancelDialog(context);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
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

  Widget _buildFeatureTile(String icon, String text, bool isIncluded) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            icon,
            style: TextStyle(
              fontSize: 18,
              color: isIncluded ? AppTheme.successGreen : AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Passer au Plan Clinique'),
        content: const Text(
          'Vous allez être redirigé vers la page de paiement pour souscrire au Plan Clinique (25,000 FCFA/mois).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Redirection vers le paiement...'),
                  backgroundColor: AppTheme.primaryBlue,
                ),
              );
            },
            child: const Text('Continuer'),
          ),
        ],
      ),
    );
  }

  void _showPaymentMethodDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Moyen de paiement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              value: 'orange',
              groupValue: 'orange',
              title: const Text('Orange Money'),
              onChanged: (value) {},
            ),
            RadioListTile(
              value: 'mtn',
              groupValue: 'orange',
              title: const Text('MTN Mobile Money'),
              onChanged: (value) {},
            ),
            RadioListTile(
              value: 'moov',
              groupValue: 'orange',
              title: const Text('Moov Money'),
              onChanged: (value) {},
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Moyen de paiement modifié'),
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _showPaymentHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Historique de paiement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPaymentHistoryItem('19 Nov 2025', '10,000 FCFA', 'Réussi'),
            _buildPaymentHistoryItem('19 Oct 2025', '10,000 FCFA', 'Réussi'),
            _buildPaymentHistoryItem('19 Sep 2025', '10,000 FCFA', 'Réussi'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistoryItem(String date, String amount, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(date, style: const TextStyle(fontSize: 14)),
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.successGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: const TextStyle(
                color: AppTheme.successGreen,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Résilier l\'abonnement'),
        content: const Text(
          'Êtes-vous sûr de vouloir résilier votre abonnement?\n\nVous perdrez l\'accès aux fonctionnalités premium à la fin de votre période de facturation actuelle (19 Décembre 2025).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Abonnement résilié. Actif jusqu\'au 19 Décembre 2025'),
                  backgroundColor: AppTheme.warningOrange,
                  duration: Duration(seconds: 4),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.secondaryRed),
            child: const Text('Résilier'),
          ),
        ],
      ),
    );
  }
}
