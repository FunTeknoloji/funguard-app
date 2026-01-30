import 'package:http/http.dart' as http;
import 'dart:convert';

class USOMService {
  final String _usomUrl = 'https://www.usom.gov.tr/url-list.txt';
  Set<String> _maliciousUrls = {};
  bool _isLoaded = false;

  Future<void> fetchUrlList() async {
    try {
      final response = await http.get(Uri.parse(_usomUrl));
      if (response.statusCode == 200) {
        final lines = LineSplitter.split(response.body);
        _maliciousUrls = lines.map((line) => line.trim().toLowerCase()).toSet();
        _isLoaded = true;
      }
    } catch (e) {
      print("USOM fetch error: $e");
    }
  }

  bool isUrlMalicious(String url) {
    if (!_isLoaded) return false;
    String cleanUrl = url.trim().toLowerCase();
    // Basic cleaning to match USOM format (which is usually just the domain)
    cleanUrl = cleanUrl.replaceAll('http://', '').replaceAll('https://', '');
    if (cleanUrl.contains('/')) {
      cleanUrl = cleanUrl.split('/').first;
    }
    return _maliciousUrls.contains(cleanUrl);
  }

  bool get isLoaded => _isLoaded;
}
