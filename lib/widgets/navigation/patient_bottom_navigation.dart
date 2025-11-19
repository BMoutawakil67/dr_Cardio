import 'package:flutter/material.dart';
import 'package:dr_cardio/config/app_theme.dart';
import 'package:dr_cardio/routes/app_routes.dart';

class PatientBottomNavigation extends StatelessWidget {
  final int currentIndex;

  const PatientBottomNavigation({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: AppTheme.primaryBlue,
      unselectedItemColor: Colors.grey.shade600,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        switch (index) {
          case 0:
            if (currentIndex != 0) {
              Navigator.pushReplacementNamed(context, AppRoutes.patientDashboard);
            }
            break;
          case 1:
            if (currentIndex != 1) {
              Navigator.pushNamed(context, AppRoutes.patientHistory, arguments: {'patientId': 'patient-001'});
            }
            break;
          case 2:
            if (currentIndex != 2) {
              Navigator.pushNamed(context, AppRoutes.patientMessages);
            }
            break;
          case 3:
            if (currentIndex != 3) {
              Navigator.pushNamed(context, AppRoutes.patientProfile);
            }
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history_outlined),
          activeIcon: Icon(Icons.history),
          label: 'Historique',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          activeIcon: Icon(Icons.chat_bubble),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}
