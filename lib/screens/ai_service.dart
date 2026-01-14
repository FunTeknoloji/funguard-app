import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String _baseUrl = 'https://text.pollinations.ai';

  static Future<Map<String, dynamic>> analyzeText(String text) async {
    try {
      final prompt = '''
Bu metni analiz et ve tehlikeli olup olmadığını belirle. 
Metin: "$text"

Aşağıdaki kriterlere göre değerlendir:
- Kimlik avı (phishing) girişimi var mı?
- Şüpheli linkler var mı?
- Dolandırıcılık ifadeleri var mı?
- Aciliyet yaratmaya çalışan ifadeler var mı?
- Kişisel bilgi talep eden ifadeler var mı?

SADECE şu formatta JSON yanıtı ver (başka bir şey yazma):
{
  "isThreat": true/false,
  "threatLevel": "high/medium/low/none",
  "message": "kısa açıklama",
  "details": ["detay1", "detay2", "detay3"]
}
''';

      final encodedPrompt = Uri.encodeComponent(prompt);
      final url = Uri.parse('$_baseUrl/$encodedPrompt');

      final response = await http.get(url).timeout(
        const Duration(seconds: 15),
      );

      if (response.statusCode == 200) {
        try {
          // AI yanıtını temizle
          String cleanResponse = response.body.trim();
          
          // JSON dışındaki metinleri kaldır
          int jsonStart = cleanResponse.indexOf('{');
          int jsonEnd = cleanResponse.lastIndexOf('}');
          
          if (jsonStart != -1 && jsonEnd != -1) {
            cleanResponse = cleanResponse.substring(jsonStart, jsonEnd + 1);
          }

          final result = json.decode(cleanResponse);
          return {
            'isThreat': result['isThreat'] ?? false,
            'threatLevel': result['threatLevel'] ?? 'none',
            'message': result['message'] ?? 'Analiz tamamlandı',
            'details': result['details'] ?? [],
          };
        } catch (e) {
          // JSON parse hatası durumunda basit analiz yap
          return _fallbackAnalysis(text);
        }
      } else {
        return _fallbackAnalysis(text);
      }
    } catch (e) {
      return _fallbackAnalysis(text);
    }
  }

  static Map<String, dynamic> _fallbackAnalysis(String text) {
    final lowerText = text.toLowerCase();
    bool isThreat = false;
    List<String> threats = [];

    // Tehlikeli kelimeler
    final dangerousKeywords = [
      'şifre', 'kredi kartı', 'cvv', 'hesap numarası', 'tc kimlik',
      'doğrulama kodu', 'otp', 'acil', 'hesabınız kapatılacak',
      'kazandınız', 'tıklayın', 'hemen', 'son gün', 'ücretsiz',
    ];

    // URL kontrolü
    if (text.contains('http') || text.contains('www.')) {
      isThreat = true;
      threats.add('Şüpheli link tespit edildi');
    }

    // Tehlikeli kelime kontrolü
    for (final keyword in dangerousKeywords) {
      if (lowerText.contains(keyword)) {
        isThreat = true;
        threats.add('Şüpheli ifade tespit edildi: "$keyword"');
      }
    }

    // Telefon numarası kontrolü
    if (RegExp(r'\+?[\d\s]{10,}').hasMatch(text)) {
      threats.add('Telefon numarası içeriyor');
    }

    return {
      'isThreat': isThreat,
      'threatLevel': isThreat ? 'high' : 'none',
      'message': isThreat
          ? 'Bu mesaj tehlikeli olabilir!'
          : 'Bu mesaj güvenli görünüyor',
      'details': threats.isEmpty
          ? ['Herhangi bir tehdit tespit edilmedi']
          : threats,
    };
  }
}
