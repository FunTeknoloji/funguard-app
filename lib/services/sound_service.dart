import 'package:audioplayers/audioplayers.dart';

class SoundService {
  final AudioPlayer _player = AudioPlayer();

  // For a real app, these would be in assets
  // For now we use some publicly available UI sounds for demonstration
  static const String scanSound = 'https://assets.mixkit.co/active_storage/sfx/2568/2568-preview.mp3';
  static const String dangerSound = 'https://cdn.pixabay.com/download/audio/2022/03/10/audio_f56360c733.mp3?filename=emergency-alarm-with-reverb-105151.mp3';
  static const String safeSound = 'https://cdn.pixabay.com/download/audio/2021/08/04/audio_06256f085a.mp3?filename=success-1-6297.mp3';

  Future<void> playScan() async {
    try {
      await _player.play(UrlSource(scanSound));
    } catch (e) {
      print("Error playing scan sound: $e");
    }
  }

  Future<void> playDanger() async {
    try {
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.play(UrlSource(dangerSound));
    } catch (e) {
      print("Error playing danger sound: $e");
    }
  }

  Future<void> playSafe() async {
    try {
      await _player.play(UrlSource(safeSound));
    } catch (e) {
      print("Error playing safe sound: $e");
    }
  }
}
