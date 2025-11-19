import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricAuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Vérifie si l'appareil supporte l'authentification biométrique
  Future<bool> isBiometricAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics || await _localAuth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  /// Récupère la liste des biométries disponibles sur l'appareil
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException {
      return <BiometricType>[];
    }
  }

  /// Authentifie l'utilisateur via biométrie
  Future<bool> authenticateWithBiometrics({
    required String reason,
  }) async {
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      return didAuthenticate;
    } on PlatformException catch (e) {
      print('Erreur d\'authentification biométrique: ${e.message}');
      return false;
    }
  }

  /// Active l'authentification biométrique pour un utilisateur
  Future<void> enableBiometricAuth(String userId, String userType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled_$userId', true);
    await prefs.setString('biometric_user_type_$userId', userType);
    await prefs.setString('last_biometric_user', userId);
  }

  /// Désactive l'authentification biométrique pour un utilisateur
  Future<void> disableBiometricAuth(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('biometric_enabled_$userId');
    await prefs.remove('biometric_user_type_$userId');
  }

  /// Vérifie si l'authentification biométrique est activée pour un utilisateur
  Future<bool> isBiometricEnabled(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('biometric_enabled_$userId') ?? false;
  }

  /// Récupère l'ID du dernier utilisateur ayant utilisé la biométrie
  Future<String?> getLastBiometricUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('last_biometric_user');
  }

  /// Récupère le type d'utilisateur (patient/doctor) pour un userId donné
  Future<String?> getUserType(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('biometric_user_type_$userId');
  }

  /// Authentification complète avec stockage des préférences
  Future<Map<String, dynamic>?> authenticateAndGetUserInfo() async {
    final userId = await getLastBiometricUserId();

    if (userId == null) {
      return null;
    }

    final isEnabled = await isBiometricEnabled(userId);
    if (!isEnabled) {
      return null;
    }

    final didAuthenticate = await authenticateWithBiometrics(
      reason: 'Authentifiez-vous pour accéder à votre compte',
    );

    if (!didAuthenticate) {
      return null;
    }

    final userType = await getUserType(userId);

    return {
      'userId': userId,
      'userType': userType,
    };
  }

  /// Affiche un message selon le type de biométrie disponible
  String getBiometricTypeMessage(List<BiometricType> types) {
    if (types.contains(BiometricType.face)) {
      return 'Connexion par reconnaissance faciale';
    } else if (types.contains(BiometricType.fingerprint)) {
      return 'Connexion par empreinte digitale';
    } else if (types.contains(BiometricType.iris)) {
      return 'Connexion par reconnaissance de l\'iris';
    } else if (types.contains(BiometricType.strong) || types.contains(BiometricType.weak)) {
      return 'Connexion biométrique';
    }
    return 'Connexion biométrique';
  }

  /// Obtient l'icône appropriée selon le type de biométrie
  String getBiometricIcon(List<BiometricType> types) {
    if (types.contains(BiometricType.face)) {
      return '🔐'; // Face ID
    } else if (types.contains(BiometricType.fingerprint)) {
      return '👆'; // Fingerprint
    } else if (types.contains(BiometricType.iris)) {
      return '👁️'; // Iris
    }
    return '🔒'; // Default
  }
}
