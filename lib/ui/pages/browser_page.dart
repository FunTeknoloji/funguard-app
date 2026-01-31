import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';
import '../../app_state.dart';

class BrowserPage extends StatefulWidget {
  const BrowserPage({super.key});

  @override
  State<BrowserPage> createState() => _BrowserPageState();
}

class _BrowserPageState extends State<BrowserPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String _currentUrl = 'https://www.google.com';
  final TextEditingController _urlController = TextEditingController(text: 'https://www.google.com');

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _currentUrl = url;
              _urlController.text = url;
            });
            _checkUrl(url);
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(_currentUrl));
  }

  void _checkUrl(String url) async {
    final appState = context.read<AppState>();

    // USOM Check
    if (appState.usomService.isUrlMalicious(url)) {
      appState.triggerManualWarning(
        "ZARARLI SİTE ENGELLEME!",
        "Girmeye çalıştığınız site ($url) güvenlik veritabanımızda kara listededir. Lütfen derhal uzaklaşın!"
      );
      return;
    }

    // AI Analysis for suspicious looking URLs
    if (url.contains("login") || url.contains("verify") || url.contains("update") || url.contains("account")) {
      final result = await appState.aiService.analyzeText("Girilmeye çalışılan web adresi: $url");
      if (result.toLowerCase().contains("tehlikeli") || result.toLowerCase().contains("şüpheli")) {
        appState.triggerManualWarning(
          "ŞÜPHELİ SİTE TESPİTİ!",
          "Yapay zeka bu siteyi şüpheli olarak işaretledi: $url\n\nAnaliz: $result"
        );
      }
    }
  }

  void _loadUrl() {
    String url = _urlController.text.trim();
    if (!url.startsWith('http')) {
      url = 'https://$url';
    }
    _controller.loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: TextField(
          controller: _urlController,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: const InputDecoration(
            hintText: 'URL girin...',
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
          ),
          onSubmitted: (_) => _loadUrl(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.purpleAccent),
            onPressed: _loadUrl,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isLoading)
            const LinearProgressIndicator(color: Colors.purpleAccent, backgroundColor: Colors.black),
          Expanded(
            child: WebViewWidget(controller: _controller),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey[900],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () async {
                if (await _controller.canGoBack()) {
                  await _controller.goBack();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () => _controller.reload(),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward, color: Colors.white),
              onPressed: () async {
                if (await _controller.canGoForward()) {
                  await _controller.goForward();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.shield, color: Colors.greenAccent),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('FunGuard Güvenli Tarayıcı Modu Aktif'))
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
