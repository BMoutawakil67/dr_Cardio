import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dr_cardio/screens/common/offline_mode_screen.dart';
import 'connectivity_service.dart';
import 'connectivity_service_stub.dart'
    if (dart.library.html) 'web_connectivity_service.dart'
    if (dart.library.io) 'mobile_connectivity_service.dart';

class UnifiedConnectivityService {
  static final UnifiedConnectivityService _instance =
      UnifiedConnectivityService._internal();
  factory UnifiedConnectivityService() => _instance;
  UnifiedConnectivityService._internal();

  late final ConnectivityService _service;
  StreamSubscription? _subscription;

  void initialize() {
    _service = getConnectivityService();
    _service.initialize();
    debugPrint('🌐 Unified Connectivity Service initialized');
  }

  bool get isOnline => _service.isOnline;
  Stream<bool> get connectionChange => _service.connectionChange;
  Future<bool> checkConnection() => _service.checkConnection();

  void dispose() {
    _subscription?.cancel();
    _service.dispose();
  }
}

class ConnectivityListener extends StatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  const ConnectivityListener({
    super.key,
    required this.child,
    required this.navigatorKey,
  });

  @override
  State<ConnectivityListener> createState() => _ConnectivityListenerState();
}

class _ConnectivityListenerState extends State<ConnectivityListener> {
  final UnifiedConnectivityService _connectivityService =
      UnifiedConnectivityService();
  StreamSubscription<bool>? _subscription;

  @override
  void initState() {
    super.initState();

    _subscription = _connectivityService.connectionChange.listen((isOnline) {
      if (!isOnline) {
        _showOfflineScreen();
      } else {
        _showConnectionRestored();
      }
    });
  }

  void _showOfflineScreen() {
    final navigator = widget.navigatorKey.currentState;
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
    final navigator = widget.navigatorKey.currentState;
    if (navigator != null && navigator.context.mounted) {
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
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
