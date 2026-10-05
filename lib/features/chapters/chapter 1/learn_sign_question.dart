import 'package:flutter/material.dart';
import 'package:handy/theme/app_colors.dart';
import 'package:video_player/video_player.dart';

class LearnSignQuestion extends StatelessWidget {
  const LearnSignQuestion({
    required this.videoAsset,
    required this.sign,
    required this.onContinue,
    super.key,
  });

  final String videoAsset;
  final String sign;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
          child: Text(
            'Learn a new sign',
            style: TextStyle(
              fontFamily: 'Inter',
              color: AppColors.textDark,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 20),
          child: ClipRRect(
            child: LessonVideo(
              key: ValueKey(videoAsset),
              assetPath: videoAsset,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          height: 50,
          margin: const EdgeInsets.symmetric(horizontal: 20.0),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.blueDark),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              sign,
              style: const TextStyle(
                fontFamily: 'Inter',
                color: AppColors.textDark,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const Spacer(),
        LessonButton(label: 'Continue', onPressed: onContinue),
      ],
    );
  }
}

class LessonButton extends StatelessWidget {
  const LessonButton({required this.label, required this.onPressed, super.key});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: SizedBox(
        height: 50,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.blueDark,
            disabledBackgroundColor: AppColors.blueDark.withValues(alpha: 0.4),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(fontFamily: 'Inter', fontSize: 16),
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

class LessonVideo extends StatefulWidget {
  const LessonVideo({required this.assetPath, this.height = 220, super.key});

  final String assetPath;
  final double height;

  @override
  State<LessonVideo> createState() => _LessonVideoState();
}

class _LessonVideoState extends State<LessonVideo> {
  late final VideoPlayerController _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.assetPath);
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      await _controller.initialize();
      await _controller.setLooping(true);
      await _controller.play();
      if (mounted) {
        setState(() {});
      }
    } catch (_) {
      if (mounted) {
        setState(() => _hasError = true);
      }
    }
  }

  void _togglePlayback() {
    if (!_controller.value.isInitialized) {
      return;
    }

    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _VideoState(
        height: widget.height,
        child: Icon(Icons.error_outline, color: Colors.redAccent),
      );
    }

    if (!_controller.value.isInitialized) {
      return _VideoState(
        height: widget.height,
        child: const CircularProgressIndicator(),
      );
    }

    final videoSize = _controller.value.size;

    return GestureDetector(
      onTap: _togglePlayback,
      child: SizedBox(
        width: double.infinity,
        height: widget.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            FittedBox(
              fit: BoxFit.fill,
              child: SizedBox(
                width: videoSize.width,
                height: videoSize.height,
                child: VideoPlayer(_controller),
              ),
            ),
            if (!_controller.value.isPlaying)
              const Center(
                child: Icon(
                  Icons.play_circle_fill,
                  color: Colors.white,
                  size: 56,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _VideoState extends StatelessWidget {
  const _VideoState({required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ColoredBox(
        color: Colors.black12,
        child: Center(child: child),
      ),
    );
  }
}
