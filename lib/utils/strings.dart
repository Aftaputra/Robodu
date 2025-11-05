// Main
class MainText {
  static const String appName = 'Robo-du';
  static const String title = 'Robo-du Control';
  static const String labelHome = 'Home';
  static const String labelStatus = 'Status';
  static const String labelSetting = 'Setting';
}

// Home Screen
class HomeText {
  // status
  static const String waitingConnection = 'Menunggu Koneksi';
  static const String connecting = 'Menghubungkan';
  static const String connected = 'Terhubung';
  static const String notConnected = 'Belum Terhubung';
  static const String disconnected = 'Terputus';
  static const String failedToConnect = 'Gagal Terhubung';
  // movement
  static const String moveForward = 'Bergerak Maju';
  static const String moveBackwards = 'Bergerak Mundur';
  static const String moveStop = 'Berhenti';
  static const String turnRight = 'Berbelok kanan';
  static const String turnLeft = 'Berbelok kiri';

  static const String inputIpRobot = 'Masukkan IP Address Robot';
  static const String robotConnected = 'Berhasil Terhubung ke Robot';
  static const String robotDisconnected = 'Terputus dari Robot';
  static const String robotNotConnected = 'Robot tidak terhubung';
  static const String connectedTo = 'Terhubung ke: ';
  static const String connectToRobot = 'Hubungkan ke Robot';
  static const String inputIpHint = '192.168.1.100';
  static const String hintConnectToRobot = 'Pastikan kedua HP terhubung ke WiFi yang sama';
  // Stream
  static const String streamError = 'Error Melakukan Stream';
  static const String streamLoading = 'Melakukan Stream';
  // Control
  static const String l = 'L';
  static const String r = 'r';
  static const String ctlLeftHand = 'Lengan Kiri';
  static const String ctlRightHand = 'Lengan Kanan';
  static const String stop = 'STOP';
  // button
  static const String btnConnect = 'Hubungkan';
  static const String btnDisconnect = 'Putuskan';
  static const String btnCancelled = 'Batal';
}

// Status Screen
class StatusText {
  static const String title = 'Status Robot';
  static const String subTitleSensor = 'Status';
  static const String sensorCameraStatus = 'Kamera';
  static const String sensorEnoseStatus = 'Enose';
  static const String subTitleEnose = 'ENose';
  static const String enoseSensorResult = 'Hasil Klasifikasi';
  static const String subTitleLog = 'Log Aktivitas';
  static const String logConnected = 'Terkoneksi';
  static const String logMoveForward = 'Bergerak Maju';
  static const String logMoveStop = 'Berhenti';
  static const String logTurnRight = 'Berbelok kanan';
  static const String logTurnLeft = 'Berbelok kiri';
  static const String logRightHandMove = 'Menggerakkan Tangan Kanan';
  static const String logLeftHandMove = 'Menggerakkan Tangan Kiri';
  static const String logSpeakRobodu = 'Mengucapkan Robodu';
  static const String logIntroduceSelf = 'Memperkenalkan Diri';
}

// Setting Screen
class SettingText {
  static const String connect = 'Sambungkan';
  static const String connected = 'Terhubung';
  static const String notConnected = 'Tidak Terhubung';
  static const String wifi = 'WiFi';
  static const String robotDetected = 'Robot Terdeteksi';
}