import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:wifi_scan/wifi_scan.dart';

class DiagnosticsScreen extends StatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  State<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends State<DiagnosticsScreen> {
  final Dio _dio = Dio();
  Map<String, String> _data = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchDiagnostics();
  }

  Future<void> _fetchDiagnostics() async {
    setState(() => _loading = true);

    String networkName = 'Unknown';
    String bssid = 'Unknown';
    String ping = 'Unknown';
    String signalQuality = 'Unknown';

    try {
      final results = await WiFiScan.instance.getScannedResults();
      if (results.isNotEmpty) {
        final strongest = results.reduce((a, b) => a.level > b.level ? a : b);
        networkName = strongest.ssid.isEmpty ? 'Hidden Network' : strongest.ssid;
        bssid = strongest.bssid;
        final rssi = strongest.level;
        if (rssi >= -50) {
          signalQuality = 'Excellent';
        } else if (rssi >= -70) {
          signalQuality = 'Good';
        } else {
          signalQuality = 'Weak';
        }
      }
    } catch (e) {
      networkName = 'Scan failed';
    }

    try {
      final stopwatch = Stopwatch()..start();
      await _dio.get('https://www.google.com');
      stopwatch.stop();
      ping = '${stopwatch.elapsedMilliseconds} ms';
    } catch (e) {
      ping = 'Unreachable';
    }

    setState(() {
      _data = {
        'Network Name': networkName,
        'BSSID': bssid,
        'Ping': ping,
        'Signal Quality': signalQuality,
        'Est. Download': 'N/A',
        'Connected Devices': 'N/A',
      };
      _loading = false;
    });
  }

  final List<IconData> _icons = [
    Icons.wifi,
    Icons.router,
    Icons.timer,
    Icons.signal_wifi_4_bar,
    Icons.download,
    Icons.devices,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostics'),
        backgroundColor: const Color(0xFF111111),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchDiagnostics,
          )
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00E5FF)))
          : Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                itemCount: _data.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4,
                ),
                itemBuilder: (context, index) {
                  final key = _data.keys.elementAt(index);
                  final value = _data.values.elementAt(index);
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFF00E5FF).withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(_icons[index], color: const Color(0xFF00E5FF)),
                        Text(value,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        Text(key,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}