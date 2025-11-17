import 'dart:async';
import 'dart:html' as html;
import 'connectivity_service.dart';

class WebConnectivityService implements ConnectivityService {
  static final WebConnectivityService _instance = WebConnectivityService._internal();
  factory WebConnectivityService() => _instance;
  WebConnectivityService._internal();

  @override
  bool get isOnline => _isOnline;
  bool _isOnline = html.window.navigator.onLine ?? true;

  final StreamController<bool> _connectionChangeController =
      StreamController<bool>.broadcast();

  @override
  Stream<bool> get connectionChange => _connectionChangeController.stream;

  StreamSubscription<html.Event>? _onlineSubscription;
  StreamSubscription<html.Event>? _offlineSubscription;

  @override
  void initialize() {
    _isOnline = html.window.navigator.onLine ?? true;
    print('🌐 Web Connectivity initialized - Online: $_isOnline');

    _onlineSubscription = html.window.onOnline.listen((event) {
      print('✅ Connection restored');
      _isOnline = true;
      _connectionChangeController.add(true);
    });

    _offlineSubscription = html.window.onOffline.listen((event) {
      print('❌ Connection lost');
      _isOnline = false;
      _connectionChangeController.add(false);
    });
  }

  @override
  Future<bool> checkConnection() async {
    _isOnline = html.window.navigator.onLine ?? true;
    return _isOnline;
  }

  @override
  void dispose() {
    _onlineSubscription?.cancel();
    _offlineSubscription?.cancel();
    _connectionChangeController.close();
  }
}

ConnectivityService getConnectivityService() => WebConnectivityService();