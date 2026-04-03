import 'package:flutter/material.dart';
import '../models/scan_point.dart';

class HeatmapPainter extends CustomPainter {
  final List<ScanPoint> points;

  HeatmapPainter({required this.points});

  Color _rssiToColor(int rssi) {
    if (rssi >= -50) return Colors.green.withOpacity(0.6);
    if (rssi >= -70) return Colors.orange.withOpacity(0.6);
    return Colors.red.withOpacity(0.6);
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final point in points) {
      final paint = Paint()
        ..color = _rssiToColor(point.rssi)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);

      canvas.drawCircle(point.position, 60, paint);
    }
  }

  @override
  bool shouldRepaint(HeatmapPainter oldDelegate) => true;
}