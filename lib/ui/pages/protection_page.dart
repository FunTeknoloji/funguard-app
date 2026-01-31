import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_state.dart';

class ProtectionPage extends StatelessWidget {
  const ProtectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Koruma Merkezi', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProtectionStatus(appState),
            const SizedBox(height: 30),
            const Text('Aktif Taramalar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _buildScanItem('WhatsApp Takibi', appState.isAutoScanEnabled),
            _buildScanItem('Telegram Takibi', appState.isAutoScanEnabled),
            _buildScanItem('SMS Koruması', appState.isAutoScanEnabled),
            _buildScanItem('USOM URL Kontrolü', appState.isUSOMProtectionEnabled),
            const SizedBox(height: 30),
            const Text('Son Tespitler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _buildDetectionHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildProtectionStatus(AppState state) {
    bool isActive = state.isAutoScanEnabled && state.isUSOMProtectionEnabled;
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isActive
              ? [Colors.purple[900]!, Colors.purple[700]!]
              : [Colors.red[900]!, Colors.red[700]!],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: (isActive ? Colors.purple : Colors.red).withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          )
        ],
      ),
      child: Row(
        children: [
          Icon(isActive ? Icons.verified_user : Icons.gpp_maybe, size: 50, color: Colors.white),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isActive ? 'Sistem Güvende' : 'Sistem Risk Altında',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  isActive ? 'Gerçek zamanlı AI koruması aktif.' : 'Kritik koruma özellikleri kapalı!',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanItem(String title, bool isEnabled) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Row(
            children: [
              Text(isEnabled ? 'AKTİF' : 'DEVRE DIŞI',
                style: TextStyle(color: isEnabled ? Colors.greenAccent : Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(width: 10),
              Icon(isEnabled ? Icons.check_circle : Icons.cancel, color: isEnabled ? Colors.greenAccent : Colors.redAccent, size: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetectionHistory() {
    return Column(
      children: [
        _buildHistoryItem('WhatsApp', 'Şüpheli Link Engellendi', '12:45', Colors.orange),
        _buildHistoryItem('SMS', 'Dolandırıcılık Girişimi', 'Dün', Colors.red),
        _buildHistoryItem('USOM', 'Zararlı Site Erişimi', '2 gün önce', Colors.red),
      ],
    );
  }

  Widget _buildHistoryItem(String source, String message, String time, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(15),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(source, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(message, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
