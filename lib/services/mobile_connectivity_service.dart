import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'connectivity_service.dart';

class MobileConnectivityService implements ConnectivityService {
  static final MobileConnectivityService _instance = MobileConnectivityService._internal();
  factory MobileConnectivityService() => _instance;
  MobileConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  bool get isOnline => _isOnline;
  bool _isOnline = true;

  final StreamController<bool> _connectionChangeController =
      StreamController<bool>.broadcast();

  @override
  Stream<bool> get connectionChange => _connectionChangeController.stream;

  @override
  void initialize() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
    print('📱 Mobile Connectivity initialized - Online: $_isOnline');

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    final bool wasOnline = _isOnline;

    _isOnline = result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.ethernet);

    if (wasOnline != _isOnline) {
      if (_isOnline) {
        print('✅ Mobile connection restored');
      } else {
        print('❌ Mobile connection lost');
      }
      _connectionChangeController.add(_isOnline);
    }
  }

  @override
  Future<bool> checkConnection() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
    return _isOnline;
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectionChangeController.close();
  }
}

ConnectivityService getConnectivityService() => MobileConnectivityService();