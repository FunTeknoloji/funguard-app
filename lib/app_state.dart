import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart' as fow;
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
  bool _isAnalyzing = false;
  bool _hasFinishedOnboarding = false;

  bool get isAutoScanEnabled => _isAutoScanEnabled;
  bool get isUSOMProtectionEnabled => _isUSOMProtectionEnabled;
  bool get isInitialized => _isInitialized;
  bool get isAnalyzing => _isAnalyzing;
  bool get hasFinishedOnboarding => _hasFinishedOnboarding;

  Future<void> init() async {
    _isAutoScanEnabled = await storageService.getAutoScanEnabled();
    _isUSOMProtectionEnabled = await storageService.getUSOMProtectionEnabled();
    _hasFinishedOnboarding = await storageService.getHasFinishedOnboarding();
    await usomService.fetchUrlList();

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );

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
    final String? packageName = arguments['package'];

    if (text == null || text.isEmpty) return;

    String sourceName = "Bilinmeyen";
    if (packageName != null) {
      if (packageName.contains("whatsapp")) sourceName = "WhatsApp";
      else if (packageName.contains("telegram")) sourceName = "Telegram";
      else if (packageName.contains("messaging") || packageName.contains("mms")) sourceName = "SMS";
      else if (packageName.contains("chrome") || packageName.contains("browser") || packageName.contains("firefox")) sourceName = "Tarayıcı";
      else if (packageName.contains("phone") || packageName.contains("dialer")) sourceName = "Arama";
    }

    // Check for URLs and USOM matching
    if (_isUSOMProtectionEnabled) {
      final urlRegex = RegExp(r'(https?:\/\/[^\s]+)');
      final matches = urlRegex.allMatches(text);
      for (final match in matches) {
        final url = match.group(0);
        if (url != null && usomService.isUrlMalicious(url)) {
          _showWarningNotification("TEHLİKELİ LİNK TESPİT EDİLDİ!", "$sourceName üzerinden gelen link USOM kara listesinde yer alıyor: $url");
          return; // Already found a threat
        }
      }
    }

    // Analyze text with AI
    final result = await aiService.analyzeText(text);

    // If AI thinks it's dangerous, we should show a notification or pop-up
    if (result.toLowerCase().contains("dangerous") || result.toLowerCase().contains("fraud") || result.toLowerCase().contains("tehlikeli") || result.toLowerCase().contains("şüpheli")) {
       _showWarningNotification("Şüpheli $sourceName İçeriği!", "Tespit edilen içerik dolandırıcılık veya zararlı niyet belirtileri içeriyor olabilir. Lütfen dikkatli olun.");
    }
  }

  void _showWarningNotification(String title, String body) async {
    // Vibration
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(pattern: [500, 200, 500, 200, 500], intensities: [255, 255, 255, 255, 255]);
    }

    // Show Overlay if possible
    final bool isOverlayActive = await fow.FlutterOverlayWindow.isActive();
    if (!isOverlayActive) {
      await fow.FlutterOverlayWindow.showOverlay(
        enableDrag: true,
        overlayTitle: "FunGuard Tehlike Uyarısı",
        overlayContent: body,
        flag: fow.OverlayFlag.focusThrough,
        alignment: fow.OverlayAlignment.center,
        visibility: fow.NotificationVisibility.visibilityPublic,
        positionGravity: fow.PositionGravity.auto,
      );
    }

    // Also show Dialog if app is in foreground
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
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
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

  Future<void> openNotificationSettings() async {
    await _channel.invokeMethod('openNotificationSettings');
  }

  Future<void> requestOverlayPermission() async {
    await _channel.invokeMethod('requestOverlayPermission');
  }

  Future<void> finishOnboarding() async {
    _hasFinishedOnboarding = true;
    await storageService.setHasFinishedOnboarding(true);
    notifyListeners();
  }

  Future<void> analyzeText(String text, BuildContext context) async {
    if (text.isEmpty) return;
    _isAnalyzing = true;
    notifyListeners();

    try {
      final result = await aiService.analyzeText(text);
      _isAnalyzing = false;
      notifyListeners();

      if (context.mounted) {
        showModalBottomSheet(
          context: context,
          backgroundColor: const Color(0xFF1E1E1E),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          builder: (context) => Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Analiz Sonucu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purpleAccent)),
                  const SizedBox(height: 15),
                  Text(result, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[700]),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Anladım', style: TextStyle(color: Colors.white)),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      }
    } catch (e) {
      _isAnalyzing = false;
      notifyListeners();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    }
  }
}
