import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _autoScanKey = 'auto_scan_enabled';
  static const String _usomProtectionKey = 'usom_protection_enabled';
  static const String _onboardingKey = 'has_finished_onboarding';

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

  Future<bool> getHasFinishedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> setHasFinishedOnboarding(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, value);
  }
}
