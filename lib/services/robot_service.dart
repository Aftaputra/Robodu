import 'dart:io';
import 'dart:convert';

class RobotService {
  static const int robotPort = 8080;
  Socket? _socket;
  
  // Connect to robot via TCP socket
  Future<bool> connectToRobot(String ipAddress) async {
    try {
      _socket = await Socket.connect(ipAddress, robotPort, timeout: Duration(seconds: 5));
      return true;
    } catch (e) {
      print("Error connecting to robot: $e");
      return false;
    }
  }
  
  // Send movement command
  Future<void> sendCommand(String command) async {
    if (_socket != null) {
      try {
        _socket!.write('$command\n');
        await _socket!.flush();
        print("Command sent: $command");
      } catch (e) {
        print("Error sending command: $e");
      }
    }
  }
  
  // Disconnect from robot
  void disconnect() {
    _socket?.close();
    _socket = null;
  }
  
  // Specific movement commands
  Future<void> moveForward() => sendCommand('FORWARD');
  Future<void> moveBackward() => sendCommand('BACKWARD');
  Future<void> turnLeft() => sendCommand('LEFT');
  Future<void> turnRight() => sendCommand('RIGHT');
  Future<void> stop() => sendCommand('STOP');
  Future<void> leftArm(int value) => sendCommand('L_ARM:$value');
  Future<void> rightArm(int value) => sendCommand('R_ARM:$value');
}