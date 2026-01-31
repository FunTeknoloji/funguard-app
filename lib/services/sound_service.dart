import 'package:audioplayers/audioplayers.dart';

class SoundService {
  final AudioPlayer _player = AudioPlayer();

  // For a real app, these would be in assets
  // For now we use some publicly available UI sounds for demonstration
  static const String scanSound = 'https://assets.mixkit.co/active_storage/sfx/2568/2568-preview.mp3';
  static const String dangerSound = 'https://assets.mixkit.co/active_storage/sfx/951/951-preview.mp3';
  static const String safeSound = 'https://assets.mixkit.co/active_storage/sfx/2013/2013-preview.mp3';

  Future<void> playScan() async {
    await _player.play(UrlSource(scanSound));
  }

  Future<void> playDanger() async {
    await _player.play(UrlSource(dangerSound));
  }

  Future<void> playSafe() async {
    await _player.play(UrlSource(safeSound));
  }
}
