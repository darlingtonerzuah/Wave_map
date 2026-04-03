import 'package:flutter/material.dart';
import '../models/network_device.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  final List<NetworkDevice> _devices = [
    NetworkDevice(name: 'iPhone 13', ip: '192.168.1.2', rssi: -45, status: 'Strong'),
    NetworkDevice(name: 'Samsung TV', ip: '192.168.1.3', rssi: -67, status: 'Okay'),
    NetworkDevice(name: 'Unknown Device', ip: '192.168.1.4', rssi: -82, status: 'Weak'),
    NetworkDevice(name: 'MacBook Pro', ip: '192.168.1.5', rssi: -51, status: 'Strong'),
  ];

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
      ),
      body: ListView.builder(
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