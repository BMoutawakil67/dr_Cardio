import 'package:flutter/material.dart';
import 'package:dr_cardio/routes/app_routes.dart';

/// Shared bottom navigation bar for Patient screens
/// 5 items: Accueil (0), Historique (1), Mesure (2), Messages (3), Profil (4)
class PatientBottomNav extends StatelessWidget {
  final int currentIndex;

  const PatientBottomNav({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      elevation: 8,
      onTap: (index) {
        switch (index) {
          case 0:
            if (currentIndex != 0) {
              Navigator.pushReplacementNamed(context, AppRoutes.patientDashboard);
            }
            break;
          case 1:
            if (currentIndex != 1) {
              Navigator.pushNamed(context, AppRoutes.patientHistory);
            }
            break;
          case 2:
            if (currentIndex != 2) {
              Navigator.pushNamed(context, AppRoutes.recordPressurePhoto);
            }
            break;
          case 3:
            if (currentIndex != 3) {
              Navigator.pushNamed(context, AppRoutes.patientMessages);
            }
            break;
          case 4:
            if (currentIndex != 4) {
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
          icon: Icon(Icons.analytics_outlined),
          activeIcon: Icon(Icons.analytics),
          label: 'Historique',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.camera_alt_outlined),
          activeIcon: Icon(Icons.camera_alt),
          label: 'Mesure',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message_outlined),
          activeIcon: Icon(Icons.message),
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

/// Shared bottom navigation bar for Doctor screens
/// 5 items: Accueil (0), Patients (1), Messages (2), Stats (3), Profil (4)
class DoctorBottomNav extends StatelessWidget {
  final int currentIndex;

  const DoctorBottomNav({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        switch (index) {
          case 0:
            if (currentIndex != 0) {
              Navigator.pushReplacementNamed(context, AppRoutes.doctorDashboard);
            }
            break;
          case 1:
            if (currentIndex != 1) {
              Navigator.pushNamed(context, AppRoutes.doctorPatients);
            }
            break;
          case 2:
            if (currentIndex != 2) {
              Navigator.pushNamed(context, AppRoutes.doctorMessages);
            }
            break;
          case 3:
            if (currentIndex != 3) {
              Navigator.pushNamed(context, AppRoutes.doctorRevenue);
            }
            break;
          case 4:
            if (currentIndex != 4) {
              Navigator.pushNamed(context, AppRoutes.doctorProfile);
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
          icon: Icon(Icons.people_outline),
          activeIcon: Icon(Icons.people),
          label: 'Patients',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message_outlined),
          activeIcon: Icon(Icons.message),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics_outlined),
          activeIcon: Icon(Icons.analytics),
          label: 'Stats',
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
