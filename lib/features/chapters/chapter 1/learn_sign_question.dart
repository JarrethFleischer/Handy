import 'package:flutter/material.dart';
<<<<<<< Updated upstream
import 'package:handy/theme/app_colors.dart';
=======
import 'package:handy/features/chapters/chapter 1/lesson_flow.dart';
>>>>>>> Stashed changes
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
          padding: EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
          child: Text(
            'Learn a new sign',
            style: TextStyle(
              fontFamily: 'Inter',
              color: Color(0xFF14181B),
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
        ),
        Padding(
<<<<<<< Updated upstream
          padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 20),
          child: ClipRRect(
            child: LessonVideo(
              key: ValueKey(videoAsset),
              assetPath: videoAsset,
=======
          padding: const EdgeInsetsDirectional.fromSTEB(20, 14, 20, 18),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF14181B), width: 2.0),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF14181B),
                  offset: Offset(0, 5),
                  blurRadius: 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: LessonVideo(
                key: ValueKey(videoUrl ?? videoAsset),
                assetPath: videoAsset,
                videoUrl: videoUrl,
              ),
>>>>>>> Stashed changes
            ),
          ),
        ),
        // FIXED: Flat info box (No chunky bottom shadow, clean flat border)
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 54),
          margin: const EdgeInsets.symmetric(horizontal: 20.0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFF14181B), width: 1.6),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              sign,
              style: const TextStyle(
                fontFamily: 'Inter',
                color: Color(0xFF14181B),
                fontSize: 18,
                fontWeight: FontWeight.w900,
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
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 16 + bottomInset),
      child: SizedBox(
        height: 52,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF14181B),
            disabledBackgroundColor: const Color(0xFFCBD5E1),
            foregroundColor: Colors.white,
            disabledForegroundColor: const Color(0xFF64748B),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: Color(0xFF14181B), width: 1.8),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

class LessonVideo extends StatefulWidget {
<<<<<<< Updated upstream
  const LessonVideo({required this.assetPath, this.height = 220, super.key});
=======
  const LessonVideo({
    this.assetPath,
    this.videoUrl,
    this.height = 210,
    super.key,
  });
>>>>>>> Stashed changes

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
        child: const Icon(Icons.error_outline, color: Colors.redAccent),
      );
    }

    if (!_controller.value.isInitialized) {
      return _VideoState(
        height: widget.height,
        child: const CircularProgressIndicator(color: Color(0xFF22A2F2)),
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
                  Icons.play_circle_fill_rounded,
                  color: Colors.white,
                  size: 60,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
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
        color: const Color(0xFFE2E8F0),
        child: Center(child: child),
      ),
    );
  }
}
