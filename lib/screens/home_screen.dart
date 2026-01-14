import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ai_service.dart';
import '../widgets/scan_card.dart';
import '../widgets/protection_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isScanning = false;
  bool _autoProtection = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoProtection = prefs.getBool('auto_protection') ?? false;
    });
  }

  Future<void> _scanText() async {
    if (_textController.text.isEmpty) {
      _showSnackBar('Lütfen analiz edilecek metni girin');
      return;
    }

    setState(() => _isScanning = true);

    try {
      final result = await AIService.analyzeText(_textController.text);
      
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
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProtectionCard(
              autoProtection: _autoProtection,
              onChanged: (value) async {
                setState(() => _autoProtection = value);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('auto_protection', value);
              },
            ),
            const SizedBox(height: 24),
            ScanCard(
              controller: _textController,
              isScanning: _isScanning,
              onScan: _scanText,
            ),
            const SizedBox(height: 24),
            _buildQuickStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Günlük Koruma',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(icon: Icons.shield, label: 'Korunan', value: '0'),
              _StatItem(icon: Icons.warning, label: 'Engellenen', value: '0'),
              _StatItem(icon: Icons.check, label: 'Güvenli', value: '0'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF6366F1)),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }
}
