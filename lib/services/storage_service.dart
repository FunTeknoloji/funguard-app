import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _autoScanKey = 'auto_scan_enabled';
  static const String _usomProtectionKey = 'usom_protection_enabled';

  Future<bool> getAutoScanEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoScanKey) ?? true;
  }

  Future<void> setAutoScanEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoScanKey, value);
  }

  Future<bool> getUSOMProtectionEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_usomProtectionKey) ?? true;
  }

  Future<void> setUSOMProtectionEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_usomProtectionKey, value);
  }
}
