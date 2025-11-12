import 'package:flutter/material.dart';
import 'package:robodu/utils/strings.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  String setName(String name) => '$name • WiFi';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<WifiNetwork> availableNetworks = [];
  String? connectedSSID;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initPermissions();
  }

  Future<void> _initPermissions() async {
    // Request location and nearby WiFi permission (for Android 13+)
    await Permission.location.request();
    await Permission.nearbyWifiDevices.request();
    _loadWiFiStatus();
  }

  Future<void> _loadWiFiStatus() async {
    setState(() => isLoading = true);

    // Get current connection
    final connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.wifi) {
      connectedSSID = await WiFiForIoTPlugin.getSSID();
    } else {
      connectedSSID = null;
    }

    // Load available networks
    try {
      final networks = await WiFiForIoTPlugin.loadWifiList();

      // urutkan berdasarkan kekuatan sinyal (terkuat di atas)
      networks.sort((a, b) => (b.level ?? -100).compareTo(a.level ?? -100));
      // hapus duplikat SSID, sisakan yang paling kuat
      networks.retainWhere((net) {
        final firstIndex = networks.indexWhere((n) => n.ssid == net.ssid);
        return firstIndex == networks.indexOf(net);
      });
      
      setState(() {
        availableNetworks = networks;
      });
    } catch (e) {
      debugPrint("Error scanning Wi-Fi: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memindai jaringan WiFi")),
      );
    }

    setState(() => isLoading = false);
  }

  Future<void> _connectToNetwork(String ssid, {String? password}) async {
    try {
      final result = await WiFiForIoTPlugin.connect(
        ssid,
        password: password,
        joinOnce: true,
        security: NetworkSecurity.WPA,
      );
      if (result) {
        setState(() => connectedSSID = ssid);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Berhasil terhubung ke $ssid")),
        );
      }
    } catch (e) {
      debugPrint("Error connecting to $ssid: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal terhubung ke $ssid")),
      );
    }
  }

  Future<void> _disconnect() async {
    await WiFiForIoTPlugin.disconnect();
    setState(() {
      connectedSSID = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Koneksi diputus")),
    );
  }

  void _promptForPassword(String ssid) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Masukkan Password untuk $ssid'),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Password'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _connectToNetwork(ssid, password: controller.text);
            },
            child: const Text('Hubungkan'),
          ),
        ],
      ),
    );
  }

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
              // Connection status
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: mainColor,
                      child: Icon(Icons.wifi, color: Colors.white, size: 30),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      connectedSSID != null
                          ? "Terhubung"
                          : "Tidak Terhubung",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      connectedSSID ?? "Tidak ada koneksi",
                      style: const TextStyle(color: Colors.black54),
                    ),
                    if (connectedSSID != null)
                      TextButton(
                        onPressed: _disconnect,
                        child: const Text(
                          "Putuskan",
                          style: TextStyle(color: mainColor),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Robot Terdeteksi",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: mainColor),
                    onPressed: _loadWiFiStatus,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // WiFi list
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : availableNetworks.isEmpty
                    ? const Center(
                  child: Text(
                    "Tidak ada jaringan terdeteksi",
                    style: TextStyle(color: Colors.black54),
                  ),
                )
                    : ListView.builder(
                  itemCount: availableNetworks.length,
                  itemBuilder: (context, index) {
                    final net = availableNetworks[index];
                    final ssid = net.ssid ?? "Unknown";
                    final isConnected = connectedSSID == ssid;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.smart_toy,
                              color: mainColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ssid,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  isConnected
                                      ? "Terhubung"
                                      : "Sambungkan",
                                  style: TextStyle(
                                    color: isConnected
                                        ? mainColor
                                        : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isConnected)
                            IconButton(
                              icon: const Icon(Icons.wifi,
                                  color: mainColor),
                              onPressed: () =>
                                  _promptForPassword(ssid),
                            ),
                        ],
                      ),
                    );
                  },
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
  final VoidCallback onTap;

  const RobotItem({
    super.key,
    required this.name,
    required this.connected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color mainColor = Color(0xFF4CB6B6);
    const Color cardColor = Color(0xFFE8F7F7);

    return InkWell(
      onTap: onTap,
      child: Container(
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
                    connected ? SettingText.connected : SettingText.connect,
                    style: TextStyle(
                      color: connected ? mainColor : Colors.black54,
                    ),
                  )
                ],
              ),
            ),
            Icon(
              Icons.signal_cellular_alt,
              color: connected ? mainColor : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
