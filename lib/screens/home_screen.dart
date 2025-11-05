import 'package:flutter/material.dart';
import 'package:robodu/utils/helper.dart';
import 'package:robodu/utils/logger.dart';
import 'dart:io';
import 'dart:convert';
import '../utils/colors.dart';
import '../utils/strings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isConnected = false;
  // TODO: change this to actual robot name
  String robotName = "Robot Camera";
  String status = HomeText.waitingConnection;
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

  String setIp(String ip) => 'IP: $ip';
  String setStatus(String status) => 'Status: $status';

  // Koneksi ke robot
  Future<void> _connectToRobot() async {
    if (_ipController.text.isEmpty) {
      AppHelper.showSnackBarError(HomeText.inputIpRobot);
      return;
    }

    try {
      setState(() {
        status = HomeText.connecting;
      });

      // Koneksi ke robot via Socket (port 8080)
      _socket = await Socket.connect(
        _ipController.text,
        8080,
        timeout: const Duration(seconds: 5),
      );

      if (!mounted) return;
      
      // Set stream URL
      streamUrl = "http://${_ipController.text}:8081/stream";

      setState(() {
        isConnected = true;
        robotIP = _ipController.text;
        status = HomeText.connected;
      });

      AppHelper.showSnackBarSuccess(HomeText.robotConnected);

      // Listen untuk response dari robot
      _socket!.listen(
        (data) {
          AppLogger.info('Data dari robot: ${utf8.decode(data)}');
        },
        onDone: () {
          _disconnectFromRobot();
        },
        onError: (error) {
          AppLogger.error('Socket error: $error');
          _disconnectFromRobot();
        },
      );
    } catch (e) {
      AppLogger.error('Error connecting: $e');
      setState(() {
        isConnected = false;
        status = HomeText.failedToConnect;
      });

      AppHelper.showSnackBarError('${HomeText.failedToConnect}: $e');
    }
  }

  // Disconnect dari robot
  void _disconnectFromRobot() {
    _socket?.close();
    _socket = null;
    
    setState(() {
      isConnected = false;
      status = HomeText.disconnected;
      streamUrl = "";
    });

    AppHelper.showSnackBarError(HomeText.robotDisconnected);
  }

  // Kirim command ke robot
  void _sendCommand(String command, {Map<String, dynamic>? data}) {
    if (!isConnected || _socket == null) return;

    try {
      Map<String, dynamic> message = {
        command: command,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      if (data != null) {
        message.addAll(data);
      }

      String jsonMessage = '${jsonEncode(message)}\n';
      _socket!.write(jsonMessage);
      
      AppLogger.info('Sent command: $command');
      
    } catch (e) {
      AppLogger.error('Error sending command: $e');
    }
  }

  // Movement commands
  void _moveForward() {
    setState(() => status = HomeText.moveForward);
    _sendCommand('forward');
  }

  void _moveBackward() {
    setState(() => status = HomeText.moveBackwards);
    _sendCommand('backward');
  }

  void _turnLeft() {
    setState(() => status = HomeText.turnLeft);
    _sendCommand('left');
  }

  void _turnRight() {
    setState(() => status = HomeText.turnRight);
    _sendCommand('right');
  }

  void _stop() {
    setState(() => status = HomeText.moveStop);
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
                color: const Color(0xFFE8F7FA),
                padding: const EdgeInsets.all(16),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  HomeText.connectedTo,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  isConnected ? robotName : HomeText.notConnected,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (isConnected)
                  Text(
                    setIp(robotIP),
                    style: const TextStyle(
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
            child: Text(isConnected ? HomeText.btnDisconnect : HomeText.btnConnect),
          ),
        ],
      ),
    );
  }

  void _showConnectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(HomeText.connectToRobot),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              HomeText.inputIpRobot,
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ipController,
              decoration: const InputDecoration(
                hintText: HomeText.inputIpHint,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.wifi),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 8),
            const Text(
              HomeText.hintConnectToRobot,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(HomeText.btnCancelled),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _connectToRobot();
            },
            child: const Text(HomeText.btnConnect),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoStream() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.white, size: 50),
                        SizedBox(height: 8),
                        Text(
                          HomeText.streamError,
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
                  const SizedBox(height: 8),
                  Text(
                    isConnected ? HomeText.streamLoading : HomeText.notConnected,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  if (!isConnected) ...[
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _showConnectDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                      ),
                      child: const Text(HomeText.btnConnect),
                    ),
                  ],
                ],
              ),
            ),
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(153),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                setStatus(status),
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
              child: _buildSlider(HomeText.l, HomeText.ctlLeftHand, leftArmValue, _updateLeftArm),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSlider(HomeText.l, HomeText.ctlRightHand, rightArmValue, _updateRightArm),
            ),
          ],
        ),
        const SizedBox(height: 20),
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
                          const Icon(Icons.wifi_off, color: Colors.white, size: 40),
                          const SizedBox(height: 8),
                          const Text(
                            HomeText.robotNotConnected,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _showConnectDialog,
                            child: const Text(HomeText.btnConnect),
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
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                description,
                style: const TextStyle(
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
    const double buttonSize = 64;

    return SizedBox(
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
                  color: isConnected ? const Color(0xFFE97451) : Colors.grey,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isConnected ? AppColors.accent : Colors.grey,
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Text(
                    HomeText.stop,
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