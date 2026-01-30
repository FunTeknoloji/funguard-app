import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_state.dart';

class LinkAnalysisPage extends StatefulWidget {
  const LinkAnalysisPage({super.key});

  @override
  State<LinkAnalysisPage> createState() => _LinkAnalysisPageState();
}

class _LinkAnalysisPageState extends State<LinkAnalysisPage> {
  final TextEditingController _controller = TextEditingController();
  String _usomResult = "";
  String _aiResult = "";
  bool _isLoading = false;

  void _analyze() async {
    if (_controller.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _usomResult = "";
      _aiResult = "";
    });

    final appState = context.read<AppState>();
    final url = _controller.text.trim();

    // USOM Check
    final isMalicious = appState.usomService.isUrlMalicious(url);
    setState(() {
      _usomResult = isMalicious
          ? "⚠️ TEHLİKELİ: Bu URL USOM kara listesinde bulunuyor!"
          : "✅ USOM listesinde bulunamadı.";
    });

    // AI Check
    final response = await appState.aiService.analyzeText("Bu linki incele: $url");
    setState(() {
      _aiResult = response;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Link Tarama')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'URL giriniz (örneğin: google.com)',
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _analyze,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[700],
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Detaylı Tarama Yap', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
            const SizedBox(height: 30),
            if (_usomResult.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: _usomResult.contains('TEHLİKELİ') ? Colors.red[900]?.withOpacity(0.3) : Colors.green[900]?.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: _usomResult.contains('TEHLİKELİ') ? Colors.red : Colors.green),
                ),
                child: Text(_usomResult, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            if (_aiResult.isNotEmpty)
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.purpleAccent.withOpacity(0.5)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Yapay Zeka Analizi:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purpleAccent)),
                        const Divider(),
                        Text(_aiResult),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
