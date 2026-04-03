import 'package:flutter/material.dart';
import '../models/scan_point.dart';
import '../painters/heatmap_painter.dart';

class HeatmapScreen extends StatefulWidget {
  const HeatmapScreen({super.key});

  @override
  State<HeatmapScreen> createState() => _HeatmapScreenState();
}

class _HeatmapScreenState extends State<HeatmapScreen> {
  final List<ScanPoint> _points = [];

  void _onTap(TapUpDetails details) {
    setState(() {
      _points.add(ScanPoint(
        position: details.localPosition,
        rssi: _mockRssi(),
      ));
    });
  }

  int _mockRssi() {
    // Simulated signal — we'll replace with real WiFi data later
    final values = [-40, -55, -65, -75, -85];
    return values[_points.length % values.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WiFi Heatmap'),
        backgroundColor: const Color(0xFF111111),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => setState(() => _points.clear()),
          )
        ],
      ),
      body: GestureDetector(
        onTapUp: _onTap,
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