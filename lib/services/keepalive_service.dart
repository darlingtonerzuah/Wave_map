import 'dart:async';
import 'package:dio/dio.dart';

class KeepAliveService {
  static final KeepAliveService _instance = KeepAliveService._internal();
  factory KeepAliveService() => _instance;
  KeepAliveService._internal();

  Timer? _timer;
  final Dio _dio = Dio();

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 14), (_) async {
      try {
        await _dio.get('https://wifi-ar-backend-1.onrender.com/api/diagnostics');
      } catch (_) {}
    });
  }

  void stop() {
    _timer?.cancel();
  }
}