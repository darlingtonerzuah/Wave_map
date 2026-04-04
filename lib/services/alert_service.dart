import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AlertService {
  static final AlertService _instance = AlertService._internal();
  factory AlertService() => _instance;
  AlertService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);
    _initialized = true;
  }

  Future<void> showWeakSignalAlert(String networkName, int rssi) async {
    await init();

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'wifi_alert',
        'WiFi Alerts',
        channelDescription: 'Alerts for weak WiFi signal',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
    );

    await _plugin.show(
      0,
      'Weak WiFi Signal',
      '$networkName is weak ($rssi dBm). Consider moving closer to your router.',
      details,
    );
  }
}