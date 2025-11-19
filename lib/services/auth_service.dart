/// Service simple pour gérer l'authentification et l'utilisateur connecté
/// Stocke l'ID de l'utilisateur connecté en mémoire
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  String? _currentUserId;
  String? _currentUserType; // 'patient' ou 'doctor'

  /// Connecter un utilisateur
  void login(String userId, String userType) {
    _currentUserId = userId;
    _currentUserType = userType;
  }

  /// Déconnecter l'utilisateur
  void logout() {
    _currentUserId = null;
    _currentUserType = null;
  }

  /// Obtenir l'ID de l'utilisateur connecté
  String? get currentUserId => _currentUserId;

  /// Obtenir le type d'utilisateur connecté
  String? get currentUserType => _currentUserType;

  /// Vérifier si un utilisateur est connecté
  bool get isLoggedIn => _currentUserId != null;

  /// Vérifier si l'utilisateur connecté est un patient
  bool get isPatient => _currentUserType == 'patient';

  /// Vérifier si l'utilisateur connecté est un docteur
  bool get isDoctor => _currentUserType == 'doctor';
}
