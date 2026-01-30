import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_state.dart';
import 'text_analysis_page.dart';
import 'link_analysis_page.dart';
import 'settings_page.dart';
import 'general_analysis_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('FunGuard AI', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildShield(appState),
            const SizedBox(height: 30),
            _buildStatusCard(appState),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _buildCategoryCard(context, 'Metin Analizi', Icons.text_snippet, const TextAnalysisPage()),
                  _buildCategoryCard(context, 'Link Tarama', Icons.link, const LinkAnalysisPage()),
                  _buildCategoryCard(context, 'SMS Koruması', Icons.sms, const GeneralAnalysisPage(title: 'SMS Analizi', hintText: 'Gelen SMS içeriğini buraya yapıştırın...')),
                  _buildCategoryCard(context, 'E-Posta Kontrol', Icons.email, const GeneralAnalysisPage(title: 'E-Posta Analizi', hintText: 'E-posta içeriğini veya gönderen bilgilerini yapıştırın...')),
                  _buildCategoryCard(context, 'Sosyal Medya', Icons.share, const GeneralAnalysisPage(title: 'Sosyal Medya', hintText: 'DM veya sosyal medya mesajını buraya yapıştırın...')),
                  _buildCategoryCard(context, 'Arama Analizi', Icons.call, const GeneralAnalysisPage(title: 'Arama Analizi', hintText: 'Sizi arayan numara veya konuşma içeriğini analiz edin...')),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildShield(AppState state) {
    bool isProtected = state.isAutoScanEnabled && state.isUSOMProtectionEnabled;
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(seconds: 4),
        curve: Curves.linear,
        builder: (context, value, child) {
          return Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isProtected ? Colors.purple : Colors.red).withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
              gradient: SweepGradient(
                colors: [
                  Colors.purple.shade900,
                  Colors.black,
                  Colors.purple.shade400,
                  Colors.black,
                  Colors.purple.shade900,
                ],
                stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                transform: GradientRotation(value * 6.28 * 2),
              ),
            ),
            child: Center(
              child: Container(
                width: 180,
                height: 180,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                ),
                child: Icon(
                  isProtected ? Icons.shield : Icons.shield_outlined,
                  size: 100,
                  color: isProtected ? Colors.greenAccent : Colors.redAccent,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(AppState state) {
    bool isProtected = state.isAutoScanEnabled && state.isUSOMProtectionEnabled;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            isProtected ? Icons.check_circle : Icons.warning,
            color: isProtected ? Colors.greenAccent : Colors.orangeAccent,
            size: 40,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isProtected ? 'Tam Koruma Aktif' : 'Koruma Eksik',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  isProtected ? 'Sisteminiz yapay zeka ile korunuyor.' : 'Bazı güvenlik özellikleri kapalı.',
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, IconData icon, Widget? targetPage) {
    return InkWell(
      onTap: () {
        if (targetPage != null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => targetPage));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bu özellik yakında eklenecek!')),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.purple.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.purpleAccent),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
