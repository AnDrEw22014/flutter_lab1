import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class NetworkService extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _isConnected = true;
  bool get isConnected => _isConnected;

  NetworkService() {
    _init();
  }

  Future<void> _init() async {
    final results = await _connectivity.checkConnectivity();
    _updateStatus(results);

    // Підписка на потік змін мережі
    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final hasConnection =
        results.isNotEmpty && !results.contains(ConnectivityResult.none);
    if (_isConnected != hasConnection) {
      _isConnected = hasConnection;
      notifyListeners();
    }
  }

  // Одноразова перевірка перед спробою входу
  Future<bool> checkInternetNow() async {
    final results = await _connectivity.checkConnectivity();
    _updateStatus(results);
    return _isConnected;
  }

  @override
  void dispose() {
    _subscription?.cancel(); // Обов'язкове закриття потоку
    super.dispose();
  }
}