import 'package:flutter/material.dart';
import 'package:dr_cardio/routes/app_routes.dart';
import 'package:dr_cardio/repositories/patient_repository.dart';
import 'package:dr_cardio/config/app_theme.dart';
import 'package:dr_cardio/services/auth_service.dart';
import 'package:dr_cardio/services/biometric_auth_service.dart';
import 'package:dr_cardio/widgets/animations/animated_widgets.dart';
import 'package:local_auth/local_auth.dart';

/// Écran de connexion patient modernisé
/// Inspiré de Reflectly avec animations fluides et design épuré
class PatientLoginScreenModern extends StatefulWidget {
  const PatientLoginScreenModern({super.key});

  @override
  State<PatientLoginScreenModern> createState() => _PatientLoginScreenModernState();
}

class _PatientLoginScreenModernState extends State<PatientLoginScreenModern> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final BiometricAuthService _biometricAuthService = BiometricAuthService();
  bool _obscurePassword = true;
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

      // Si l'utilisateur a déjà enregistré ses empreintes, proposer automatiquement
      if (_isBiometricAvailable) {
        final lastUserId = await _biometricAuthService.getLastBiometricUserId();
        if (lastUserId != null) {
          final isEnabled = await _biometricAuthService.isBiometricEnabled(lastUserId);
          if (isEnabled) {
            // Attendre un petit moment pour que l'UI se charge
            await Future.delayed(const Duration(milliseconds: 500));
            if (mounted) {
              _handleBiometricLogin();
            }
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repository = PatientRepository();
      final patients = await repository.getAllPatients();

      final email = _emailController.text.trim();
      final patient = patients.firstWhere(
        (p) => p.email.toLowerCase() == email.toLowerCase() ||
               p.phoneNumber == email,
        orElse: () => throw Exception('Aucun compte trouvé avec cet email/téléphone'),
      );

      if (!mounted) return;

      AuthService().login(patient.id, 'patient');

      // Activer l'authentification biométrique pour les prochaines fois
      if (_isBiometricAvailable) {
        await _biometricAuthService.enableBiometricAuth(patient.id, 'patient');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Bienvenue ${patient.firstName}!'),
          backgroundColor: AppTheme.successGreen,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      Navigator.pushReplacementNamed(context, AppRoutes.patientDashboard);
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
      final userInfo = await _biometricAuthService.authenticateAndGetUserInfo();

      if (userInfo == null) {
        throw Exception('Authentification échouée');
      }

      final userId = userInfo['userId'] as String;
      final userType = userInfo['userType'] as String?;

      if (userType != 'patient') {
        throw Exception('Ce compte n\'est pas un compte patient');
      }

      if (!mounted) return;

      // Récupérer les informations du patient
      final repository = PatientRepository();
      final patient = await repository.getPatient(userId);

      if (patient == null) {
        throw Exception('Compte introuvable');
      }

      if (!mounted) return;

      AuthService().login(patient.id, 'patient');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Bienvenue ${patient.firstName}!'),
          backgroundColor: AppTheme.successGreen,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      Navigator.pushReplacementNamed(context, AppRoutes.patientDashboard);
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
              AppTheme.primaryBlue,
              AppTheme.primaryBlue.withOpacity(0.8),
              const Color(0xFF1976D2),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Bouton retour
                  Align(
                    alignment: Alignment.topLeft,
                    child: FadeInSlideUp(
                      delay: 0,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
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
                      minScale: 0.98,
                      maxScale: 1.02,
                      child: Image.asset(
                        'assets/images/logoBase.png',
                        width: 120,
                        height: 120,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Titre
                  FadeInSlideUp(
                    delay: 400,
                    child: const Text(
                      'Bonjour',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  FadeInSlideUp(
                    delay: 600,
                    child: Text(
                      'Connectez-vous à votre compte',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),

                  // Champ Email
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
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email_outlined, color: Colors.white70),
                          labelText: 'Email ou Téléphone',
                          labelStyle: const TextStyle(color: Colors.white70),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre email';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Champ Mot de passe
                  FadeInSlideUp(
                    delay: 1000,
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
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
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

                  const SizedBox(height: 16),

                  // Mot de passe oublié
                  FadeInSlideUp(
                    delay: 1200,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.patientForgotPassword,
                            arguments: {'userType': 'patient'},
                          );
                        },
                        child: Text(
                          'Mot de passe oublié?',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Bouton Se connecter
                  FadeInSlideUp(
                    delay: 1400,
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
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppTheme.primaryBlue,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'SE CONNECTER',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryBlue,
                                    letterSpacing: 1,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

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

                  const SizedBox(height: 40),

                  // S'inscrire
                  FadeInSlideUp(
                    delay: 1800,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.patientRegister);
                      },
                      child: Text(
                        'PAS ENCORE DE COMPTE? S\'INSCRIRE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.9),
                          letterSpacing: 0.5,
                        ),
                      ),
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
