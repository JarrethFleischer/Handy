import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

final AudioPlayer _soundPlayer = AudioPlayer();

Future<void> _playSound(String fileName) async {
  await _soundPlayer.stop();
  await _soundPlayer.play(AssetSource('sounds/$fileName'));
}

Future<void> playCorrectSound() => _playSound('correct.mp3');

Future<void> playIncorrectSound() => _playSound('incorrect.mp3');

Future<void> playClickSound() => _playSound('click.mp3');

class ClickSoundLayer extends StatelessWidget {
  const ClickSoundLayer({required this.child, super.key});

  final Widget child;

  void _handlePointerDown(PointerDownEvent event) {
    final result = HitTestResult();
    WidgetsBinding.instance.hitTestInView(result, event.position, event.viewId);
    for (final entry in result.path) {
      final target = entry.target;
      final isTappable =
          target is RenderSemanticsAnnotations &&
              target.properties.onTap != null ||
          target is RenderSemanticsGestureHandler && target.onTap != null;
      if (isTappable) {
        playClickSound();
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _handlePointerDown,
      child: child,
    );
  }
}
