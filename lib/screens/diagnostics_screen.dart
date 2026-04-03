import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class DiagnosticsScreen extends StatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  State<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends State<DiagnosticsScreen> {
  final Dio _dio = Dio();
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDiagnostics();
  }

  Future<void> _fetchDiagnostics() async {
    try {
      final response = await _dio.get('http://127.0.0.1:5000/api/diagnostics');
      setState(() {
        _data = response.data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to connect to backend';
        _loading = false;
      });
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
            onPressed: () {
              setState(() => _loading = true);
              _fetchDiagnostics();
            },
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF)))
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _buildGrid(),
    );
  }

  Widget _buildGrid() {
    final stats = [
      {'label': 'Network Name', 'value': _data!['network_name'], 'icon': Icons.wifi},
      {'label': 'Signal Quality', 'value': '${_data!['signal_quality']}%', 'icon': Icons.signal_wifi_4_bar},
      {'label': 'Ping', 'value': '${_data!['ping']} ms', 'icon': Icons.timer},
      {'label': 'Est. Download', 'value': '${_data!['download']} Mbps', 'icon': Icons.download},
      {'label': 'Connected Devices', 'value': '${_data!['connected_devices']}', 'icon': Icons.devices},
      {'label': 'IP Address', 'value': _data!['ip'], 'icon': Icons.router},
    ];

    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        itemCount: stats.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
        ),
        itemBuilder: (context, index) {
          final stat = stats[index];
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
    );
  }
}