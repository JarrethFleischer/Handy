import 'package:audioplayers/audioplayers.dart';

final AudioPlayer _soundPlayer = AudioPlayer();

Future<void> _playSound(String fileName) async {
  await _soundPlayer.stop();
  await _soundPlayer.play(AssetSource('sounds/$fileName'));
}

Future<void> playCorrectSound() => _playSound('correct.mp3');

Future<void> playIncorrectSound() => _playSound('incorrect.mp3');

Future<void> playWinSound() => _playSound('win.mp3');

Future<void> playLoseSound() => _playSound('lose.mp3');
