class AppRoutes {
  // Routes communes
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String profileChoice = '/profile-choice';

  // Routes d'authentification
  static const String patientLogin = '/patient/login';
  static const String patientRegister = '/patient/register';
  static const String doctorLogin = '/doctor/login';
  static const String doctorRegister = '/doctor/register';
  static const String payment = '/payment';

  // Routes récupération mot de passe
  static const String patientForgotPassword = '/patient/forgot-password';
  static const String patientVerifyOtp = '/patient/verify-otp';
  static const String patientResetPassword = '/patient/reset-password';

  static const String doctorForgotPassword = '/doctor/forgot-password';
  static const String doctorVerifyOtp = '/doctor/verify-otp';
  static const String doctorResetPassword = '/doctor/reset-password';

  // Routes Patient
  static const String patientDashboard = '/patient/dashboard';
  static const String recordPressurePhoto = '/patient/record-photo';
  static const String recordPressureManual = '/patient/record-manual';
  static const String addContext = '/patient/add-context';
  static const String patientHistory = '/patient/history';
  static const String measureDetail = '/patient/measure-detail';
  static const String patientMessages = '/patient/messages';
  static const String patientChat = '/patient/chat';
  static const String patientDocuments = '/patient/documents';
  static const String teleconsultation = '/patient/teleconsultation';
  static const String patientProfile = '/patient/profile';
  static const String patientEditProfile = '/patient/edit-profile';
  static const String patientNotifications = '/patient/notifications';
  static const String patientSettings = '/patient/settings';

  // Routes Cardiologue
  static const String doctorDashboard = '/doctor/dashboard';
  static const String doctorProfile = '/doctor/profile';
  static const String doctorEditProfile = '/doctor/edit-profile';
  static const String doctorPatients = '/doctor/patients';
  static const String patientFile = '/doctor/patient-file';
  static const String patientFullHistory = '/doctor/patient-history';
  static const String doctorMessages = '/doctor/messages';
  static const String doctorChat = '/doctor/chat';
  static const String doctorRevenue = '/doctor/revenue';
  static const String doctorNotificationsSettings = '/doctor/notifications-settings';
  static const String doctorConsultationHours = '/doctor/consultation-hours';

  // Routes Administrateur
  static const String adminLogin = '/admin/login';
  static const String adminDashboard = '/admin/dashboard';

  // Routes utilitaires
  static const String qrScanner = '/qr-scanner';
  static const String alertDialog = '/alert';
  static const String offlineMode = '/offline';
  static const String helpSupport = '/help-support';
  static const String termsPrivacy = '/terms-privacy';
}
