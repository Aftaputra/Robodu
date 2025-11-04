import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color mainColor = Color(0xFF4CB6B6);
    const Color cardColor = Color(0xFFE8F7F7);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Connected Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: const [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: mainColor,
                      child: Icon(Icons.wifi, color: Colors.white, size: 30),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Terhubung",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Robot-X1 • WiFi",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                "Robot Terdeteksi",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),

              // Robot List
              Expanded(
                child: ListView(
                  children: const [
                    RobotItem(name: "Robot-X1", connected: true),
                    RobotItem(name: "Robot-X1", connected: false),
                    RobotItem(name: "Robot-X1", connected: false),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RobotItem extends StatelessWidget {
  final String name;
  final bool connected;

  const RobotItem({
    super.key,
    required this.name,
    required this.connected,
  });

  @override
  Widget build(BuildContext context) {
    const Color mainColor = Color(0xFF4CB6B6);
    const Color cardColor = Color(0xFFE8F7F7);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: mainColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.smart_toy, color: mainColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  connected ? "Terhubung" : "Sambungkan",
                  style: TextStyle(
                    color: connected ? mainColor : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.signal_cellular_alt, color: mainColor),
        ],
      ),
    );
  }
}
