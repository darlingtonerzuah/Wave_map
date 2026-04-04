import 'package:flutter/material.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'network_detail_screen.dart';

class DiagnosticsScreen extends StatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  State<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends State<DiagnosticsScreen> {
  List<WiFiAccessPoint> _networks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _scanNetworks();
  }

  Future<void> _scanNetworks() async {
    setState(() => _loading = true);
    final results = await WiFiScan.instance.getScannedResults();
    setState(() {
      _networks = results;
      _loading = false;
    });
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
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NetworkDetailScreen(network: n),
                          ),
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: const Color(0xFF00E5FF).withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.wifi, color: Color(0xFF00E5FF)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  n.ssid.isEmpty ? 'Hidden Network' : n.ssid,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
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