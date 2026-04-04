import 'package:flutter/material.dart';
import '../models/scan_point.dart';
import '../painters/heatmap_painter.dart';
import '../services/wifi_service.dart';

class HeatmapScreen extends StatefulWidget {
  const HeatmapScreen({super.key});

  @override
  State<HeatmapScreen> createState() => _HeatmapScreenState();
}

class _HeatmapScreenState extends State<HeatmapScreen> {
  final List<ScanPoint> _points = [];
  bool _scanning = false;

  Future<void> _onTap(TapUpDetails details) async {
    if (_scanning) return;
    setState(() => _scanning = true);

    final wifiService = WifiService();
    final devices = await wifiService.scanDevices();

    if (devices.isNotEmpty) {
      final strongest = devices.reduce((a, b) => a.rssi > b.rssi ? a : b);
      setState(() {
        _points.add(ScanPoint(
          position: details.localPosition,
          rssi: strongest.rssi,
        ));
      });
    }

    setState(() => _scanning = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WiFi Heatmap'),
        backgroundColor: const Color(0xFF111111),
        actions: [
          if (_scanning)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Color(0xFF00E5FF),
                  strokeWidth: 2,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => setState(() => _points.clear()),
          )
        ],
      ),
      body: GestureDetector(
        onTapUp: (details) => _onTap(details),
        child: CustomPaint(
          painter: HeatmapPainter(points: _points),
          child: Container(
            color: Colors.transparent,
          ),
        ),
      ),
    );
  }
}