import 'package:flutter/material.dart';
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
        // Si c'est un upgrade (fromRegistration = false), payer la différence
        // Sinon (nouvelle inscription), payer le montant complet
        _amount = _fromRegistration ? 10000 : 5000; // Différence = 10000 - 5000 = 5000
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
                  // Sinon, retourner true pour indiquer que le paiement est réussi
                  Navigator.pop(context, true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successGreen,
              ),
              child: Text(_fromRegistration ? 'CONTINUER' : 'RETOUR AU PROFIL'),
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

            // MTN Mobile Money
            _buildPaymentMethodCard(
              'mtn',
              '📱 MTN Mobile Money',
              Icons.phone_android,
              const Color(0xFFFFCC00),
            ),
            const SizedBox(height: 12),

            // Moov Money
            _buildPaymentMethodCard(
              'moov',
              '📱 Moov Money',
              Icons.phone_android,
              const Color(0xFF009FE3),
            ),
            const SizedBox(height: 12),

            // Carte bancaire
            _buildPaymentMethodCard(
              'card',
              '💳 Carte bancaire',
              Icons.credit_card,
              AppTheme.primaryBlue,
            ),
            const SizedBox(height: 24),

            // Champs de saisie selon le mode sélectionné
            if (_selectedPaymentMethod == 'mtn' || _selectedPaymentMethod == 'moov')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Numéro de téléphone',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: '+229 XX XX XX XX',
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),

            if (_selectedPaymentMethod == 'card')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informations de la carte',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _cardNumberController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '1234 5678 9012 3456',
                      labelText: 'Numéro de carte',
                      prefixIcon: const Icon(Icons.credit_card),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _cardExpiryController,
                          keyboardType: TextInputType.datetime,
                          decoration: InputDecoration(
                            hintText: 'MM/AA',
                            labelText: 'Expiration',
                            prefixIcon: const Icon(Icons.calendar_today),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _cardCvvController,
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'CVV',
                            labelText: 'CVV',
                            prefixIcon: const Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),

            // Renouvellement automatique
            CheckboxListTile(
              value: _autoRenewal,
              onChanged: (value) {
                setState(() {
                  _autoRenewal = value ?? true;
                });
              },
              title: const Text('Renouvellement automatique'),
              subtitle: const Text('Votre abonnement sera renouvelé chaque mois'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 16),

            // CGU
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'En payant, vous acceptez les ',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => _showTermsDialog('CGU'),
                  child: const Text('CGU', style: TextStyle(decoration: TextDecoration.underline)),
                ),
                Text(' et ', style: Theme.of(context).textTheme.bodySmall),
                TextButton(
                  onPressed: () => _showTermsDialog('CGV'),
                  child: const Text('CGV', style: TextStyle(decoration: TextDecoration.underline)),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Bouton de paiement
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'PAYER $_amount FCFA',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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

  Widget _buildPaymentMethodCard(
    String methodId,
    String title,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedPaymentMethod == methodId;

    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPaymentMethod = methodId;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryBlue,
                ),
            ],
          ),
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
