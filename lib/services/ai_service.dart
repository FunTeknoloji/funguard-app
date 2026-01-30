import 'package:http/http.dart' as http;

class AIService {
  final String _baseUrl = 'https://text.pollinations.ai/';

  Future<String> analyzeText(String text) async {
    final prompt = "Analyze the following content for fraud, scams, or malicious intent. "
        "Return ONLY a short explanation in Turkish and a safety assessment. "
        "Content: $text";

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
