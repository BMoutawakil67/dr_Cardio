import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dr_cardio/routes/app_routes.dart';
import 'package:dr_cardio/services/unified_connectivity_service.dart';
import 'package:dr_cardio/config/app_theme.dart';

/// Shared bottom navigation bar for Patient screens
/// 5 items: Accueil (0), Historique (1), Mesure (2), Messages (3), Profil (4)
class PatientBottomNav extends StatefulWidget {
  final int currentIndex;

  const PatientBottomNav({
    super.key,
    required this.currentIndex,
  });

  @override
  State<PatientBottomNav> createState() => _PatientBottomNavState();
}

class _PatientBottomNavState extends State<PatientBottomNav> {
  final UnifiedConnectivityService _connectivityService = UnifiedConnectivityService();
  late bool _isOnline;
  StreamSubscription<bool>? _subscription;

  @override
  void initState() {
    super.initState();
    _isOnline = _connectivityService.isOnline;
    _subscription = _connectivityService.connectionChange.listen((isOnline) {
      if (mounted) {
        setState(() {
          _isOnline = isOnline;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _showOfflineMessage(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.wifi_off, color: Colors.white),
            const SizedBox(width: 12),
            Text('$feature non disponible hors ligne'),
          ],
        ),
        backgroundColor: AppTheme.warningOrange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      elevation: 8,
      onTap: (index) {
        // Index 3 = Messages (nécessite connexion)
        if (index == 3 && !_isOnline) {
          _showOfflineMessage('Messages');
          return;
        }

        switch (index) {
          case 0:
            if (widget.currentIndex != 0) {
              Navigator.pushReplacementNamed(context, AppRoutes.patientDashboard);
            }
            break;
          case 1:
            if (widget.currentIndex != 1) {
              Navigator.pushNamed(context, AppRoutes.patientHistory);
            }
            break;
          case 2:
            if (widget.currentIndex != 2) {
              Navigator.pushNamed(context, AppRoutes.recordPressurePhoto);
            }
            break;
          case 3:
            if (widget.currentIndex != 3) {
              Navigator.pushNamed(context, AppRoutes.patientMessages);
            }
            break;
          case 4:
            if (widget.currentIndex != 4) {
              Navigator.pushNamed(context, AppRoutes.patientProfile);
            }
            break;
        }
      },
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Accueil',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.analytics_outlined),
          activeIcon: Icon(Icons.analytics),
          label: 'Historique',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.camera_alt_outlined),
          activeIcon: Icon(Icons.camera_alt),
          label: 'Mesure',
        ),
        BottomNavigationBarItem(
          icon: Stack(
            children: [
              Icon(
                Icons.message_outlined,
                color: _isOnline ? null : Colors.grey.shade400,
              ),
              if (!_isOnline)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Icon(
                    Icons.wifi_off,
                    size: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
            ],
          ),
          activeIcon: Icon(
            Icons.message,
            color: _isOnline ? null : Colors.grey.shade400,
          ),
          label: 'Messages',
        ),
        const BottomNavigationBarItem(
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
class DoctorBottomNav extends StatefulWidget {
  final int currentIndex;

  const DoctorBottomNav({
    super.key,
    required this.currentIndex,
  });

  @override
  State<DoctorBottomNav> createState() => _DoctorBottomNavState();
}

class _DoctorBottomNavState extends State<DoctorBottomNav> {
  final UnifiedConnectivityService _connectivityService = UnifiedConnectivityService();
  late bool _isOnline;
  StreamSubscription<bool>? _subscription;

  @override
  void initState() {
    super.initState();
    _isOnline = _connectivityService.isOnline;
    _subscription = _connectivityService.connectionChange.listen((isOnline) {
      if (mounted) {
        setState(() {
          _isOnline = isOnline;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _showOfflineMessage(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.wifi_off, color: Colors.white),
            const SizedBox(width: 12),
            Text('$feature non disponible hors ligne'),
          ],
        ),
        backgroundColor: AppTheme.warningOrange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        // Index 2 = Messages (nécessite connexion)
        if (index == 2 && !_isOnline) {
          _showOfflineMessage('Messages');
          return;
        }

        switch (index) {
          case 0:
            if (widget.currentIndex != 0) {
              Navigator.pushReplacementNamed(context, AppRoutes.doctorDashboard);
            }
            break;
          case 1:
            if (widget.currentIndex != 1) {
              Navigator.pushNamed(context, AppRoutes.doctorPatients);
            }
            break;
          case 2:
            if (widget.currentIndex != 2) {
              Navigator.pushNamed(context, AppRoutes.doctorMessages);
            }
            break;
          case 3:
            if (widget.currentIndex != 3) {
              Navigator.pushNamed(context, AppRoutes.doctorRevenue);
            }
            break;
          case 4:
            if (widget.currentIndex != 4) {
              Navigator.pushNamed(context, AppRoutes.doctorProfile);
            }
            break;
        }
      },
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Accueil',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
          activeIcon: Icon(Icons.people),
          label: 'Patients',
        ),
        BottomNavigationBarItem(
          icon: Stack(
            children: [
              Icon(
                Icons.message_outlined,
                color: _isOnline ? null : Colors.grey.shade400,
              ),
              if (!_isOnline)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Icon(
                    Icons.wifi_off,
                    size: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
            ],
          ),
          activeIcon: Icon(
            Icons.message,
            color: _isOnline ? null : Colors.grey.shade400,
          ),
          label: 'Messages',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.analytics_outlined),
          activeIcon: Icon(Icons.analytics),
          label: 'Stats',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}
