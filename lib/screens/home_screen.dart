import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import '../utils/colors.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isConnected = false;
  String robotName = "Robot Camera";
  String status = "Menunggu koneksi...";
  String robotIP = "";
  
  // Variabel untuk slider
  int leftArmValue = 50;
  int rightArmValue = 50;

  // Controller untuk input IP
  final TextEditingController _ipController = TextEditingController();
  
  // Socket untuk komunikasi
  Socket? _socket;
  
  // Stream URL
  String streamUrl = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _socket?.close();
    _ipController.dispose();
    super.dispose();
  }

  // Koneksi ke robot
  Future<void> _connectToRobot() async {
    if (_ipController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Masukkan IP Address robot!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() {
        status = "Menghubungkan...";
      });

      // Koneksi ke robot via Socket (port 8080)
      _socket = await Socket.connect(
        _ipController.text,
        8080,
        timeout: Duration(seconds: 5),
      );

      // Set stream URL
      streamUrl = "http://${_ipController.text}:8081/stream";

      setState(() {
        isConnected = true;
        robotIP = _ipController.text;
        status = "Terhubung";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Berhasil terhubung ke robot!"),
          backgroundColor: AppColors.success,
        ),
      );

      // Listen untuk response dari robot
      _socket!.listen(
        (data) {
          print("Data dari robot: ${utf8.decode(data)}");
        },
        onDone: () {
          _disconnectFromRobot();
        },
        onError: (error) {
          print("Socket error: $error");
          _disconnectFromRobot();
        },
      );
    } catch (e) {
      print("Error connecting: $e");
      setState(() {
        isConnected = false;
        status = "Gagal terhubung";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal terhubung: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Disconnect dari robot
  void _disconnectFromRobot() {
    _socket?.close();
    _socket = null;
    
    setState(() {
      isConnected = false;
      status = "Terputus";
      streamUrl = "";
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Terputus dari robot"),
        backgroundColor: AppColors.error,
      ),
    );
  }

  // Kirim command ke robot
  void _sendCommand(String command, {Map<String, dynamic>? data}) {
    if (!isConnected || _socket == null) return;

    try {
      Map<String, dynamic> message = {
        'command': command,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      if (data != null) {
        message.addAll(data);
      }

      String jsonMessage = jsonEncode(message) + '\n';
      _socket!.write(jsonMessage);
      
      print("Sent command: $command");
    } catch (e) {
      print("Error sending command: $e");
    }
  }

  // Movement commands
  void _moveForward() {
    setState(() => status = "Gerak Maju");
    _sendCommand('forward');
  }

  void _moveBackward() {
    setState(() => status = "Gerak Mundur");
    _sendCommand('backward');
  }

  void _turnLeft() {
    setState(() => status = "Belok Kiri");
    _sendCommand('left');
  }

  void _turnRight() {
    setState(() => status = "Belok Kanan");
    _sendCommand('right');
  }

  void _stop() {
    setState(() => status = "Berhenti");
    _sendCommand('stop');
  }

  // Slider commands
  void _updateLeftArm(int value) {
    setState(() => leftArmValue = value);
    _sendCommand('left_arm', data: {'value': value});
  }

  void _updateRightArm(int value) {
    setState(() => rightArmValue = value);
    _sendCommand('right_arm', data: {'value': value});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              flex: 3,
              child: _buildVideoStream(),
            ),
            Expanded(
              flex: 2,
              child: Container(
                color: Color(0xFFE8F7FA),
                padding: EdgeInsets.all(16),
                child: _buildControlSection(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Connected to :",
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  isConnected ? robotName : "Belum terhubung",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (isConnected)
                  Text(
                    "IP: $robotIP",
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: isConnected ? _disconnectFromRobot : _showConnectDialog,
            style: OutlinedButton.styleFrom(
              foregroundColor: isConnected ? AppColors.error : AppColors.success,
              side: BorderSide(
                color: isConnected ? AppColors.error : AppColors.success,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(isConnected ? "Disconnect" : "Connect"),
          ),
        ],
      ),
    );
  }

  void _showConnectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Connect to Robot"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Masukkan IP Address robot:",
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _ipController,
              decoration: InputDecoration(
                hintText: "192.168.1.100",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.wifi),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 8),
            Text(
              "Pastikan kedua HP terhubung ke WiFi yang sama",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _connectToRobot();
            },
            child: Text("Connect"),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoStream() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isConnected ? Colors.black : Colors.grey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          if (isConnected && streamUrl.isNotEmpty)
            // Video stream menggunakan Image.network dengan auto-refresh
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                streamUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.white, size: 50),
                        SizedBox(height: 8),
                        Text(
                          "Error loading stream",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isConnected ? Icons.videocam : Icons.videocam_off,
                    color: Colors.white,
                    size: 50,
                  ),
                  SizedBox(height: 8),
                  Text(
                    isConnected ? "Loading stream..." : "Tidak Terhubung",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  if (!isConnected) ...[
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _showConnectDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                      ),
                      child: Text("Connect Robot"),
                    ),
                  ],
                ],
              ),
            ),
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                "Status: $status",
                style: TextStyle(
                  color: isConnected ? AppColors.success : AppColors.error,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSlider("L", "Lengan Kiri", leftArmValue, _updateLeftArm),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildSlider("R", "Lengan Kanan", rightArmValue, _updateRightArm),
            ),
          ],
        ),
        SizedBox(height: 20),
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: _buildDirectionalPad(),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: _buildMicrophoneButton(),
              ),
              if (!isConnected)
                Positioned.fill(
                  child: Container(
                    color: Colors.black54,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.wifi_off, color: Colors.white, size: 40),
                          SizedBox(height: 8),
                          Text(
                            "Robot Tidak Terhubung",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _showConnectDialog,
                            child: Text("Connect Sekarang"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSlider(String label, String description, int value, Function(int) onUpdate) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: value > 0 ? () => onUpdate(value - 10) : null,
            child: Icon(
              Icons.remove,
              color: value > 0 ? AppColors.primary : Colors.grey,
              size: 20,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: value < 100 ? () => onUpdate(value + 10) : null,
            child: Icon(
              Icons.add,
              color: value < 100 ? AppColors.success : Colors.grey,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionalPad() {
    final double buttonSize = 64;

    return Container(
      width: buttonSize * 3,
      height: buttonSize * 3,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: buttonSize,
            child: _buildDirectionButton(
              Icons.keyboard_arrow_up,
              _moveForward,
              buttonSize,
            ),
          ),
          Positioned(
            top: buttonSize,
            left: 0,
            child: _buildDirectionButton(
              Icons.keyboard_arrow_left,
              _turnLeft,
              buttonSize,
            ),
          ),
          Positioned(
            top: buttonSize,
            left: buttonSize * 2,
            child: _buildDirectionButton(
              Icons.keyboard_arrow_right,
              _turnRight,
              buttonSize,
            ),
          ),
          Positioned(
            top: buttonSize * 2,
            left: buttonSize,
            child: _buildDirectionButton(
              Icons.keyboard_arrow_down,
              _moveBackward,
              buttonSize,
            ),
          ),
          Positioned(
            top: buttonSize,
            left: buttonSize,
            child: GestureDetector(
              onTap: _stop,
              child: Container(
                width: buttonSize,
                height: buttonSize,
                decoration: BoxDecoration(
                  color: isConnected ? Color(0xFFE97451) : Colors.grey,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isConnected ? AppColors.accent : Colors.grey,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    "STOP",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionButton(IconData icon, VoidCallback onPressed, double size) {
    return GestureDetector(
      onTap: isConnected ? onPressed : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isConnected ? AppColors.cardBackground : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isConnected ? AppColors.accent : Colors.grey,
            width: 2,
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            color: isConnected ? AppColors.success : Colors.grey,
            size: 32,
          ),
        ),
      ),
    );
  }

  Widget _buildMicrophoneButton() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isConnected ? AppColors.cardBackground : Colors.grey[300],
        shape: BoxShape.circle,
        border: Border.all(
          color: isConnected ? AppColors.accent : Colors.grey,
          width: 2,
        ),
      ),
      child: Icon(
        Icons.mic,
        color: isConnected ? AppColors.success : Colors.grey,
        size: 20,
      ),
    );
  }
}