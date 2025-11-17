import 'dart:async';

abstract class ConnectivityService {
  bool get isOnline;
  Stream<bool> get connectionChange;
  Future<bool> checkConnection();
  void initialize();
  void dispose();
}