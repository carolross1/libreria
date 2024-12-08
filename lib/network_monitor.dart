import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkMonitor {
  final _connectivity = Connectivity();
  final _controller = StreamController<bool>.broadcast();

  // Stream para escuchar cambios en el estado de la red
  Stream<bool> get onNetworkChange => _controller.stream;

  NetworkMonitor() {
    _connectivity.onConnectivityChanged.listen((result) {
      _controller.add(result != ConnectivityResult.none);
    });
  }

  Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  void dispose() {
    _controller.close();
  }
}
