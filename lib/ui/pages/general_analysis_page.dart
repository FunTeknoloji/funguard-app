import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_state.dart';

class GeneralAnalysisPage extends StatefulWidget {
  final String title;
  final String hintText;
  const GeneralAnalysisPage({super.key, required this.title, required this.hintText});

  @override
  State<GeneralAnalysisPage> createState() => _GeneralAnalysisPageState();
}

class _GeneralAnalysisPageState extends State<GeneralAnalysisPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _controller,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  filled: true,
                  fillColor: Colors.grey[900],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[700],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: appState.isAnalyzing
                    ? null
                    : () => appState.analyzeText(_controller.text, context),
                child: appState.isAnalyzing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Yapay Zeka ile Analiz Et', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 30),
              _buildTips(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTips() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.amber),
              SizedBox(width: 10),
              Text('Güvenlik İpucu', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Dolandırıcılar genellikle aciliyet hissi yaratır. "Hemen tıklayın", "Hesabınız bloke edildi" gibi ifadelere dikkat edin.',
            style: TextStyle(color: Colors.grey[300], fontSize: 13),
          ),
        ],
      ),
    );
  }
}
