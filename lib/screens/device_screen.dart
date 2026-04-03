import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/network_device.dart';
import 'package:flutter/foundation.dart';
import '../services/wifi_service.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  final Dio _dio = Dio();
  List<NetworkDevice> _devices = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDevices();
  }

 Future<void> _fetchDevices() async {
  try {
    if (kIsWeb) {
      // Web: use backend mock data
      final response = await _dio.get('http://10.11.59.210:5000/api/devices');
      setState(() {
        _devices = (response.data as List).map((d) => NetworkDevice(
          name: d['name'],
          ip: d['ip'],
          rssi: d['rssi'],
          status: d['status'],
        )).toList();
        _loading = false;
      });
    } else {
      // Android: real WiFi scan
      final wifiService = WifiService();
      final results = await wifiService.scanDevices();
      setState(() {
        _devices = results;
        _loading = false;
      });
    }
  } catch (e) {
    setState(() {
      _error = 'Failed to load devices';
      _loading = false;
    });
  }
}
  Color _statusColor(String status) {
    switch (status) {
      case 'Strong': return Colors.green;
      case 'Okay': return Colors.orange;
      default: return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devices'),
        backgroundColor: const Color(0xFF111111),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _loading = true);
              _fetchDevices();
            },
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF)))
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : ListView.builder(
                  itemCount: _devices.length,
                  itemBuilder: (context, index) {
                    final device = _devices[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.devices, color: Color(0xFF00E5FF)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(device.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(device.ip, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                Text('${device.rssi} dBm', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _statusColor(device.status).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(device.status, style: TextStyle(color: _statusColor(device.status), fontSize: 12)),
                          )
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}