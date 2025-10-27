import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../models/robot.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<Robot> detectedRobots = [
    Robot(
      id: "1",
      name: "Robo-du 123",
      status: "Terhubung",
      isConnected: true,
      ipAddress: "192.168.1.100",
      signalStrength: 4,
      ssid: "ata", // Tambahkan SSID
    ),
    Robot(
      id: "2",
      name: "Robot-X2",
      status: "Sambungkan",
      isConnected: false,
      ipAddress: "192.168.1.101",
      signalStrength: 3,
      ssid: "Robot-X2",
    ),
    Robot(
      id: "3",
      name: "SmartBot-001",
      status: "Sambungkan",
      isConnected: false,
      ipAddress: "192.168.1.102",
      signalStrength: 2,
      ssid: "SmartBot",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              _buildConnectionStatus(),
              SizedBox(height: 20),
              _buildRobotDetection(),
              SizedBox(height: 20),
              Expanded(child: _buildRobotList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.wifi,
              color: Colors.white,
              size: 30,
            ),
          ),
          SizedBox(height: 16),
          Text(
            "Terhubung",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "Robo-du 123 • WiFi", // Tetap placeholder
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "SSID: ata", // Info SSID
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRobotDetection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Robot Terdeteksi",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        IconButton(
          onPressed: () {
            // Refresh detection
            setState(() {});
          },
          icon: Icon(
            Icons.refresh,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildRobotList() {
    return ListView.builder(
      itemCount: detectedRobots.length,
      itemBuilder: (context, index) {
        final robot = detectedRobots[index];
        return _buildRobotItem(robot);
      },
    );
  }

  Widget _buildRobotItem(Robot robot) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Robot Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.smart_toy,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          SizedBox(width: 12),
          
          // Robot Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  robot.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  "SSID: ${robot.ssid}", // Tampilkan SSID
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  robot.status,
                  style: TextStyle(
                    fontSize: 14,
                    color: robot.isConnected 
                        ? AppColors.success 
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Signal Strength
          _buildSignalStrength(robot.signalStrength),
        ],
      ),
    );
  }

  Widget _buildSignalStrength(int strength) {
    return Row(
      children: List.generate(4, (index) {
        return Container(
          width: 4,
          height: (index + 1) * 4.0 + 8,
          margin: EdgeInsets.only(right: 2),
          decoration: BoxDecoration(
            color: index < strength 
                ? AppColors.primary 
                : Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}