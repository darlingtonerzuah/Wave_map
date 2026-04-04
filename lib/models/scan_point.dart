import 'package:flutter/rendering.dart';

class ScanPoint {
  final Offset position;
  final int rssi;

  ScanPoint({required this.position, required this.rssi});

  Map<String, dynamic> toJson() => {
        'x': position.dx,
        'y': position.dy,
        'rssi': rssi,
      };

  factory ScanPoint.fromJson(Map<String, dynamic> json) => ScanPoint(
        position: Offset(json['x'], json['y']),
        rssi: json['rssi'],
      );
}