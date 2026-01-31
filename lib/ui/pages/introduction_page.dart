import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_state.dart';

class IntroductionPage extends StatefulWidget {
  const IntroductionPage({super.key});

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            children: [
              _buildPage(
                title: "Hoş Geldiniz",
                description: "FunGuard ile dijital dünyada güvendesiniz. Yapay zeka destekli koruma sistemimiz sizi dolandırıcılardan korur.",
                icon: Icons.shield_outlined,
              ),
              _buildPage(
                title: "Otomatik Tarama",
                description: "Gelen mesajları, linkleri ve aramaları anında analiz ederiz. Şüpheli bir durum tespit ettiğimizde sizi uyarırız.",
                icon: Icons.security_outlined,
              ),
              _buildPermissionPage(appState),
            ],
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) => _buildIndicator(index)),
                ),
                const SizedBox(height: 30),
                if (_currentPage < 2)
                  ElevatedButton(
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[700],
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text("İLERLE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage({required String title, required String description, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 120, color: Colors.purpleAccent),
          const SizedBox(height: 40),
          Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 20),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionPage(AppState appState) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_person_outlined, size: 80, color: Colors.purpleAccent),
          const SizedBox(height: 30),
          const Text("Gerekli İzinler", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 15),
          const Text(
            "FunGuard'ın sizi koruyabilmesi için aşağıdaki izinlere ihtiyacı vardır:",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 40),
          _buildPermissionTile(
            title: "Bildirim Erişimi",
            subtitle: "Mesajları analiz etmek için gereklidir.",
            onTap: () => appState.openNotificationSettings(),
          ),
          const SizedBox(height: 15),
          _buildPermissionTile(
            title: "Üstte Görüntüleme",
            subtitle: "Tehlike anında uyarı pop-up'ı göstermek için gereklidir.",
            onTap: () => appState.requestOverlayPermission(),
          ),
          const SizedBox(height: 50),
          ElevatedButton(
            onPressed: () async {
               // In a real app we'd verify permissions here, but for now we proceed
               await appState.finishOnboarding();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[700],
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text("BAŞLAT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionTile({required String title, required String subtitle, required VoidCallback onTap}) {
    return ListTile(
      tileColor: Colors.purple.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      leading: const Icon(Icons.check_circle_outline, color: Colors.purpleAccent),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.white60)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white30),
      onTap: onTap,
    );
  }

  Widget _buildIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      height: 10,
      width: _currentPage == index ? 25 : 10,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.purpleAccent : Colors.grey[700],
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
