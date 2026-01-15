import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const FunGuardApp());
}

class FunGuardApp extends StatelessWidget {
  const FunGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FunGuard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F0F1E),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isScanning = false;
  bool _autoProtection = false;

  Future<void> _scanText() async {
    if (_textController.text.isEmpty) {
      _showSnackBar('Lütfen analiz edilecek metni girin');
      return;
    }

    setState(() => _isScanning = true);

    try {
      final result = await _analyzeWithAI(_textController.text);
      
      if (mounted) {
        await _showThreatDialog(
          result['isThreat'] ?? false,
          result['message'] ?? '',
          result['details'] ?? [],
        );
      }
    } catch (e) {
      _showSnackBar('Analiz sırasında hata oluştu');
    } finally {
      setState(() => _isScanning = false);
    }
  }

  Future<Map<String, dynamic>> _analyzeWithAI(String text) async {
    try {
      final prompt = '''
Bu metni analiz et ve tehlikeli olup olmadığını belirle. 
Metin: "$text"

SADECE şu formatta JSON yanıtı ver:
{
  "isThreat": true/false,
  "message": "kısa açıklama",
  "details": ["detay1", "detay2"]
}
''';

      final encodedPrompt = Uri.encodeComponent(prompt);
      final url = Uri.parse('https://text.pollinations.ai/$encodedPrompt');

      final response = await http.get(url).timeout(
        const Duration(seconds: 15),
      );

      if (response.statusCode == 200) {
        try {
          String cleanResponse = response.body.trim();
          
          int jsonStart = cleanResponse.indexOf('{');
          int jsonEnd = cleanResponse.lastIndexOf('}');
          
          if (jsonStart != -1 && jsonEnd != -1) {
            cleanResponse = cleanResponse.substring(jsonStart, jsonEnd + 1);
          }

          final result = json.decode(cleanResponse);
          return {
            'isThreat': result['isThreat'] ?? false,
            'message': result['message'] ?? 'Analiz tamamlandı',
            'details': result['details'] ?? [],
          };
        } catch (e) {
          return _fallbackAnalysis(text);
        }
      } else {
        return _fallbackAnalysis(text);
      }
    } catch (e) {
      return _fallbackAnalysis(text);
    }
  }

  Map<String, dynamic> _fallbackAnalysis(String text) {
    final lowerText = text.toLowerCase();
    bool isThreat = false;
    List<String> threats = [];

    final dangerousKeywords = [
      'şifre', 'kredi kartı', 'cvv', 'hesap numarası', 'tc kimlik',
      'doğrulama kodu', 'otp', 'acil', 'hesabınız kapatılacak',
      'kazandınız', 'tıklayın', 'hemen', 'son gün', 'ücretsiz',
    ];

    if (text.contains('http') || text.contains('www.')) {
      isThreat = true;
      threats.add('Şüpheli link tespit edildi');
    }

    for (final keyword in dangerousKeywords) {
      if (lowerText.contains(keyword)) {
        isThreat = true;
        threats.add('Şüpheli ifade: "$keyword"');
      }
    }

    return {
      'isThreat': isThreat,
      'message': isThreat
          ? 'Bu mesaj tehlikeli olabilir!'
          : 'Bu mesaj güvenli görünüyor',
      'details': threats.isEmpty
          ? ['Herhangi bir tehdit tespit edilmedi']
          : threats,
    };
  }

  Future<void> _showThreatDialog(bool isThreat, String message, List<dynamic> details) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF1A1A2E),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isThreat
                    ? Colors.red.withOpacity(0.2)
                    : Colors.green.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isThreat ? Icons.warning : Icons.check_circle,
                color: isThreat ? Colors.red : Colors.green,
                size: 32,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isThreat ? 'Tehlike Tespit Edildi!' : 'Güvenli',
                style: TextStyle(
                  color: isThreat ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                style: const TextStyle(color: Colors.white70),
              ),
              if (details.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Detaylar:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                ...details.map((detail) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(color: Colors.white70)),
                          Expanded(
                            child: Text(
                              detail.toString(),
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF6366F1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FunGuard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _autoProtection
                      ? [const Color(0xFF6366F1), const Color(0xFF8B5CF6)]
                      : [const Color(0xFF374151), const Color(0xFF1F2937)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _autoProtection ? 'Koruma Aktif' : 'Koruma Kapalı',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _autoProtection
                              ? 'SMS ve linkler taranıyor'
                              : 'Otomatik korumayı aktif edin',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _autoProtection,
                    onChanged: (value) => setState(() => _autoProtection = value),
                    activeColor: Colors.white,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.document_scanner, color: Color(0xFF6366F1)),
                      SizedBox(width: 12),
                      Text(
                        'Metin Tarama',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _textController,
                    maxLines: 5,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Analiz edilecek metni buraya yazın...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                      filled: true,
                      fillColor: const Color(0xFF0F0F1E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isScanning ? null : _scanText,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isScanning
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.shield_outlined),
                                SizedBox(width: 8),
                                Text(
                                  'Analiz Et',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
