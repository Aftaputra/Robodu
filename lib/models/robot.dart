class Robot {
  final String id;
  final String name;
  String status;
  bool isConnected;
  final String ipAddress;
  final int signalStrength;
  final String ssid; // Tambahkan field SSID

  Robot({
    required this.id,
    required this.name,
    required this.status,
    required this.isConnected,
    required this.ipAddress,
    required this.signalStrength,
    required this.ssid,
  });
}