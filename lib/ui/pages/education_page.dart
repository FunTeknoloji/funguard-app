import 'package:flutter/material.dart';

class EducationPage extends StatelessWidget {
  const EducationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eğitim Merkezi', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 20),
            _buildCategories(),
            const SizedBox(height: 25),
            _buildFeaturedArticle(),
            const SizedBox(height: 25),
            const Text('Popüler Makaleler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _buildArticleItem(
              icon: Icons.phishing,
              iconColor: Colors.blue,
              title: 'Phishing Nedir?',
              subtitle: 'Sahte e-postaları ve linkleri na...',
              tag: 'Güvenlik',
              readTime: '3 dk okuma',
            ),
            _buildArticleItem(
              icon: Icons.phone_android,
              iconColor: Colors.orange,
              title: 'Telefon Dolandırıcılığı',
              subtitle: 'Kendinizi şüpheli sesli aramala...',
              tag: 'Mobil',
              readTime: '5 dk okuma',
            ),
            _buildArticleItem(
              icon: Icons.lock_outline,
              iconColor: Colors.green,
              title: 'Verilerinizi Koruyun',
              subtitle: 'Güçlü şifreler ve 2FA kullanımı...',
              tag: 'Gizlilik',
              readTime: '4 dk okuma',
            ),
            _buildArticleItem(
              icon: Icons.credit_card,
              iconColor: Colors.purple,
              title: 'Kart Güvenliği',
              subtitle: 'Online alışverişlerde kredi kartı...',
              tag: 'Finans',
              readTime: '6 dk okuma',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(15),
      ),
      child: const TextField(
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: Colors.grey),
          hintText: 'Konu ara...',
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildCategoryChip('Tümü', isSelected: true),
          _buildCategoryChip('Kimlik Avı'),
          _buildCategoryChip('Telefon'),
          _buildCategoryChip('Veri Güvenliği'),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue : Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey)),
    );
  }

  Widget _buildFeaturedArticle() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withOpacity(0.8), Colors.transparent],
        ),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1550751827-4bd374c3f58b?auto=format&fit=crop&w=800&q=80'),
          fit: BoxFit.cover,
          opacity: 0.6,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(5)),
              child: const Text('HAFTANIN KONUSU', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 5),
            const Text('Sosyal Mühendislik', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const Text('İnsanları manipüle ederek gizli bilgileri ele geçirme yöntemleri ve korunma yolları.',
              style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String tag,
    required String readTime
  }) {
    return Builder(
      builder: (context) {
        return InkWell(
          onTap: () => _showArticleDetail(context, title, subtitle, icon, iconColor),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(icon, color: iconColor),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: iconColor.withOpacity(0.2), borderRadius: BorderRadius.circular(5)),
                            child: Text(tag, style: TextStyle(color: iconColor, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 10),
                          Text('• $readTime', style: const TextStyle(color: Colors.grey, fontSize: 10)),
                        ],
                      )
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        );
      }
    );
  }

  void _showArticleDetail(BuildContext context, String title, String subtitle, IconData icon, Color color) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Icon(icon, color: color, size: 40),
                  const SizedBox(width: 15),
                  Expanded(child: Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
                ],
              ),
              const SizedBox(height: 20),
              Text(subtitle, style: const TextStyle(fontSize: 18, color: Colors.purpleAccent, fontWeight: FontWeight.w500)),
              const SizedBox(height: 20),
              const Text(
                "Detaylı Bilgilendirme:\n\n"
                "Dolandırıcılık yöntemleri her geçen gün gelişmektedir. FunGuard olarak size en güncel korumayı sağlamaya çalışıyoruz. "
                "Bu tür saldırılardan korunmak için asla şüpheli linklere tıklamayın ve kişisel bilgilerinizi paylaşmayın.\n\n"
                "1. Kaynağı Doğrulayın: Gelen mesajın veya e-postanın gerçekten iddia edilen kurumdan gelip gelmediğini kontrol edin.\n\n"
                "2. Acele Etmeyin: Dolandırıcılar genellikle sizi panikletmeye ve hızlı karar vermeye zorlar. Sakin kalın.\n\n"
                "3. İki Faktörlü Doğrulama: Tüm hesaplarınızda 2FA özelliğini aktif hale getirin.\n\n"
                "Unutmayın, hiçbir banka veya resmi kurum sizden şifrenizi SMS veya e-posta yoluyla istemez.",
                style: TextStyle(fontSize: 16, height: 1.6, color: Colors.white70),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[700],
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text('Anladım, Teşekkürler', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
