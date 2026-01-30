import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vibration/vibration.dart';
import 'main.dart';
import 'services/ai_service.dart';
import 'services/usom_service.dart';
import 'services/storage_service.dart';

class AppState extends ChangeNotifier {
  final AIService aiService = AIService();
  final USOMService usomService = USOMService();
  final StorageService storageService = StorageService();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static const _channel = MethodChannel('com.funguard.app/notifications');

  bool _isAutoScanEnabled = true;
  bool _isUSOMProtectionEnabled = true;
  bool _isInitialized = false;

  bool get isAutoScanEnabled => _isAutoScanEnabled;
  bool get isUSOMProtectionEnabled => _isUSOMProtectionEnabled;
  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    _isAutoScanEnabled = await storageService.getAutoScanEnabled();
    _isUSOMProtectionEnabled = await storageService.getUSOMProtectionEnabled();
    await usomService.fetchUrlList();

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onNotificationReceived') {
        _handleIncomingNotification(call.arguments);
      }
    });

    _isInitialized = true;
    notifyListeners();
  }

  void _handleIncomingNotification(dynamic arguments) async {
    if (!_isAutoScanEnabled) return;

    final String? text = arguments['text'];
    if (text == null || text.isEmpty) return;

    // Check for URLs and USOM matching
    if (_isUSOMProtectionEnabled) {
      final urlRegex = RegExp(r'(https?:\/\/[^\s]+)');
      final matches = urlRegex.allMatches(text);
      for (final match in matches) {
        final url = match.group(0);
        if (url != null && usomService.isUrlMalicious(url)) {
          _showWarningNotification("TEHLİKELİ LİNK TESPİT EDİLDİ!", "Mesajdaki link USOM kara listesinde yer alıyor: $url");
          return; // Already found a threat
        }
      }
    }

    // Analyze text with AI
    final result = await aiService.analyzeText(text);

    // If AI thinks it's dangerous, we should show a notification or pop-up
    // For now, let's just log it. In a real app, we'd use flutter_local_notifications.
    print("Incoming Notification Analysis: $result");

    if (result.toLowerCase().contains("dangerous") || result.toLowerCase().contains("fraud") || result.toLowerCase().contains("tehlikeli")) {
       _showWarningNotification("Şüpheli Mesaj Tespit Edildi!", "Gelen mesaj dolandırıcılık belirtileri içeriyor olabilir. Lütfen dikkatli olun.");
    }
  }

  void _showWarningNotification(String title, String body) async {
    // Vibration
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(pattern: [500, 200, 500, 200, 500], intensities: [255, 255, 255, 255, 255]);
    }

    // Show Pop-up
    if (navigatorKey.currentState != null) {
      showDialog(
        context: navigatorKey.currentContext!,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.red[900],
          title: Row(
            children: [
              const Icon(Icons.warning, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text(title, style: const TextStyle(color: Colors.white))),
            ],
          ),
          content: Text(body, style: const TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('TAMAM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'funguard_alerts',
      'FunGuard Alerts',
      channelDescription: 'Notifications for fraud alerts',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, title, body, platformChannelSpecifics);
  }

  void setAutoScan(bool value) {
    _isAutoScanEnabled = value;
    storageService.setAutoScanEnabled(value);
    notifyListeners();
  }

  void setUSOMProtection(bool value) {
    _isUSOMProtectionEnabled = value;
    storageService.setUSOMProtectionEnabled(value);
    notifyListeners();
  }
}
