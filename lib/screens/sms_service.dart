import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SmsService {
  static Future<void> initialize() async {
    debugPrint('SMS Service initialized');
  }

  static Future<void> startMonitoring() async {
    debugPrint('SMS monitoring placeholder');
  }

  static Future<void> _saveToHistory(
    String sender,
    String message,
    Map<String, dynamic> result,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('threat_history') ?? [];

    final timestamp = DateTime.now().toIso8601String();
    final entry = '$sender|$message|$timestamp|${result['threatLevel']}';

    history.insert(0, entry);
    
    if (history.length > 100) {
      history.removeRange(100, history.length);
    }

    await prefs.setStringList('threat_history', history);
  }

  static Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('threat_history') ?? [];

    return history.map((entry) {
      final parts = entry.split('|');
      return {
        'sender': parts.isNotEmpty ? parts[0] : 'Bilinmeyen',
        'message': parts.length > 1 ? parts[1] : entry,
        'timestamp': parts.length > 2 ? parts[2] : DateTime.now().toIso8601String(),
      };
    }).toList();
  }
}
