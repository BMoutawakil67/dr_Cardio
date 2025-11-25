import 'package:flutter/material.dart';
import 'package:dr_cardio/config/app_theme.dart';
import 'package:dr_cardio/routes/app_routes.dart';
import 'package:dr_cardio/models/patient_model.dart';
import 'package:dr_cardio/repositories/patient_repository.dart';
import 'package:dr_cardio/widgets/animations/animated_widgets.dart';
import 'package:uuid/uuid.dart';

class PatientRegisterScreen extends StatefulWidget {
  const PatientRegisterScreen({super.key});

  @override
  State<PatientRegisterScreen> createState() => _PatientRegisterScreenState();
}

class _PatientRegisterScreenState extends State<PatientRegisterScreen> {
  final _pageController = PageController();
  int _currentStep = 0;

  // Étape 1 - Informations de base
  final _formKey1 = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  DateTime? _birthDate;
  String? _selectedGender;

  // Étape 2 - Sécurité
  final _formKey2 = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _enableBiometric = true;

  // Étape 3 - Choix de l'abonnement
  String? _selectedSubscription;

  // Étape 3.5 - Paiement (pour standard et premium)
  String _selectedPaymentMethod = 'mtn';
  final _paymentPhoneController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCvvController = TextEditingController();

  // Étape 4 - Choix du cardiologue
  String? _selectedDoctor;
  final _searchController = TextEditingController();

  // Ancien - Abonnement (gardé pour compatibilité)
  String _selectedPlan = 'standard';

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _paymentPhoneController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentStep = index;
    });
  }

  void _handleNext() {
    // This method will be called by the 'SUIVANT' buttons in Step 1 and 2
    if (_currentStep == 0) {
      // After Personal Info
      if (_formKey1.currentState!.validate()) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else if (_currentStep == 1) {
      // After Security
      if (_formKey2.currentState!.validate()) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
    // Navigation from Step 3 (Subscription) is handled directly in the card buttons.
    // Navigation from Step 4 (Cardiologist) is handled directly in its selection button.
  }

  void _handleBack() {
    if (_currentStep > 0) {
      // Prevent going back from cardiologist step if payment was made.
      // This logic will be more robust once payment screen is fully integrated.
      if (_currentStep == 3 &&
          (_selectedSubscription == 'standard' ||
              _selectedSubscription == 'premium')) {
        // Potentially show a dialog confirming they want to change subscription.
        // For now, we allow it.
        _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else if (_currentStep != 3) {
        _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _createAccount() async {
    // Split name into firstName and lastName
    final nameParts = _nameController.text.trim().split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    // Create a Patient object with the collected data
    final patient = Patient(
      id: const Uuid().v4(), // Generate unique UUID
      firstName: firstName,
      lastName: lastName,
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      birthDate: _birthDate!,
      gender: _selectedGender ?? '',
      profileImageUrl: null,
    );

    try {
      // Save patient to Hive database
      final repository = PatientRepository();
      await repository.addPatient(patient);

      debugPrint('✅ Account created for: ${patient.firstName} ${patient.lastName}');
      debugPrint('   Email: ${patient.email}');
      debugPrint('   ID: ${patient.id}');
      debugPrint('   Subscription: $_selectedSubscription');
      debugPrint('   Doctor: $_selectedDoctor');

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Compte créé avec succès! Connectez-vous maintenant.'),
          backgroundColor: AppTheme.successGreen,
          duration: const Duration(seconds: 3),
        ),
      );

      // Navigate to login screen
      Navigator.pushReplacementNamed(context, AppRoutes.patientLogin);
    } catch (e) {
      debugPrint('❌ Error creating account: $e');

      if (!mounted) return;

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur lors de la création du compte: $e'),
          backgroundColor: AppTheme.errorRed,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate total steps dynamically (5 if paid plan, 3 if free)
    int totalSteps = _selectedSubscription == 'free' ? 3 : 5;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription Patient'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleBack,
        ),
      ),
      body: Column(
        children: [
          // Indicateur de progression
          LinearProgressIndicator(
            value: (_currentStep + 1) / totalSteps,
            backgroundColor: Colors.grey.shade200,
          ),
          // PageView pour les étapes
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1(),
                _buildStep2(),
                _buildSubscriptionStep(),
                _buildPaymentStep(),
                _buildStep3(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ÉTAPE 1 - Informations personnelles
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FadeInSlideUp(
              delay: 0,
              child: Text(
                'Créez votre compte',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),

            // Nom complet
            FadeInSlideUp(
              delay: 200,
              child: TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person_outline),
                labelText: 'Nom complet',
                hintText: 'Jean Dupont',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre nom';
                }
                return null;
              },
              ),
            ),
            const SizedBox(height: 16),

            // Email
            FadeInSlideUp(
              delay: 400,
              child: TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.email_outlined),
                labelText: 'Email',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre email';
                }
                if (!value.contains('@')) {
                  return 'Email invalide';
                }
                return null;
              },
              ),
            ),
            const SizedBox(height: 16),

            // Téléphone
            FadeInSlideUp(
              delay: 600,
              child: TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.phone_outlined),
                labelText: 'Téléphone',
                hintText: '+229',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre téléphone';
                }
                return null;
              },
              ),
            ),
            const SizedBox(height: 16),

            // Adresse
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.location_on_outlined),
                labelText: 'Adresse',
                hintText: 'Rue, Ville, Pays',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre adresse';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Genre
            DropdownButtonFormField<String>(
              initialValue: _selectedGender,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person_outline),
                labelText: 'Genre',
              ),
              items: const [
                DropdownMenuItem(value: 'Homme', child: Text('Homme')),
                DropdownMenuItem(value: 'Femme', child: Text('Femme')),
                DropdownMenuItem(value: 'Autre', child: Text('Autre')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez sélectionner votre genre';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Date de naissance
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime(2000),
                  firstDate: DateTime(1920),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _birthDate = date;
                  });
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                  labelText: 'Date de naissance',
                ),
                child: Text(
                  _birthDate != null
                      ? '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}'
                      : 'Sélectionner',
                  style: TextStyle(
                    color: _birthDate != null ? null : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Bouton Suivant
            ElevatedButton(
              onPressed: () {
                if (_formKey1.currentState!.validate() && _birthDate != null) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } else if (_birthDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Veuillez sélectionner votre date de naissance'),
                    ),
                  );
                }
              },
              child: const Text('SUIVANT'),
            ),
          ],
        ),
      ),
    );
  }

  // ÉTAPE 2 - Sécurité
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Sécurisez votre compte',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Mot de passe
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline),
                labelText: 'Mot de passe',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un mot de passe';
                }
                if (value.length < 8) {
                  return 'Au moins 8 caractères';
                }
                if (!value.contains(RegExp(r'[A-Z]'))) {
                  return 'Au moins une majuscule';
                }
                if (!value.contains(RegExp(r'[0-9]'))) {
                  return 'Au moins un chiffre';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),

            // Critères de mot de passe
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPasswordCriterion('• Au moins 8 caractères',
                      _passwordController.text.length >= 8),
                  _buildPasswordCriterion('• Une majuscule',
                      _passwordController.text.contains(RegExp(r'[A-Z]'))),
                  _buildPasswordCriterion('• Un chiffre',
                      _passwordController.text.contains(RegExp(r'[0-9]'))),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Confirmer mot de passe
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline),
                labelText: 'Confirmer',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value != _passwordController.text) {
                  return 'Les mots de passe ne correspondent pas';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Activer Face ID
            CheckboxListTile(
              value: _enableBiometric,
              onChanged: (value) {
                setState(() {
                  _enableBiometric = value ?? true;
                });
              },
              title: const Text('Activer Face ID'),
              subtitle: const Text('(recommandé)'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 32),

            // Bouton Suivant
            ElevatedButton(
              onPressed: () {
                if (_formKey2.currentState!.validate()) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: const Text('SUIVANT'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordCriterion(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: isMet ? AppTheme.successGreen : Colors.grey.shade600,
        ),
      ),
    );
  }

  // ÉTAPE 3 - CHOIX DE L'ABONNEMENT
  Widget _buildSubscriptionStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Choisissez votre formule',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildSubscriptionCard(
            planId: 'free',
            badge: 'GRATUIT',
            badgeColor: Colors.green,
            price: '0 FCFA/mois',
            features: [
              'Enregistrement manuel',
              'Historique limité (30 jours)',
              'Sans cardiologue attitré',
            ],
            buttonText: 'Choisir Gratuit',
          ),
          const SizedBox(height: 16),
          _buildSubscriptionCard(
            planId: 'standard',
            badge: 'POPULAIRE',
            badgeColor: Colors.blue,
            price: '5000 FCFA/mois',
            features: [
              'Photo tensiomètre',
              'Historique complet',
              '1 cardiologue attitré',
              'Messagerie',
            ],
            buttonText: 'Choisir Standard',
          ),
          const SizedBox(height: 16),
          _buildSubscriptionCard(
            planId: 'premium',
            badge: 'COMPLET',
            badgeColor: Colors.amber,
            price: '10000 FCFA/mois',
            features: [
              'Tout Standard +',
              'Téléconsultation',
              'Rapports avancés',
              'Support prioritaire',
            ],
            buttonText: 'Choisir Premium',
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard({
    required String planId,
    required String badge,
    required Color badgeColor,
    required String price,
    required List<String> features,
    required String buttonText,
  }) {
    final isSelected = _selectedSubscription == planId;

    return Card(
      elevation: isSelected ? 6 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              price,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ...features.map((feature) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check,
                          color: AppTheme.successGreen, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(feature)),
                    ],
                  ),
                )),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedSubscription = planId;
                });
                // Handle navigation after selection
                if (planId == 'free') {
                  // For free plan, we can directly create the account
                  _createAccount();
                } else {
                  // For paid plans, move to the next step (payment)
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isSelected ? Theme.of(context).colorScheme.primary : null,
              ),
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }

  // ÉTAPE 3.5 - Paiement (pour standard et premium)
  Widget _buildPaymentStep() {
    // Calculate amount based on subscription
    int amount = _selectedSubscription == 'standard' ? 5000 : 10000;
    String planName = _selectedSubscription == 'standard' ? 'STANDARD' : 'PREMIUM';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Paiement',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Récapitulatif de la commande
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
                      const Text('Abonnement'),
                      Text(planName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Montant'),
                      Text('$amount FCFA', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Méthode de paiement
          Text(
            'Méthode de paiement',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // Mobile Money Options
          _buildPaymentMethodCard(
            'mtn',
            'MTN Money',
            Icons.phone_android,
            AppTheme.warningOrange,
          ),
          const SizedBox(height: 12),
          _buildPaymentMethodCard(
            'moov',
            'Moov Money',
            Icons.phone_android,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildPaymentMethodCard(
            'card',
            'Carte bancaire',
            Icons.credit_card,
            AppTheme.greyDark,
          ),
          const SizedBox(height: 24),

          // Payment form based on selected method
          if (_selectedPaymentMethod == 'mtn' || _selectedPaymentMethod == 'moov')
            TextFormField(
              controller: _paymentPhoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.phone),
                labelText: 'Numéro de téléphone',
                hintText: _selectedPaymentMethod == 'mtn' ? 'Ex: 96 XX XX XX' : 'Ex: 97 XX XX XX',
              ),
            ),

          if (_selectedPaymentMethod == 'card') ...[
            TextFormField(
              controller: _cardNumberController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.credit_card),
                labelText: 'Numéro de carte',
                hintText: '1234 5678 9012 3456',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cardExpiryController,
                    keyboardType: TextInputType.datetime,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.calendar_today),
                      labelText: 'Expiration',
                      hintText: 'MM/AA',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _cardCvvController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      labelText: 'CVV',
                      hintText: '123',
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 32),

          // Bouton Payer
          ElevatedButton(
            onPressed: _processPayment,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text('PAYER $amount FCFA'),
          ),
        ],
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
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
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
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    // Validation selon le mode de paiement
    if ((_selectedPaymentMethod == 'mtn' || _selectedPaymentMethod == 'moov') &&
        _paymentPhoneController.text.isEmpty) {
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
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    Navigator.pop(context); // Fermer le dialog de traitement

    // Afficher le dialog de succès
    _showPaymentSuccessDialog();
  }

  void _showPaymentSuccessDialog() {
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
              'Votre abonnement ${_selectedSubscription?.toUpperCase()} a été activé.\nVous pouvez maintenant choisir votre cardiologue.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Fermer le dialog
                // Continue to next step (cardiologist selection)
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successGreen,
              ),
              child: const Text('CONTINUER'),
            ),
          ],
        ),
      ),
    );
  }

  // ÉTAPE 4 - Choix du cardiologue
  Widget _buildStep3() {
    final doctors = [
      {
        'name': 'Dr. Kouassi Jean',
        'specialty': 'Cardiologue',
        'rating': 4.8,
        'reviews': 125,
        'location': 'Cotonou, Bénin',
      },
      {
        'name': 'Dr. Amina Diallo',
        'specialty': 'Cardiologue',
        'rating': 4.9,
        'reviews': 98,
        'location': 'Porto-Novo, Bénin',
      },
      {
        'name': 'Dr. Mensah Paul',
        'specialty': 'Cardiologue',
        'rating': 4.7,
        'reviews': 156,
        'location': 'Lomé, Togo',
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Sélectionnez votre cardiologue',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Barre de recherche
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Rechercher...',
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Options de recherche
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildSearchOption(
                  Icons.location_on_outlined, 'Par localisation'),
              _buildSearchOption(Icons.local_hospital_outlined, 'Par hôpital'),
              _buildSearchOption(Icons.qr_code_scanner, 'Scanner QR Code'),
            ],
          ),
          const SizedBox(height: 16),

          // Passer
          TextButton.icon(
            onPressed: () {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            icon: const Icon(Icons.skip_next),
            label: const Text('Sans cardiologue (passer)'),
          ),
          const SizedBox(height: 24),

          // Liste des cardiologues
          ...doctors.map((doctor) => _buildDoctorCard(
                doctor['name'] as String,
                doctor['specialty'] as String,
                doctor['rating'] as double,
                doctor['reviews'] as int,
                doctor['location'] as String,
              )),
        ],
      ),
    );
  }

  Widget _buildSearchOption(IconData icon, String label) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildDoctorCard(
    String name,
    String specialty,
    double rating,
    int reviews,
    String location,
  ) {
    final isSelected = _selectedDoctor == name;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        specialty,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text('$rating ($reviews avis)'),
                const Spacer(),
                const Icon(Icons.location_on_outlined, size: 16),
                const SizedBox(width: 4),
                Expanded(
                    child:
                        Text(location, style: const TextStyle(fontSize: 12))),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedDoctor = name;
                  });
                  _createAccount();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isSelected ? Theme.of(context).colorScheme.primary : null,
                ),
                child: const Text('SÉLECTIONNER'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ÉTAPE 4 - Abonnement
  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Choisissez votre forfait',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Plan Standard
          _buildPlanCard(
            'standard',
            '📦 STANDARD',
            '3000 F CFA / mois',
            [
              'Suivi tension',
              'Messagerie',
              'Alertes automatiques',
              'Graphiques',
            ],
          ),
          const SizedBox(height: 16),

          // Plan Premium
          _buildPlanCard(
            'premium',
            '🌟 PREMIUM',
            '5000 F CFA / mois',
            [
              'Tout Standard +',
              'Téléconsultation',
              'Conseils IA',
              'Support prioritaire',
            ],
          ),
          const SizedBox(height: 32),

          // Bouton Continuer vers paiement
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.payment);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('CONTINUER VERS PAIEMENT'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
      String planId, String title, String price, List<String> features) {
    final isSelected = _selectedPlan == planId;

    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPlan = planId;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                price,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 16),
              ...features.map((feature) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.check,
                            color: AppTheme.successGreen, size: 20),
                        const SizedBox(width: 8),
                        Text(feature),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
