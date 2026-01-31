import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_state.dart';
import 'text_analysis_page.dart';
import 'link_analysis_page.dart';
import 'general_analysis_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D001A), Colors.black],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hoş Geldin,', style: TextStyle(color: Colors.grey, fontSize: 16)),
                          Text('FunGuard Güvendesin', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.purple.withOpacity(0.3)),
                        ),
                        child: const Icon(Icons.notifications_outlined, color: Colors.purpleAccent),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                _buildGlowingShield(appState),
                const SizedBox(height: 40),
                _buildProtectionBadges(appState),
                const SizedBox(height: 40),
                _buildActionGrid(context),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlowingShield(AppState state) {
    bool isProtected = state.isAutoScanEnabled && state.isUSOMProtectionEnabled;
    Color primaryColor = isProtected ? Colors.purpleAccent : Colors.redAccent;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.2),
                  blurRadius: 60,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
          // Spinning border
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(seconds: 10),
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value * 2 * 3.14159,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.transparent),
                    gradient: SweepGradient(
                      colors: [
                        primaryColor.withOpacity(0.0),
                        primaryColor,
                        primaryColor.withOpacity(0.0),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              );
            },
          ),
          // Inner Circle
          Container(
            width: 190,
            height: 190,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0D001A),
              border: Border.all(color: primaryColor.withOpacity(0.3), width: 2),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                  inset: true,
                ) as BoxShadow,
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isProtected ? Icons.shield : Icons.shield_outlined,
                  size: 80,
                  color: primaryColor,
                ),
                const SizedBox(height: 10),
                Text(
                  isProtected ? 'KORUNUYORSUNUZ' : 'RİSK ALTINDASINIZ',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProtectionBadges(AppState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildBadge('AI Analiz', state.isAutoScanEnabled),
        _buildBadge('USOM', state.isUSOMProtectionEnabled),
        _buildBadge('Canlı Takip', state.isAutoScanEnabled),
      ],
    );
  }

  Widget _buildBadge(String label, bool active) {
    return Column(
      children: [
        Icon(active ? Icons.check_circle : Icons.error_outline,
          color: active ? Colors.greenAccent : Colors.grey, size: 20),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Güvenlik Araçları', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.5,
            children: [
              _buildModernCard(context, 'Metin Analiz', Icons.description_rounded, const TextAnalysisPage()),
              _buildModernCard(context, 'Link Tarama', Icons.link_rounded, const LinkAnalysisPage()),
              _buildModernCard(context, 'SMS Koruma', Icons.message_rounded, const GeneralAnalysisPage(title: 'SMS Analizi', hintText: 'SMS içeriğini buraya yapıştırın...')),
              _buildModernCard(context, 'E-Posta', Icons.email_rounded, const GeneralAnalysisPage(title: 'E-Posta Analizi', hintText: 'E-posta içeriğini yapıştırın...')),
              _buildModernCard(context, 'Sosyal Medya', Icons.people_rounded, const GeneralAnalysisPage(title: 'Sosyal Medya', hintText: 'Mesajı yapıştırın...')),
              _buildModernCard(context, 'Arama Takip', Icons.call_rounded, const GeneralAnalysisPage(title: 'Arama Analizi', hintText: 'Numara veya görüşme detaylarını yazın...')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernCard(BuildContext context, String title, IconData icon, Widget target) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => target)),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.purpleAccent, size: 30),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
