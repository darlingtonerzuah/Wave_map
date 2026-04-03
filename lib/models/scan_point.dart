import 'package:flutter/rendering.dart';

class ScanPoint {
    final Offset position; // x,y on screen
    final int rssi; // signal strength

    ScanPoint({required this.position, required this.rssi});
    
}