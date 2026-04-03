import 'package:flutter/material.dart';

class DiagnosticsScreen extends StatelessWidget {
  const DiagnosticsScreen({super.key});

  final List<Map<String, dynamic>> _stats = const [
    {'label': 'Network Name', 'value': 'MyWiFi_5G', 'icon': Icons.wifi},
    {'label': 'Signal Quality', 'value': '78%', 'icon': Icons.signal_wifi_4_bar},
    {'label': 'Ping', 'value': '12 ms', 'icon': Icons.timer},
    {'label': 'Est. Download', 'value': '54 Mbps', 'icon': Icons.download},
    {'label': 'Connected Devices', 'value': '4', 'icon': Icons.devices},
    {'label': 'IP Address', 'value': '192.168.1.1', 'icon': Icons.router},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostics'),
        backgroundColor: const Color(0xFF111111),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          itemCount: _stats.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
          ),
          itemBuilder: (context, index) {
            final stat = _stats[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(stat['icon'] as IconData, color: const Color(0xFF00E5FF)),
                  Text(stat['value'] as String,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(stat['label'] as String,
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}