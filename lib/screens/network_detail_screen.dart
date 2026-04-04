import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:wifi_scan/wifi_scan.dart';

class NetworkDetailScreen extends StatefulWidget {
  final WiFiAccessPoint network;
  const NetworkDetailScreen({super.key, required this.network});

  @override
  State<NetworkDetailScreen> createState() => _NetworkDetailScreenState();
}

class _NetworkDetailScreenState extends State<NetworkDetailScreen> {
  final Dio _dio = Dio();
  Map<String, String> _data = {};
  bool _loading = true;

  final List<IconData> _icons = [
    Icons.wifi,
    Icons.router,
    Icons.settings_input_antenna,
    Icons.lock,
    Icons.signal_wifi_4_bar,
    Icons.timer,
  ];

  @override
  void initState() {
    super.initState();
    _loadDiagnostics();
  }

  Future<void> _loadDiagnostics() async {
    setState(() => _loading = true);

    String ping = 'Unknown';
    try {
      final stopwatch = Stopwatch()..start();
      await _dio.get('https://www.google.com');
      stopwatch.stop();
      ping = '${stopwatch.elapsedMilliseconds} ms';
    } catch (e) {
      ping = 'Unreachable';
    }

    final rssi = widget.network.level;
    final signalQuality =
        rssi >= -50 ? 'Excellent' : rssi >= -70 ? 'Good' : 'Weak';
    final frequency =
        widget.network.frequency >= 5000 ? '5 GHz' : '2.4 GHz';
    final security = widget.network.capabilities.contains('WPA3')
        ? 'WPA3'
        : widget.network.capabilities.contains('WPA2')
            ? 'WPA2'
            : widget.network.capabilities.contains('WPA')
                ? 'WPA'
                : 'Open';

    setState(() {
      _data = {
        'Network Name':
            widget.network.ssid.isEmpty ? 'Hidden Network' : widget.network.ssid,
        'BSSID': widget.network.bssid,
        'Frequency': frequency,
        'Security': security,
        'Signal Quality': signalQuality,
        'Ping': ping,
      };
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.network.ssid.isEmpty
            ? 'Hidden Network'
            : widget.network.ssid),
        backgroundColor: const Color(0xFF111111),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDiagnostics,
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
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
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
                                fontSize: 16,
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