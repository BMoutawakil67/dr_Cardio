import 'package:dr_cardio/data/local/hive_database.dart';
import 'package:dr_cardio/services/mock/mock_service.dart';
import 'package:flutter/material.dart';
import 'package:dr_cardio/config/app_theme.dart';
import 'package:dr_cardio/routes/app_routes.dart';

// Écrans communs
import 'package:dr_cardio/screens/common/splash_screen.dart';
import 'package:dr_cardio/screens/common/onboarding_screen.dart';
import 'package:dr_cardio/screens/common/profile_choice_screen.dart';
import 'package:dr_cardio/screens/common/patient_login_screen_modern.dart';
import 'package:dr_cardio/screens/common/doctor_login_screen.dart';
import 'package:dr_cardio/screens/common/patient_register_screen.dart';
import 'package:dr_cardio/screens/common/payment_screen.dart';
import 'package:dr_cardio/screens/common/notifications_screen.dart';

// Écrans Patient
import 'package:dr_cardio/screens/patient/patient_dashboard_screen.dart';
import 'package:dr_cardio/screens/patient/record_pressure_manual_screen.dart';
import 'package:dr_cardio/screens/patient/record_pressure_photo_screen.dart';
import 'package:dr_cardio/screens/patient/add_context_screen.dart';
import 'package:dr_cardio/screens/patient/patient_history_screen.dart';
import 'package:dr_cardio/screens/patient/measure_detail_screen.dart';
import 'package:dr_cardio/screens/patient/patient_messages_screen.dart';
import 'package:dr_cardio/screens/patient/patient_chat_screen.dart';
import 'package:dr_cardio/screens/patient/patient_profile_screen.dart';
import 'package:dr_cardio/screens/patient/patient_settings_screen.dart';
import 'package:dr_cardio/screens/patient/patient_documents_screen.dart';

// Écrans Cardiologue
import 'package:dr_cardio/screens/doctor/doctor_dashboard_screen.dart';
import 'package:dr_cardio/screens/doctor/doctor_patients_screen.dart';
import 'package:dr_cardio/screens/doctor/doctor_patient_file_screen.dart';
import 'package:dr_cardio/screens/doctor/doctor_profile_screen.dart';
import 'package:dr_cardio/screens/doctor/doctor_messages_screen.dart';
import 'package:dr_cardio/screens/doctor/doctor_chat_screen.dart';
import 'package:dr_cardio/screens/doctor/doctor_patient_history_screen.dart';
import 'package:dr_cardio/screens/doctor/doctor_revenue_screen.dart';
import 'package:dr_cardio/screens/common/teleconsultation_screen.dart';
import 'package:dr_cardio/screens/admin/admin_dashboard_screen.dart';
import 'package:dr_cardio/screens/patient/patient_edit_profile_screen.dart';
import 'package:dr_cardio/screens/doctor/doctor_edit_profile_screen.dart';

import 'package:dr_cardio/screens/common/forgot_password_screen.dart';
import 'package:dr_cardio/screens/common/reset_password_screen.dart';
import 'package:dr_cardio/screens/common/verify_otp_screen.dart';

// Services
import 'package:dr_cardio/services/unified_connectivity_service.dart';
import 'package:dr_cardio/screens/common/offline_mode_screen.dart';

// Écrans utilitaires
import 'package:dr_cardio/screens/utils/placeholder_screen.dart';
import 'package:dr_cardio/screens/common/help_support_screen.dart';
import 'package:dr_cardio/screens/common/terms_privacy_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive database
  await HiveDatabase.init();

  // Generate and save mock data
  await MockService.generateAndSaveMockData();

  // Initialize unified connectivity service (works on web and mobile)
  UnifiedConnectivityService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final UnifiedConnectivityService _connectivityService =
      UnifiedConnectivityService();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();

    // Listen to connectivity changes (works on web and mobile)
    _connectivityService.connectionChange.listen((isOnline) {
      if (!isOnline) {
        // Show offline screen
        _showOfflineScreen();
      } else {
        // Show connection restored message
        _showConnectionRestored();
      }
    });
  }

  void _showOfflineScreen() {
    final navigator = navigatorKey.currentState;
    if (navigator != null) {
      navigator.push(
        MaterialPageRoute(
          builder: (context) => const OfflineModeScreen(),
          fullscreenDialog: true,
        ),
      );
    }
  }

  void _showConnectionRestored() {
    final navigator = navigatorKey.currentState;
    if (navigator != null) {
      ScaffoldMessenger.of(navigator.context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.wifi, color: Colors.white),
              SizedBox(width: 12),
              Text('Connexion rétablie'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'DocteurCardio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: AppRoutes.splash,
      routes: {
        // Routes communes
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.onboarding: (context) => const OnboardingScreen(),
        AppRoutes.profileChoice: (context) => const ProfileChoiceScreen(),

        // Routes d'authentification
        AppRoutes.patientLogin: (context) => const PatientLoginScreenModern(),
        AppRoutes.patientRegister: (context) => const PatientRegisterScreen(),
        AppRoutes.doctorLogin: (context) => const DoctorLoginScreen(),
        AppRoutes.doctorRegister: (context) => const PlaceholderScreen(
              screenName: 'Inscription Cardiologue',
            ),
        AppRoutes.adminLogin: (context) => const PlaceholderScreen(
              screenName: 'Connexion Administrateur',
            ),

        // Routes de récupération de mot de passe
        AppRoutes.patientForgotPassword: (context) =>
            const ForgotPasswordScreen(userType: 'patient'),
        AppRoutes.patientVerifyOtp: (context) =>
            const VerifyOtpScreen(userType: 'patient'),
        AppRoutes.patientResetPassword: (context) =>
            const ResetPasswordScreen(userType: 'patient'),
        AppRoutes.doctorForgotPassword: (context) =>
            const ForgotPasswordScreen(userType: 'doctor'),
        AppRoutes.doctorVerifyOtp: (context) =>
            const VerifyOtpScreen(userType: 'doctor'),
        AppRoutes.doctorResetPassword: (context) =>
            const ResetPasswordScreen(userType: 'doctor'),

        AppRoutes.payment: (context) => const PaymentScreen(),

        // Routes Patient
        AppRoutes.patientDashboard: (context) => const PatientDashboardScreen(),
        AppRoutes.recordPressurePhoto: (context) =>
            const RecordPressurePhotoScreen(),
        AppRoutes.recordPressureManual: (context) =>
            const RecordPressureManualScreen(),
        AppRoutes.addContext: (context) => const AddContextScreen(),
        AppRoutes.patientHistory: (context) => const PatientHistoryScreen(),
        AppRoutes.measureDetail: (context) =>
            const MeasureDetailScreen(),
        AppRoutes.patientMessages: (context) => const PatientMessagesScreen(),
        AppRoutes.patientChat: (context) => const PatientChatScreen(),
        AppRoutes.patientDocuments: (context) => const PatientDocumentsScreen(),
        AppRoutes.teleconsultation: (context) => const TeleconsultationScreen(),
        AppRoutes.patientProfile: (context) => const PatientProfileScreen(),
        AppRoutes.patientEditProfile: (context) => const PatientEditProfileScreen(),
        AppRoutes.patientNotifications: (context) =>
            const NotificationsScreen(),
        AppRoutes.patientSettings: (context) => const PatientSettingsScreen(),

        // Routes Cardiologue
        AppRoutes.doctorDashboard: (context) => const DoctorDashboardScreen(),
        AppRoutes.doctorProfile: (context) => const DoctorProfileScreen(),
        AppRoutes.doctorEditProfile: (context) =>
            const DoctorEditProfileScreen(),
        AppRoutes.doctorPatients: (context) => const DoctorPatientsScreen(),
        AppRoutes.patientFile: (context) => const DoctorPatientFileScreen(),
        AppRoutes.patientFullHistory: (context) =>
            const DoctorPatientHistoryScreen(),
        AppRoutes.doctorMessages: (context) => const DoctorMessagesScreen(),
        AppRoutes.doctorChat: (context) => const DoctorChatScreen(),
        AppRoutes.doctorRevenue: (context) => const DoctorRevenueScreen(),

        // Routes Administrateur
        AppRoutes.adminDashboard: (context) => const AdminDashboardScreen(),

        // Routes utilitaires
        AppRoutes.qrScanner: (context) => const PlaceholderScreen(
              screenName: 'Scanner QR Code',
            ),
        AppRoutes.alertDialog: (context) => const PlaceholderScreen(
              screenName: 'Alerte',
            ),
        AppRoutes.offlineMode: (context) => const PlaceholderScreen(
              screenName: 'Mode Hors Ligne',
            ),
        AppRoutes.helpSupport: (context) => const HelpSupportScreen(),
        AppRoutes.termsPrivacy: (context) => const TermsPrivacyScreen(),
      },
    );
  }
}
