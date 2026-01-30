import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Otomatik Tarama'),
            subtitle: const Text('Gelen bildirimleri (WhatsApp, Telegram) otomatik analiz eder.'),
            value: appState.isAutoScanEnabled,
            onChanged: (val) => appState.setAutoScan(val),
            activeColor: Colors.purpleAccent,
          ),
          SwitchListTile(
            title: const Text('USOM Koruması'),
            subtitle: const Text('URL\'leri USOM veritabanı üzerinden anlık kontrol eder.'),
            value: appState.isUSOMProtectionEnabled,
            onChanged: (val) => appState.setUSOMProtection(val),
            activeColor: Colors.purpleAccent,
          ),
          const Divider(),
          const ListTile(
            title: Text('Uygulama Sürümü'),
            trailing: Text('1.0.0'),
          ),
          ListTile(
            title: const Text('Bildirim Erişimini Aç'),
            subtitle: const Text('Otomatik tarama için gereklidir.'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {
              const intent = 'android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS';
              const channel = MethodChannel('com.funguard.app/notifications');
              channel.invokeMethod('openNotificationSettings');
            },
          ),
          ListTile(
            title: const Text('USOM Listesini Güncelle'),
            trailing: const Icon(Icons.refresh),
            onTap: () async {
              await appState.usomService.fetchUrlList();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('USOM listesi güncellendi.')),
              );
            },
          ),
          const AboutListTile(
            applicationName: 'FunGuard AI',
            applicationVersion: '1.0.0',
            applicationIcon: Icon(Icons.security, color: Colors.purpleAccent),
            aboutBoxChildren: [
              Text('FunGuard, yapay zeka destekli bir dolandırıcı önleme uygulamasıdır.'),
            ],
          ),
        ],
      ),
    );
  }
}
