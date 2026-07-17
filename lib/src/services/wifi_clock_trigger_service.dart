import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

/// Watches Wi-Fi connectivity changes and reports the currently-connected
/// SSID, so callers can auto clock-in/out when a device joins or leaves a
/// registered workplace network.
///
/// Reading the SSID requires location permission on both iOS and Android —
/// the OS treats it as location data. [start] requests that permission the
/// first time it's needed; if denied, [onSsidChanged] is called with `null`
/// and the trigger silently stays inactive (same as not connected to Wi-Fi).
class WifiClockTriggerService {
  WifiClockTriggerService({Connectivity? connectivity, NetworkInfo? networkInfo})
      : _connectivity = connectivity ?? Connectivity(),
        _networkInfo = networkInfo ?? NetworkInfo();

  final Connectivity _connectivity;
  final NetworkInfo _networkInfo;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  void start(void Function(String? ssid) onSsidChanged) {
    _subscription = _connectivity.onConnectivityChanged.listen((results) async {
      if (!results.contains(ConnectivityResult.wifi)) {
        onSsidChanged(null);
        return;
      }
      onSsidChanged(await _currentSsid());
    });
  }

  Future<String?> _currentSsid() async {
    var status = await Permission.locationWhenInUse.status;
    if (!status.isGranted) {
      status = await Permission.locationWhenInUse.request();
    }
    if (!status.isGranted) return null;
    final raw = await _networkInfo.getWifiName();
    // Both platforms may wrap the SSID in quotes.
    return raw?.replaceAll('"', '');
  }

  void dispose() {
    _subscription?.cancel();
  }
}
