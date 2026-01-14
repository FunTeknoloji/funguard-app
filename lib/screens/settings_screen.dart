import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _smsPermission = false;
  bool _notificationPermission = false;
  bool _autoProtection = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _loadSettings();
  }

  Future<void> _checkPermissions() async {
    final sms = await Permission.sms.status;
    final notification = await Permission.notification.status;

    setState(() {
      _smsPermission = sms.isGranted;
      _notificationPermission = notification.isGranted;
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoProtection = prefs.getBool('auto_protection') ?? false;
    });
  }

  Future<void> _toggleAutoProtection(bool value) async {
    if (value && !_smsPermission) {
      await _requestSmsPermission();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_protection', value);
    setState(() => _autoProtection = value);
  }

  Future<void> _requestSmsPermission() async {
    final status = await Permission.sms.request();
    setState(() => _smsPermission = status.isGranted);

    if (status.isGranted) {
      await _toggleAutoProtection(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildProfileCard(),
          const SizedBox(height: 24),
          _buildSectionTitle('Güvenlik'),
          _buildSettingCard(
            icon: Icons.shield,
            title: 'Otomatik Koruma',
            subtitle: 'SMS ve linkleri otomatik tara',
            trailing: Switch(
              value: _autoProtection,
              onChanged: _toggleAutoProtection,
              activeColor: const Color(0xFF6366F1),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('İzinler'),
          _buildPermissionCard(
            icon: Icons.sms,
            title: 'SMS İzni',
            granted: _smsPermission,
            onTap: _requestSmsPermission,
          ),
          _buildPermissionCard(
            icon: Icons.notifications,
            title: 'Bildirim İzni',
            granted: _notificationPermission,
            onTap: () async {
              await Permission.notification.request();
              await _checkPermissions();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kullanıcı',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'FunGuard ile korunuyorsunuz',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white70,
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF6366F1)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildPermissionCard({
    required IconData icon,
    required String title,
    required bool granted,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (granted ? Colors.green : Colors.orange).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: granted ? Colors.green : Colors.orange,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  granted ? 'İzin verildi' : 'İzin gerekli',
                  style: TextStyle(
                    color: granted ? Colors.green : Colors.orange,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (!granted)
            TextButton(
              onPressed: onTap,
              child: const Text('İzin Ver'),
            ),
        ],
      ),
    );
  }
}
