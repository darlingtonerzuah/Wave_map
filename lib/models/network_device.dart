class NetworkDevice {
  final String name;
  final String ip;
  final int rssi;
  final String status;

  NetworkDevice({
    required this.name,
    required this.ip,
    required this.rssi,
    required this.status,
  });
}