import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader('Güvenlik Ayarları'),
          _buildSwitchTile(
            title: 'Otomatik Analiz',
            subtitle: 'Gelen bildirimleri otomatik tara',
            value: appState.isAutoScanEnabled,
            onChanged: (val) => appState.setAutoScan(val),
            icon: Icons.auto_awesome,
          ),
          _buildSwitchTile(
            title: 'Global Güvenlik Veritabanı',
            subtitle: 'Bilinen zararlı bağlantıları otomatik engelle',
            value: appState.isUSOMProtectionEnabled,
            onChanged: (val) => appState.setUSOMProtection(val),
            icon: Icons.security,
          ),
          const SizedBox(height: 20),
          _buildSectionHeader('Sistem İzinleri'),
          _buildPermissionTile(
            context,
            title: 'Bildirim Erişimi',
            subtitle: 'Mesajları okuyabilmek için gereklidir',
            icon: Icons.notifications_active,
            onTap: () => appState.openNotificationSettings(),
          ),
          _buildPermissionTile(
            context,
            title: 'Ekran Üstünde Gösterim',
            subtitle: 'Uyarı pencereleri için gereklidir',
            icon: Icons.layers,
            onTap: () => appState.requestOverlayPermission(),
          ),
          const SizedBox(height: 20),
          _buildSectionHeader('Uygulama'),
          _buildListTile(
            title: 'Hakkında',
            icon: Icons.info_outline,
            onTap: () {},
          ),
          _buildListTile(
            title: 'Yardım & Destek',
            icon: Icons.help_outline,
            onTap: () {},
          ),
          const SizedBox(height: 40),
          Center(
            child: Text(
              'FunGuard v1.0.0',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildSwitchTile({required String title, required String subtitle, required bool value, required Function(bool) onChanged, required IconData icon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.purpleAccent),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.purpleAccent,
        ),
      ),
    );
  }

  Widget _buildPermissionTile(BuildContext context, {required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildListTile({required String title, required IconData icon, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
