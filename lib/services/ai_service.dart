import 'package:http/http.dart' as http;

class AIService {
  final String _baseUrl = 'https://text.pollinations.ai/';

  Future<String> analyzeText(String text) async {
    final prompt = "Sen FunGuard AI güvenlik asistanısın. Aşağıdaki içeriği dolandırıcılık, phishing veya zararlı niyet açısından analiz et. "
        "Sonucu profesyonel bir dille Türkçe olarak açıkla. Güvenlik durumunu (GÜVENLİ, ŞÜPHELİ, TEHLİKELİ) en başta belirt. "
        "İçerik: $text";

    final encodedPrompt = Uri.encodeComponent(prompt);
    final url = Uri.parse('$_baseUrl$encodedPrompt');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return response.body;
      } else {
        return "Hata: AI servisine ulaşılamadı (${response.statusCode})";
      }
    } catch (e) {
      return "Hata: $e";
    }
  }
}
