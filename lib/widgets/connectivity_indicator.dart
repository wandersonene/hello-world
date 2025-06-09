import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityIndicator extends StatefulWidget {
  const ConnectivityIndicator({Key? key}) : super(key: key);

  @override
  State<ConnectivityIndicator> createState() => _ConnectivityIndicatorState();
}

class _ConnectivityIndicatorState extends State<ConnectivityIndicator> {
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];

  @override
  void initState() {
    super.initState();
    _checkInitialConnectivity();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _checkInitialConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    _updateConnectionStatus(connectivityResult);
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    setState(() {
      _connectionStatus = result;
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isOnline = _connectionStatus.contains(ConnectivityResult.mobile) ||
                    _connectionStatus.contains(ConnectivityResult.wifi) ||
                    _connectionStatus.contains(ConnectivityResult.ethernet);
    // Consider VPN as online too, though it might not always mean internet access.
    // For simplicity, we'll count it as online.
    if (_connectionStatus.contains(ConnectivityResult.vpn)) {
        isOnline = true;
    }
    // If none of the above, and it contains none, it's offline.
    // If it's just 'bluetooth' or other, it might be considered offline for internet purposes.
    if (!isOnline && _connectionStatus.contains(ConnectivityResult.none) && _connectionStatus.length == 1) {
        isOnline = false;
    }


    return Tooltip(
      message: isOnline ? 'Online' : 'Offline - Sem conexão com a rede',
      child: Icon(
        isOnline ? Icons.wifi_outlined : Icons.wifi_off_outlined,
        color: isOnline ? Colors.green[400] : Colors.red[400],
        size: 20,
      ),
    );
  }
}
