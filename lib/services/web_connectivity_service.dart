import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'connectivity_service.dart';

class WebConnectivityService implements ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionChangeController =
      StreamController.broadcast();

  @override
  Stream<bool> get connectionChange => _connectionChangeController.stream;

  @override
  bool get isOnline => _isOnline;
  bool _isOnline = true;

  @override
  Future<void> initialize() async {
    _connectivity.onConnectivityChanged.listen(_handleResult);
    final result = await _connectivity.checkConnectivity();
    _handleResult(result);
  }

  void _handleResult(List<ConnectivityResult> result) {
    final isOnlineNow = !result.contains(ConnectivityResult.none);
    if (_isOnline != isOnlineNow) {
      _isOnline = isOnlineNow;
      _connectionChangeController.add(_isOnline);
    }
  }

  @override
  Future<bool> checkConnection() async {
    final result = await _connectivity.checkConnectivity();
    _handleResult(result);
    return _isOnline;
  }

  @override
  void dispose() {
    _connectionChangeController.close();
  }
}

ConnectivityService getConnectivityService() => WebConnectivityService();
