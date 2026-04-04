import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import 'dart:math';

class ARScreen extends StatefulWidget {
  const ARScreen({super.key});

  @override
  State<ARScreen> createState() => _ARScreenState();
}

class _ARScreenState extends State<ARScreen> {
  CameraController? _controller;
  List<WiFiAccessPoint> _networks = [];
  WiFiAccessPoint? _selectedNetwork;
  bool _loading = true;
  bool _scanning = false;
  String _error = '';
  double _heading = 0;
  double _currentRssi = -100;
  double _bestRssi = -100;
  double _bestHeading = 0;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _scanNetworks();
    _startCompass();
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      setState(() {
        _error = 'Camera permission denied';
        _loading = false;
      });
      return;
    }
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      setState(() {
        _error = 'No camera found';
        _loading = false;
      });
      return;
    }
    _controller = CameraController(cameras[0], ResolutionPreset.medium);
    await _controller!.initialize();
    setState(() => _loading = false);
  }

  Future<void> _scanNetworks() async {
    final results = await WiFiScan.instance.getScannedResults();
    setState(() => _networks = results);
  }

  void _startCompass() {
    FlutterCompass.events?.listen((event) {
      if (mounted) setState(() => _heading = event.heading ?? 0);
    });
  }

  Future<void> _trackSignal() async {
    if (_selectedNetwork == null || _scanning) return;
    setState(() => _scanning = true);

    final results = await WiFiScan.instance.getScannedResults();
    final match = results.where((r) => r.bssid == _selectedNetwork!.bssid).toList();

    if (match.isNotEmpty) {
      final rssi = match.first.level.toDouble();
      setState(() {
        _currentRssi = rssi;
        if (rssi > _bestRssi) {
          _bestRssi = rssi;
          _bestHeading = _heading;
        }
      });
    }

    setState(() => _scanning = false);
  }

  double _angleDiff(double a, double b) {
    double diff = (a - b + 360) % 360;
    if (diff > 180) diff -= 360;
    return diff;
  }

  Color _rssiColor(double rssi) {
    if (rssi >= -50) return Colors.green;
    if (rssi >= -70) return Colors.orange;
    return Colors.red;
  }

  String _rssiLabel(double rssi) {
    if (rssi >= -50) return 'Excellent';
    if (rssi >= -70) return 'Good';
    return 'Weak';
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final arrowAngle = _angleDiff(_bestHeading, _heading);

    return Scaffold(
      appBar: AppBar(
        title: const Text('WiFi Compass'),
        backgroundColor: const Color(0xFF111111),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _scanNetworks),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00E5FF)))
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.camera_alt, color: Colors.grey, size: 64),
                      const SizedBox(height: 16),
                      Text(_error, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _error = '';
                            _loading = true;
                          });
                          _initCamera();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00E5FF),
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Retry'),
                      ),
                      TextButton(
                        onPressed: () => openAppSettings(),
                        child: const Text('Open Settings',
                            style: TextStyle(color: Color(0xFF00E5FF))),
                      ),
                    ],
                  ),
                )
              : _selectedNetwork == null
                  ? _networkPicker()
                  : Stack(
                      children: [
                        SizedBox.expand(child: CameraPreview(_controller!)),
                        if (settings.arOverlay) ...[
                          // Arrow pointing to best signal
                          Center(
                            child: Transform.rotate(
                              angle: arrowAngle * pi / 180,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: _rssiColor(_currentRssi)
                                          .withOpacity(0.2),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: _rssiColor(_currentRssi),
                                          width: 2),
                                    ),
                                    child: Icon(Icons.navigation,
                                        color: _rssiColor(_currentRssi),
                                        size: 36),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Signal info overlay
                          Positioned(
                            bottom: 40,
                            left: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.75),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: const Color(0xFF00E5FF)
                                        .withOpacity(0.4)),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    _selectedNetwork!.ssid.isEmpty
                                        ? 'Hidden Network'
                                        : _selectedNetwork!.ssid,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      _statCard('Current',
                                          '${_currentRssi.toInt()} dBm',
                                          _rssiColor(_currentRssi)),
                                      _statCard('Best',
                                          '${_bestRssi.toInt()} dBm',
                                          Colors.green),
                                      _statCard('Quality',
                                          _rssiLabel(_currentRssi),
                                          _rssiColor(_currentRssi)),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: _trackSignal,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF00E5FF),
                                      foregroundColor: Colors.black,
                                      minimumSize:
                                          const Size(double.infinity, 44),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                    ),
                                    child: Text(_scanning
                                        ? 'Scanning...'
                                        : 'Scan Signal'),
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed: () => setState(() {
                                      _selectedNetwork = null;
                                      _currentRssi = -100;
                                      _bestRssi = -100;
                                      _bestHeading = 0;
                                    }),
                                    child: const Text('Change Network',
                                        style: TextStyle(
                                            color: Colors.grey)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Compass heading
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.explore,
                                      color: Color(0xFF00E5FF), size: 16),
                                  const SizedBox(width: 4),
                                  Text('${_heading.toStringAsFixed(0)}°',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 13)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
    );
  }

  Widget _networkPicker() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Select a network to track',
            style: TextStyle(
                color: Color(0xFF00E5FF),
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _networks.length,
            itemBuilder: (context, index) {
              final n = _networks[index];
              return GestureDetector(
                onTap: () => setState(() => _selectedNetwork = n),
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
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text('${n.level} dBm',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label,
            style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }
}