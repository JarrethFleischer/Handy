import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:handy/features/camera/view/camera_view.dart';

/// Opens the live camera quiz behind a "Preparing your quiz" screen.
///
/// The loader appears instantly, then [CameraView] is built underneath it.
/// When CameraView reports ready via `onReady`, the progress bar fills and
/// the loader fades out to reveal the camera.
///
/// [CameraView] pops its own route with `true` when passed, so the result of
/// pushing this route is the same as pushing [CameraView] directly.
class QuizLoaderView extends StatefulWidget {
  const QuizLoaderView({
    super.key,
    required this.expectedSign,
    required this.xpReward,
  });

  final String expectedSign;
  final int xpReward;

  static Future<bool?> open(
    BuildContext context, {
    required String expectedSign,
    required int xpReward,
  }) {
    return Navigator.push<bool>(
      context,
      PageRouteBuilder<bool>(
        // Instant: the loader must be fully on screen before the camera
        // starts its heavy setup, so the freeze happens behind it.
        transitionDuration: Duration.zero,
        reverseTransitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (_, _, _) =>
            QuizLoaderView(expectedSign: expectedSign, xpReward: xpReward),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  State<QuizLoaderView> createState() => _QuizLoaderViewState();
}

class _QuizLoaderViewState extends State<QuizLoaderView> {
  static const _yellow = Color(0xFFFFD86B);
  static const _sky = Color(0xFF22A2F2);
  static const _ink = Color(0xFF14181B);

  final Completer<void> _cameraReady = Completer<void>();
  Timer? _progressTimer;
  double _progress = 0.05;
  String _status = 'Starting the camera...';
  bool _showCamera = false;
  bool _overlayVisible = true;
  bool _overlayRemoved = false;

  @override
  void initState() {
    super.initState();
    _progressTimer = Timer.periodic(
      const Duration(milliseconds: 80),
      (_) => _tickProgress(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _prepare());
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }

  /// Creeps toward 90% while waiting; a freeze just looks like a bigger jump.
  void _tickProgress() {
    if (!mounted || _cameraReady.isCompleted) return;
    setState(() {
      _progress += (0.9 - _progress) * 0.06;
      if (_progress > 0.35 && _status == 'Starting the camera...') {
        _status = 'Loading hand tracking...';
      } else if (_progress > 0.7 && _status == 'Loading hand tracking...') {
        _status = 'Almost ready...';
      }
    });
  }

  Future<void> _prepare() async {
    // Make sure the loader frame is actually painted on screen first.
    await WidgetsBinding.instance.endOfFrame;
    await Future<void>.delayed(const Duration(milliseconds: 60));
    if (!mounted) return;
    setState(() => _showCamera = true);

    // Wait for CameraView to report ready (safety cap in case it never does).
    await _cameraReady.future.timeout(
      const Duration(seconds: 8),
      onTimeout: () {},
    );
    _progressTimer?.cancel();
    if (!mounted) return;

    setState(() {
      _progress = 1.0;
      _status = 'Starting your quiz...';
    });
    // Let the bar finish filling and the first preview frames paint.
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    setState(() => _overlayVisible = false);
  }

  void _onCameraReady() {
    if (!_cameraReady.isCompleted) _cameraReady.complete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _yellow,
      body: Stack(
        children: [
          if (_showCamera)
            Positioned.fill(
              child: CameraView(
                purpose: CameraPurpose.liveTest,
                expectedSign: widget.expectedSign,
                xpReward: widget.xpReward,
                onReady: _onCameraReady,
              ),
            ),
          if (!_overlayRemoved)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: !_overlayVisible,
                child: AnimatedOpacity(
                  opacity: _overlayVisible ? 1 : 0,
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOut,
                  onEnd: () {
                    if (!_overlayVisible && mounted) {
                      setState(() => _overlayRemoved = true);
                    }
                  },
                  child: _buildLoader(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoader() {
    return ColoredBox(
      color: _yellow,
      child: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(Icons.close_rounded, color: _ink),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset('assets/images/logo2.svg'),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Preparing your quiz',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: _ink,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildProgressBar(),
                    const SizedBox(height: 16),
                    Text(
                      _status,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 22,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _ink, width: 3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Align(
          alignment: Alignment.centerLeft,
          child: AnimatedFractionallySizedBox(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            widthFactor: _progress.clamp(0.0, 1.0),
            heightFactor: 1,
            child: Container(
              decoration: BoxDecoration(
                color: _sky,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
