import 'package:wifi_scan/wifi_scan.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/network_device.dart';

class WifiService {
  Future<List<NetworkDevice>> scanDevices() async {
    // Request location permission (required for WiFi scanning on Android)
    final status = await Permission.location.request();
    if (!status.isGranted) return [];

    // Check if scanning is supported
    final can = await WiFiScan.instance.canStartScan();
    if (can != CanStartScan.yes) return [];

    // Start scan
    await WiFiScan.instance.startScan();

    // Get results
    final results = await WiFiScan.instance.getScannedResults();

    return results.map((r) => NetworkDevice(
      name: r.ssid.isEmpty ? 'Hidden Network' : r.ssid,
      ip: r.bssid,
      rssi: r.level,
      status: _rssiToStatus(r.level),
    )).toList();
  }

  String _rssiToStatus(int rssi) {
    if (rssi >= -50) return 'Strong';
    if (rssi >= -70) return 'Okay';
    return 'Weak';
  }
}