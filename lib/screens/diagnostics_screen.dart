import 'package:flutter/material.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'network_detail_screen.dart';

class DiagnosticsScreen extends StatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  State<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends State<DiagnosticsScreen> {
  List<WiFiAccessPoint> _networks = [];
  WiFiAccessPoint? _lastSelected;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _scanNetworks();
  }

  Future<void> _scanNetworks() async {
    setState(() => _loading = true);
    final results = await WiFiScan.instance.getScannedResults();
    final prefs = await SharedPreferences.getInstance();
    final lastBssid = prefs.getString('last_network_bssid');

    WiFiAccessPoint? match;
    if (lastBssid != null) {
      final found = results.where((r) => r.bssid == lastBssid).toList();
      if (found.isNotEmpty) match = found.first;
    }

    setState(() {
      _networks = results;
      _lastSelected = match;
      _loading = false;
    });

    if (match != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NetworkDetailScreen(network: match!),
        ),
      );
    }
  }

  Future<void> _onNetworkTap(WiFiAccessPoint network) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_network_bssid', network.bssid);
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NetworkDetailScreen(network: network),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostics'),
        backgroundColor: const Color(0xFF111111),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _scanNetworks,
          )
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00E5FF)))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Tap your network to view details',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _networks.length,
                    itemBuilder: (context, index) {
                      final n = _networks[index];
                      final isLast = _lastSelected?.bssid == n.bssid;
                      return GestureDetector(
                        onTap: () => _onNetworkTap(n),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isLast
                                ? const Color(0xFF00E5FF).withOpacity(0.1)
                                : const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isLast
                                  ? const Color(0xFF00E5FF)
                                  : const Color(0xFF00E5FF).withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.wifi,
                                  color: isLast
                                      ? const Color(0xFF00E5FF)
                                      : Colors.grey),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      n.ssid.isEmpty ? 'Hidden Network' : n.ssid,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isLast
                                              ? const Color(0xFF00E5FF)
                                              : Colors.white),
                                    ),
                                    if (isLast)
                                      const Text('Last viewed',
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 11)),
                                  ],
                                ),
                              ),
                              Text('${n.level} dBm',
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                              const SizedBox(width: 8),
                              const Icon(Icons.chevron_right,
                                  color: Colors.grey),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}