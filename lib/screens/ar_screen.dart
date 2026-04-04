import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/wifi_service.dart';
import '../models/network_device.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class ARScreen extends StatefulWidget {
  const ARScreen({super.key});

  @override
  State<ARScreen> createState() => _ARScreenState();
}

class _ARScreenState extends State<ARScreen> {
  CameraController? _controller;
  List<NetworkDevice> _networks = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _initCamera();
    _scanNetworks();
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
    final wifiService = WifiService();
    final results = await wifiService.scanDevices();
    setState(() => _networks = results.take(5).toList());
  }

  Color _rssiColor(int rssi) {
    if (rssi >= -50) return Colors.green;
    if (rssi >= -70) return Colors.orange;
    return Colors.red;
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR View'),
        backgroundColor: const Color(0xFF111111),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _scanNetworks,
          )
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00E5FF)))
          : _error.isNotEmpty
              ? Center(
                  child: Text(_error,
                      style: const TextStyle(color: Colors.red)))
              : Stack(
                  children: [
                    // Camera feed
                    SizedBox.expand(
                      child: CameraPreview(_controller!),
                    ),
                   // WiFi overlays
                   if (context.watch<SettingsProvider>().arOverlay)
                     SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Nearby Networks',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(color: Colors.black, blurRadius: 4)
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            ..._networks.map((n) => _networkCard(n)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _networkCard(NetworkDevice network) {
    final color = _rssiColor(network.rssi);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi, color: color, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(network.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
              Text('${network.rssi} dBm',
                  style: TextStyle(color: color, fontSize: 11)),
            ],
          ),
          const SizedBox(width: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(network.status,
                style: TextStyle(color: color, fontSize: 11)),
          )
        ],
      ),
    );
  }
}