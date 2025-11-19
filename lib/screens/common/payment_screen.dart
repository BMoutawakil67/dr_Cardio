import 'package:flutter/material.dart';
import 'package:dr_cardio/routes/app_routes.dart';
import 'package:dr_cardio/config/app_theme.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = 'mtn';
  bool _autoRenewal = true;
  String _selectedPlan = 'STANDARD';
  int _amount = 3000;
  String _selectedSubscription = 'standard';

  // Contrôleurs pour Mobile Money
  final _phoneController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCvvController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    super.dispose();
  }

  bool _fromRegistration = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      _selectedSubscription = arguments['subscription'] ?? 'standard';
      _fromRegistration = arguments['fromRegistration'] ?? false;

      if (_selectedSubscription == 'standard') {
        _amount = 5000;
        _selectedPlan = 'STANDARD';
      } else if (_selectedSubscription == 'premium') {
        _amount = 10000;
        _selectedPlan = 'PREMIUM';
      }
    }
  }

  Future<void> _processPayment() async {
    // Validation selon le mode de paiement
    if ((_selectedPaymentMethod == 'mtn' || _selectedPaymentMethod == 'moov') &&
        _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer votre numéro de téléphone'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    if (_selectedPaymentMethod == 'card' &&
        (_cardNumberController.text.isEmpty ||
            _cardExpiryController.text.isEmpty ||
            _cardCvvController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir toutes les informations de la carte'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    // Afficher le dialog de traitement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Traitement du paiement...'),
              ],
            ),
          ),
        ),
      ),
    );

    // Simuler le traitement du paiement
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.pop(context); // Fermer le dialog de traitement

      // Afficher le dialog de succès
      _showSuccessDialog();
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppTheme.successGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Paiement réussi !',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              _fromRegistration
                  ? 'Votre abonnement $_selectedPlan a été activé.\nVous pouvez maintenant choisir votre cardiologue.'
                  : 'Votre abonnement $_selectedPlan a été activé avec succès',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Fermer le dialog
                if (_fromRegistration) {
                  // Si depuis l'inscription, retourner true pour continuer le flux
                  Navigator.pop(context, true);
                } else {
                  // Sinon, rediriger vers le dashboard patient
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.patientDashboard,
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successGreen,
              ),
              child: Text(_fromRegistration ? 'CONTINUER' : 'ACCÉDER À MON COMPTE'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Récapitulatif de la commande',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Abonnement'),
                        Text(_selectedSubscription),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Montant'),
                        Text('$_amount FCFA'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Méthode de paiement',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            // ... rest of the payment UI
          ],
        ),
      ),
    );
  }

  void _showTermsDialog(String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(type == 'CGU'
            ? 'Conditions Générales d\'Utilisation'
            : 'Conditions Générales de Vente'),
        content: SingleChildScrollView(
          child: Text(
            type == 'CGU'
                ? 'Les conditions générales d\'utilisation de DocteurCardio...\n\n'
                    '1. Acceptation des conditions\n'
                    '2. Description du service\n'
                    '3. Compte utilisateur\n'
                    '4. Confidentialité des données\n'
                    '5. Responsabilités\n\n'
                    '[Texte complet à intégrer]'
                : 'Les conditions générales de vente de DocteurCardio...\n\n'
                    '1. Prix et facturation\n'
                    '2. Modalités de paiement\n'
                    '3. Résiliation\n'
                    '4. Remboursement\n\n'
                    '[Texte complet à intégrer]',
            style: const TextStyle(fontSize: 14),
          ),
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
}
