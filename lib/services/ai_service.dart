import 'package:http/http.dart' as http;

class AIService {
  final String _baseUrl = 'https://text.pollinations.ai/';

  Future<String> analyzeText(String text) async {
    final prompt = "Sen FunGuard Çok Gelişmiş AI Güvenlik Analizörüsün. "
        "Görevin: Aşağıdaki metni/linki derinlemesine incelemek ve siber güvenlik uzmanı gibi rapor sunmaktır. "
        "Kurallar: "
        "1. Yanıtın en başında büyük harflerle [DURUM: GÜVENLİ], [DURUM: ŞÜPHELİ] veya [DURUM: TEHLİKELİ] yaz. "
        "2. Neden bu karara vardığını maddeler halinde açıkla. "
        "3. Kullanıcıya net tavsiyeler ver. "
        "4. Yanıtın içinde '--' gibi anlamsız karakterler kullanma. "
        "5. Önemli kısımları **kalın** yaz. "
        "6. Profesyonel ve ciddi bir ton kullan. "
        "İçerik: $text";

    final encodedPrompt = Uri.encodeComponent(prompt);
    final url = Uri.parse('$_baseUrl$encodedPrompt');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        String cleanBody = response.body.replaceAll('--', '').trim();
        // Remove leading/trailing quotes if AI added them
        if (cleanBody.startsWith('"') && cleanBody.endsWith('"')) {
          cleanBody = cleanBody.substring(1, cleanBody.length - 1);
        }
        return cleanBody;
      } else {
        return "Hata: AI servisine ulaşılamadı (${response.statusCode})";
      }
    } catch (e) {
      return "Hata: $e";
    }
  }
}
