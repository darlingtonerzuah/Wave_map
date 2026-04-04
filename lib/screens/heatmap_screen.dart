import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/scan_point.dart';
import '../painters/heatmap_painter.dart';
import '../providers/settings_provider.dart';
import '../services/alert_service.dart';

class HeatmapScreen extends StatefulWidget {
  const HeatmapScreen({super.key});

  @override
  State<HeatmapScreen> createState() => _HeatmapScreenState();
}

class _HeatmapScreenState extends State<HeatmapScreen> {
  List<WiFiAccessPoint> _networks = [];
  int _currentNetworkIndex = 0;
  Map<String, List<ScanPoint>> _networkPoints = {};
  bool _scanning = false;
  bool _loadingNetworks = true;

  @override
  void initState() {
    super.initState();
    _loadSavedPoints();
    _loadNetworks();
  }

  Future<void> _loadSavedPoints() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('heatmap_points');
    if (saved != null) {
      final Map<String, dynamic> decoded = jsonDecode(saved);
      setState(() {
        _networkPoints = decoded.map((key, value) => MapEntry(
              key,
              (value as List)
                  .map((e) => ScanPoint.fromJson(e))
                  .toList(),
            ));
      });
    }
  }

  Future<void> _savePoints() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_networkPoints
        .map((key, value) => MapEntry(key, value.map((e) => e.toJson()).toList())));
    await prefs.setString('heatmap_points', encoded);
  }

  Future<void> _loadNetworks() async {
    setState(() => _loadingNetworks = true);
    await Permission.location.request();
    final can = await WiFiScan.instance.canStartScan();
    if (can == CanStartScan.yes) {
      await WiFiScan.instance.startScan();
    }
    final results = await WiFiScan.instance.getScannedResults();
    setState(() {
      _networks = results;
      _loadingNetworks = false;
    });
  }

  WiFiAccessPoint? get _currentNetwork =>
      _networks.isEmpty ? null : _networks[_currentNetworkIndex];

  List<ScanPoint> get _currentPoints =>
      _currentNetwork == null ? [] : (_networkPoints[_currentNetwork!.bssid] ?? []);

  Future<void> _onTap(TapUpDetails details) async {
    if (_scanning || _currentNetwork == null) return;
    setState(() => _scanning = true);

    final can = await WiFiScan.instance.canGetScannedResults();
    if (can == CanGetScannedResults.yes) {
      final results = await WiFiScan.instance.getScannedResults();
      final match = results.where((r) => r.bssid == _currentNetwork!.bssid).toList();

      if (match.isNotEmpty) {
        final rssi = match.first.level;
        final bssid = _currentNetwork!.bssid;

        setState(() {
          _networkPoints[bssid] = [
            ...(_networkPoints[bssid] ?? []),
            ScanPoint(position: details.localPosition, rssi: rssi),
          ];
        });

        await _savePoints();

        final settings = context.read<SettingsProvider>();
        if (settings.alerts && rssi < -70) {
          AlertService().showWeakSignalAlert(
              _currentNetwork!.ssid.isEmpty
                  ? 'Hidden Network'
                  : _currentNetwork!.ssid,
              rssi);
        }
      }
    }

    setState(() => _scanning = false);
  }

  void _previousNetwork() {
    if (_currentNetworkIndex > 0) setState(() => _currentNetworkIndex--);
  }

  void _nextNetwork() {
    if (_currentNetworkIndex < _networks.length - 1) {
      setState(() => _currentNetworkIndex++);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        title: _loadingNetworks
            ? const Text('Scanning...')
            : _networks.isEmpty
                ? const Text('No Networks')
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: _currentNetworkIndex > 0 ? _previousNetwork : null,
                        color: _currentNetworkIndex > 0
                            ? const Color(0xFF00E5FF)
                            : Colors.grey,
                      ),
                      Expanded(
                        child: Text(
                          _currentNetwork!.ssid.isEmpty
                              ? 'Hidden Network'
                              : _currentNetwork!.ssid,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: _currentNetworkIndex < _networks.length - 1
                            ? _nextNetwork
                            : null,
                        color: _currentNetworkIndex < _networks.length - 1
                            ? const Color(0xFF00E5FF)
                            : Colors.grey,
                      ),
                    ],
                  ),
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
            onPressed: () async {
              if (_currentNetwork != null) {
                setState(() => _networkPoints[_currentNetwork!.bssid] = []);
                await _savePoints();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNetworks,
          ),
        ],
      ),
      body: _loadingNetworks
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00E5FF)))
          : GestureDetector(
              onTapUp: (details) => _onTap(details),
              child: CustomPaint(
                painter: HeatmapPainter(points: _currentPoints),
                child: Container(color: Colors.transparent),
              ),
            ),
    );
  }
}