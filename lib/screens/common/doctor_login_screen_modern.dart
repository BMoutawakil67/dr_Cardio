import 'package:flutter/material.dart';
import 'package:dr_cardio/routes/app_routes.dart';
import 'package:dr_cardio/config/app_theme.dart';
import 'package:dr_cardio/widgets/animations/animated_widgets.dart';
import 'package:dr_cardio/repositories/doctor_repository.dart';
import 'package:dr_cardio/services/auth_service.dart';
import 'package:dr_cardio/services/biometric_auth_service.dart';
import 'package:local_auth/local_auth.dart';

class DoctorLoginScreenModern extends StatefulWidget {
  const DoctorLoginScreenModern({super.key});

  @override
  State<DoctorLoginScreenModern> createState() => _DoctorLoginScreenModernState();
}

class _DoctorLoginScreenModernState extends State<DoctorLoginScreenModern> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _orderNumberController = TextEditingController();
  final BiometricAuthService _biometricAuthService = BiometricAuthService();
  final DoctorRepository _doctorRepository = DoctorRepository();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _isBiometricAvailable = false;
  List<BiometricType> _availableBiometrics = [];

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    final isAvailable = await _biometricAuthService.isBiometricAvailable();
    final biometrics = await _biometricAuthService.getAvailableBiometrics();

    if (mounted) {
      setState(() {
        _isBiometricAvailable = isAvailable && biometrics.isNotEmpty;
        _availableBiometrics = biometrics;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _orderNumberController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Simuler connexion
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅ Connexion réussie'),
          backgroundColor: AppTheme.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      Navigator.pushReplacementNamed(context, AppRoutes.doctorDashboard);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur: $e'),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleBiometricLogin() async {
    if (!_isBiometricAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('❌ Authentification biométrique non disponible sur cet appareil'),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Authentifier avec biométrie
      final authenticated = await _biometricAuthService.authenticate(
        reason: 'Authentifiez-vous pour accéder à votre compte cardiologue',
      );

      if (!authenticated) {
        throw Exception('Authentification échouée');
      }

      // Récupérer le premier cardiologue de la liste
      final doctors = await _doctorRepository.getAllDoctors();

      if (doctors.isEmpty) {
        throw Exception('Aucun cardiologue trouvé');
      }

      final firstDoctor = doctors.first;

      if (!mounted) return;

      // Se connecter avec le premier cardiologue
      AuthService().login(firstDoctor.id, 'doctor');

      // Activer l'authentification biométrique pour les prochaines fois
      if (_isBiometricAvailable) {
        await _biometricAuthService.enableBiometricAuth(firstDoctor.id, 'doctor');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Bienvenue Dr. ${firstDoctor.firstName}!'),
          backgroundColor: AppTheme.successGreen,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      Navigator.pushReplacementNamed(context, AppRoutes.doctorDashboard);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: AppTheme.errorRed,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.secondaryRed,
              AppTheme.secondaryRed.withOpacity(0.8),
              const Color(0xFFD32F2F),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Bouton retour
                  FadeInSlideUp(
                    delay: 0,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Logo avec animation pulse
                  FadeInSlideUp(
                    delay: 200,
                    child: PulseAnimation(
                      duration: const Duration(seconds: 3),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.medical_services,
                          size: 60,
                          color: AppTheme.secondaryRed,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Titre
                  FadeInSlideUp(
                    delay: 400,
                    child: Text(
                      'Espace Professionnel',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Sous-titre
                  FadeInSlideUp(
                    delay: 600,
                    child: Text(
                      'Connectez-vous à votre compte cardiologue',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Email professionnel
                  FadeInSlideUp(
                    delay: 800,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.email_outlined, color: Colors.white70),
                          labelText: 'Email professionnel',
                          labelStyle: TextStyle(color: Colors.white70),
                          hintText: 'dr.nom@hopital.com',
                          hintStyle: TextStyle(color: Colors.white38),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre email professionnel';
                          }
                          if (!value.contains('@')) {
                            return 'Email invalide';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Numéro d'ordre
                  FadeInSlideUp(
                    delay: 1000,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextFormField(
                        controller: _orderNumberController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.badge_outlined, color: Colors.white70),
                          labelText: 'Numéro d\'ordre (optionnel)',
                          labelStyle: TextStyle(color: Colors.white70),
                          hintText: 'ex: 12345',
                          hintStyle: TextStyle(color: Colors.white38),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Mot de passe
                  FadeInSlideUp(
                    delay: 1200,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
                          labelText: 'Mot de passe',
                          labelStyle: const TextStyle(color: Colors.white70),
                          border: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.white70,
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
                            return 'Veuillez entrer votre mot de passe';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Se souvenir de moi & Mot de passe oublié
                  FadeInSlideUp(
                    delay: 1400,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                              fillColor: MaterialStateProperty.all(Colors.white),
                              checkColor: AppTheme.secondaryRed,
                            ),
                            const Text(
                              'Se souvenir',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.doctorForgotPassword);
                          },
                          child: const Text(
                            'Mot de passe oublié?',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Bouton connexion
                  FadeInSlideUp(
                    delay: 1600,
                    child: PressableButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Center(
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppTheme.secondaryRed,
                                    ),
                                  ),
                                )
                              : Text(
                                  'SE CONNECTER',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.secondaryRed,
                                      ),
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Biométrie
                  if (_isBiometricAvailable)
                    FadeInSlideUp(
                      delay: 1600,
                      child: PressableButton(
                        onPressed: _isLoading ? null : _handleBiometricLogin,
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 2),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.fingerprint, color: Colors.white, size: 28),
                              SizedBox(width: 12),
                              Text(
                                'Connexion biométrique',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Lien inscription
                  FadeInSlideUp(
                    delay: 1800,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Pas encore inscrit? ',
                          style: TextStyle(color: Colors.white70),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.doctorRegister);
                          },
                          child: const Text(
                            'Créer un compte',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
