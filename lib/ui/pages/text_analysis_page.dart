import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_state.dart';

class TextAnalysisPage extends StatefulWidget {
  const TextAnalysisPage({super.key});

  @override
  State<TextAnalysisPage> createState() => _TextAnalysisPageState();
}

class _TextAnalysisPageState extends State<TextAnalysisPage> {
  final TextEditingController _controller = TextEditingController();

  void _analyze() async {
    if (_controller.text.isEmpty) return;
    final appState = context.read<AppState>();
    await appState.analyzeText(_controller.text, context);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isLoading = appState.isAnalyzing;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Metin Analizi', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.purple.withOpacity(0.2)),
              ),
              child: TextField(
                controller: _controller,
                maxLines: 8,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Şüpheli metni buraya yapıştırın...',
                  hintStyle: TextStyle(color: Colors.grey),
                  contentPadding: EdgeInsets.all(20),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 25),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: const LinearGradient(colors: [Colors.purpleAccent, Colors.deepPurple]),
                boxShadow: [
                  BoxShadow(color: Colors.purpleAccent.withOpacity(0.3), blurRadius: 10, spreadRadius: 1),
                ],
              ),
              child: ElevatedButton(
                onPressed: isLoading ? null : _analyze,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Yapay Zeka ile Analiz Et', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
