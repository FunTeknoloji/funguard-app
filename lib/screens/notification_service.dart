import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telephony/telephony.dart';
import 'ai_service.dart';
import 'notification_service.dart';

class SmsService {
  static final Telephony telephony = Telephony.instance;

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final autoProtection = prefs.getBool('auto_protection') ?? false;

    if (autoProtection) {
      await telephony.requestPhoneAndSmsPermissions;
    }
  }

  static Future<void> startMonitoring() async {
    telephony.listenIncomingSms(
      onNewMessage: _onMessageReceived,
      listenInBackground: true,
    );
  }

  static Future<void> _onMessageReceived(SmsMessage message) async {
    final prefs = await SharedPreferences.getInstance();
    final autoProtection = prefs.getBool('auto_protection') ?? false;

    if (!autoProtection) return;

    final sender = message.address ?? 'Bilinmeyen';
    final body = message.body ?? '';

    if (body.isEmpty) return;

    // AI ile analiz et
    final result = await AIService.analyzeText(body);

    if (result['isThreat'] == true) {
      // Tehlikeli mesaj tespit edildi - bildirim gönder
      await NotificationService.showThreatNotification(
        sender: sender,
        message: body,
        threatLevel: result['threatLevel'] ?? 'high',
      );

      // Geçmişe kaydet
      await _saveToHistory(sender, body, result);
    }
  }

  static Future<void> _saveToHistory(
    String sender,
    String message,
    Map<String, dynamic> result,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('threat_history') ?? [];

    final entry = {
      'sender': sender,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
      'threatLevel': result['threatLevel'],
      'details': result['details'],
    };

    history.insert(0, entry.toString());
    
    // Son 100 kaydı tut
    if (history.length > 100) {
      history.removeRange(100, history.length);
    }

    await prefs.setStringList('threat_history', history);
  }

  static Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('threat_history') ?? [];

    return history.map((entry) {
      try {
        // String'i Map'e dönüştür (basitleştirilmiş)
        return {
          'sender': 'Kayıtlı Tehdit',
          'message': entry,
          'timestamp': DateTime.now().toIso8601String(),
        };
      } catch (e) {
        return {};
      }
    }).toList();
  }
}
