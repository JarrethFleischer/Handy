import 'dart:async';

import 'package:handy/features/camera/landmarks/coordinate_normalizer.dart';
import 'package:handy/features/camera/landmarks/gesture_sample_log.dart';
import 'package:handy/features/camera/landmarks/hand_sample_log.dart';
import 'package:handy/features/recognition/sign_classifier.dart';
import 'package:handy/features/camera/view/hand_landmark_painter.dart';
import 'package:handy/features/camera/view/landmark_values_panel.dart';
import 'package:handy/features/camera/view/sample_capture_bar.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hand_landmarker/hand_landmarker.dart';
import 'package:handy/features/widget/popup.dart';
import 'package:handy/theme/app_colors.dart';
import 'package:share_plus/share_plus.dart';

/// Live camera preview using the [camera] plugin.
///
/// Prefers the front camera (typical for sign-language capture) and
/// handles permissions, lifecycle pause/resume, and camera switching.
/// On Android, MediaPipe Hands overlays 21 landmarks via [hand_landmarker].
enum CameraPurpose { collectSamples, liveTest }

class CameraView extends StatefulWidget {
  const CameraView({
    super.key,
    this.purpose = CameraPurpose.collectSamples,
    this.expectedSign,
    this.xpReward = 100,
  });

  final CameraPurpose purpose;
  final String? expectedSign;
  final int xpReward;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver {
  CameraController? _controller;
  CameraDescription? _currentCamera;
  HandLandmarkerPlugin? _plugin;
  List<CameraDescription> _cameras = const [];
  String? _errorMessage;
  bool _isInitializing = true;
  bool _isSwitching = false;
  bool _isRecording = false;
  final _labelController = TextEditingController(text: 'A');
  final _hands = ValueNotifier<List<Hand>>(const []);
  StreamSubscription<List<Hand>>? _landmarkSub;
  HandSampleLog? _log;
  GestureSampleLog? _gestureLog;
  List<Hand> _latestHands = const [];
  final List<List<double>> _frameBuffer = [];
  int _gestureSession = 0;
  SignClassifier? _classifier;
  String? _predictedLabel;
  double _predictedConfidence = 0;
  String? _motionLabel;
  double _motionConfidence = 0;
  String? _pendingLabel;
  int _pendingCount = 0;
  String? _pendingMotionLabel;
  int _pendingMotionCount = 0;
  DateTime? _lastInference;
  final List<List<double>> _motionWindow = [];
  bool _practicePassed = false;
  bool _practiceStarted = false;
  bool _matchedDuringPractice = false;
  int _countdownRemaining = 5;
  Timer? _countdownTimer;
  static const _practiceSeconds = 5;

  bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.purpose == CameraPurpose.liveTest) {
      _loadClassifier();
    } else {
      _openLog();
    }
    _startCamera();
  }

  @override
  void dispose() {
    _gestureSession += 1;
    _countdownTimer?.cancel();
    _landmarkSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _disposeCamera();
    _plugin?.dispose();
    _plugin = null;
    _classifier?.close();
    _hands.dispose();
    _labelController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    final camera = _currentCamera;
    if (controller == null ||
        !controller.value.isInitialized ||
        camera == null) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _disposeCamera();
    } else if (state == AppLifecycleState.resumed) {
      _initializeController(camera);
    }
  }

  Future<void> _startCamera() async {
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      final cameras = await availableCameras();
      if (!mounted) {
        return;
      }

      if (cameras.isEmpty) {
        setState(() {
          _cameras = const [];
          _isInitializing = false;
          _errorMessage = 'No cameras were found on this device.';
        });
        return;
      }

      _cameras = cameras;
      _ensurePlugin();
      final frontCameras = cameras.where(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );
      await _initializeController(
        frontCameras.isNotEmpty ? frontCameras.first : cameras.first,
      );
    } on CameraException catch (error) {
      _showError(_messageForCameraException(error));
    } catch (error) {
      _showError('Failed to start the camera.\n$error');
    }
  }

  void _ensurePlugin() {
    if (!_isAndroid || _plugin != null) {
      return;
    }
    try {
      _plugin = HandLandmarkerPlugin.create(
        numHands: 2,
        minHandDetectionConfidence: 0.7,
        delegate: HandLandmarkerDelegate.gpu,
      );
    } catch (error) {
      debugPrint('GPU hand landmarker failed, falling back to CPU: $error');
      _plugin = HandLandmarkerPlugin.create(
        numHands: 2,
        minHandDetectionConfidence: 0.7,
        delegate: HandLandmarkerDelegate.cpu,
      );
    }
    _listenForLandmarks();
  }

  void _listenForLandmarks() {
    final plugin = _plugin;
    if (plugin == null || _landmarkSub != null) {
      return;
    }
    _landmarkSub = plugin.landmarkStream.listen((hands) {
      _latestHands = hands;
      _hands.value = hands;
      if (_isRecording) {
        _bufferGestureFrame(hands);
      }
      if (widget.purpose == CameraPurpose.liveTest) {
        _updatePrediction(hands);
      }
    });
  }

  Future<void> _loadClassifier() async {
    final classifier = SignClassifier();
    await classifier.load();
    if (!mounted) {
      classifier.close();
      return;
    }
    setState(() => _classifier = classifier);
  }

  void _updatePrediction(List<Hand> hands) {
    final classifier = _classifier;
    if (classifier == null || !classifier.isReady) {
      return;
    }

    if (hands.isEmpty) {
      _motionWindow.clear();
      _pendingLabel = null;
      _pendingCount = 0;
      _pendingMotionLabel = null;
      _pendingMotionCount = 0;
      _publishPrediction(null, 0, null, 0);
      return;
    }

    final sample = normalizeHand(hands.first);
    if (sample == null) {
      return;
    }

    _motionWindow.add(List<double>.from(sample.values));
    if (_motionWindow.length > gestureFrameCount) {
      _motionWindow.removeAt(0);
    }

    final now = DateTime.now();
    final last = _lastInference;
    if (last != null &&
        now.difference(last) < const Duration(milliseconds: 100)) {
      return;
    }
    _lastInference = now;

    final staticPrediction = classifier.predictStatic(sample.values);
    _applyStablePrediction(
      prediction: staticPrediction,
      pendingLabel: _pendingLabel,
      pendingCount: _pendingCount,
      onPending: (label, count) {
        _pendingLabel = label;
        _pendingCount = count;
      },
    );

    final motionPrediction = classifier.predictMotion(_motionWindow);
    _applyStablePrediction(
      prediction: motionPrediction,
      pendingLabel: _pendingMotionLabel,
      pendingCount: _pendingMotionCount,
      onPending: (label, count) {
        _pendingMotionLabel = label;
        _pendingMotionCount = count;
      },
      isMotion: true,
    );
  }

  void _applyStablePrediction({
    required SignPrediction? prediction,
    required String? pendingLabel,
    required int pendingCount,
    required void Function(String? label, int count) onPending,
    bool isMotion = false,
  }) {
    if (prediction == null || prediction.confidence < 0.55) {
      onPending(null, 0);
      if (isMotion) {
        _publishPrediction(_predictedLabel, _predictedConfidence, null, 0);
      } else {
        _publishPrediction(
          null,
          prediction?.confidence ?? 0,
          _motionLabel,
          _motionConfidence,
        );
      }
      return;
    }

    final count = pendingLabel == prediction.label ? pendingCount + 1 : 1;
    onPending(prediction.label, count);
    if (count < 3) {
      return;
    }

    if (isMotion) {
      _publishPrediction(
        _predictedLabel,
        _predictedConfidence,
        prediction.label,
        prediction.confidence,
      );
    } else {
      _publishPrediction(
        prediction.label,
        prediction.confidence,
        _motionLabel,
        _motionConfidence,
      );
    }
  }

  void _publishPrediction(
    String? label,
    double confidence,
    String? motionLabel,
    double motionConfidence,
  ) {
    if (_predictedLabel == label &&
        _motionLabel == motionLabel &&
        (_predictedConfidence - confidence).abs() < 0.01 &&
        (_motionConfidence - motionConfidence).abs() < 0.01) {
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _predictedLabel = label;
      _predictedConfidence = confidence;
      _motionLabel = motionLabel;
      _motionConfidence = motionConfidence;
      if (_practiceStarted && _expectedSignMatched) {
        _matchedDuringPractice = true;
      }
    });
  }

  void _startPracticeCountdown() {
    if (_practiceStarted || _practicePassed || widget.expectedSign == null) {
      return;
    }

    _countdownTimer?.cancel();
    setState(() {
      _practiceStarted = true;
      _countdownRemaining = _practiceSeconds;
      _matchedDuringPractice = _expectedSignMatched;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdownRemaining <= 1) {
        timer.cancel();
        _finishPracticeCountdown();
        return;
      }
      setState(() {
        _countdownRemaining -= 1;
        if (_expectedSignMatched) {
          _matchedDuringPractice = true;
        }
      });
    });
  }

  Future<void> _finishPracticeCountdown() async {
    _countdownTimer?.cancel();
    final passed = _matchedDuringPractice || _expectedSignMatched;
    if (!mounted) return;
    setState(() {
      _practicePassed = passed;
      _practiceStarted = false;
      _countdownRemaining = _practiceSeconds;
    });
    final accepted = await showSignResultDialog(
      context,
      correct: passed,
      sign: widget.expectedSign ?? '',
      xpEarned: passed ? widget.xpReward : 0,
    );
    if (!mounted) return;
    if (accepted) {
      Navigator.pop(context, true);
    }
  }

  bool get _expectedSignMatched {
    final expected = widget.expectedSign;
    if (expected == null) {
      return false;
    }
    return _isSameSign(_predictedLabel, expected) ||
        _isSameSign(_motionLabel, expected);
  }

  Future<void> _confirmExpectedSign() async {
    if (_practicePassed) {
      return;
    }
    if (!_expectedSignMatched) {
      _showMessage('Show the ${widget.expectedSign} sign first.');
      return;
    }

    setState(() {
      _practicePassed = true;
    });
    await showSignResultDialog(
      context,
      correct: true,
      sign: widget.expectedSign ?? '',
      xpEarned: widget.xpReward,
    );
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _openLog() async {
    try {
      final log = await HandSampleLog.open();
      final gestureLog = await GestureSampleLog.open();
      if (!mounted) {
        return;
      }
      setState(() {
        _log = log;
        _gestureLog = gestureLog;
      });
    } catch (error) {
      debugPrint('Failed to open sample log: $error');
    }
  }

  Future<void> _captureSample({bool silent = false}) async {
    final label = _labelController.text.trim();
    if (label.isEmpty) {
      if (!silent) {
        _showMessage('Enter a sign label first.');
      }
      return;
    }

    final log = _log;
    if (log == null) {
      if (!silent) {
        _showMessage('Sample file is not ready yet.');
      }
      return;
    }

    if (_latestHands.isEmpty) {
      if (!silent) {
        _showMessage('No hand in frame.');
      }
      return;
    }

    final saved = await log.append(label, _latestHands.first);
    if (!mounted) {
      return;
    }
    if (!saved) {
      if (!silent) {
        _showMessage('Could not read all 21 joints. Hold your hand in view.');
      }
      return;
    }
    setState(() {});
  }

  void _bufferGestureFrame(List<Hand> hands) {
    if (hands.isEmpty) {
      return;
    }
    final sample = normalizeHand(hands.first);
    if (sample == null) {
      return;
    }
    _frameBuffer.add(List<double>.from(sample.values));
  }

  Future<void> _recordGesture() async {
    if (_isRecording) {
      return;
    }
    final label = _labelController.text.trim();
    if (label.isEmpty) {
      _showMessage('Enter a sign label first.');
      return;
    }
    final gestureLog = _gestureLog;
    if (gestureLog == null) {
      _showMessage('Gesture file is not ready yet.');
      return;
    }

    final session = ++_gestureSession;
    _frameBuffer.clear();
    setState(() => _isRecording = true);
    await Future<void>.delayed(gestureRecordDuration);
    if (!mounted || session != _gestureSession) {
      return;
    }

    final frames = _frameBuffer.map(List<double>.from).toList(growable: false);
    setState(() => _isRecording = false);

    if (frames.isEmpty) {
      _showMessage('No hand was in frame during the recording.');
      return;
    }

    final saved = await gestureLog.append(label, frames);
    if (!mounted) {
      return;
    }
    if (!saved) {
      _showMessage('Could not save that gesture.');
      return;
    }
    setState(() {});
    _showMessage(
      'Saved "$label" (${frames.length} frames → $gestureFrameCount).',
    );
  }

  Future<void> _exportSamples() async {
    final files = <XFile>[];
    final names = <String>[];
    final log = _log;
    final gestureLog = _gestureLog;
    if (log != null && log.count > 0) {
      files.add(XFile(log.file.path, mimeType: 'text/csv'));
      names.add('hand_samples.csv');
    }
    if (gestureLog != null && gestureLog.count > 0) {
      files.add(XFile(gestureLog.file.path, mimeType: 'text/csv'));
      names.add('gesture_samples.csv');
    }
    if (files.isEmpty) {
      _showMessage('Capture a sample before exporting.');
      return;
    }

    try {
      await SharePlus.instance.share(
        ShareParams(
          files: files,
          fileNameOverrides: names,
          subject: 'Hand landmark samples',
        ),
      );
    } catch (error) {
      _showMessage('Could not export the CSV.\n$error');
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _initializeController(CameraDescription camera) async {
    // Release the current camera fully before opening another one.
    // Opening two controllers at once often leaves a blank preview on Android.
    final previous = _controller;
    _controller = null;
    if (previous != null) {
      await _stopAndDispose(previous);
    }

    if (!mounted) {
      return;
    }

    final controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    try {
      await controller.initialize();
      if (!mounted) {
        await _stopAndDispose(controller);
        return;
      }

      if (_plugin != null) {
        await controller.startImageStream(_processCameraImage);
      }

      if (!mounted) {
        await _stopAndDispose(controller);
        return;
      }

      setState(() {
        _controller = controller;
        _currentCamera = camera;
        _isInitializing = false;
        _errorMessage = null;
      });
    } on CameraException catch (error) {
      await _stopAndDispose(controller);
      _showError(_messageForCameraException(error));
    } catch (error) {
      await _stopAndDispose(controller);
      _showError('Failed to start the camera.\n$error');
    }
  }

  Future<void> _stopAndDispose(CameraController controller) async {
    try {
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }
    } catch (_) {
      // Already stopped or never started.
    }
    await controller.dispose();
  }

  void _disposeCamera() {
    final controller = _controller;
    _controller = null;
    if (controller == null) {
      return;
    }
    if (controller.value.isStreamingImages) {
      controller.stopImageStream();
    }
    controller.dispose();
  }

  void _processCameraImage(CameraImage image) {
    final plugin = _plugin;
    final controller = _controller;
    if (plugin == null ||
        controller == null ||
        !controller.value.isInitialized ||
        image.planes.length < 3) {
      return;
    }

    try {
      plugin.processFrame(image, controller.description.sensorOrientation);
    } catch (error) {
      debugPrint('Error processing hand landmarks: $error');
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2 ||
        _currentCamera == null ||
        _isInitializing ||
        _isSwitching) {
      return;
    }

    final currentIndex = _cameras.indexWhere(
      (camera) => camera.name == _currentCamera!.name,
    );
    final nextIndex = currentIndex < 0
        ? 0
        : (currentIndex + 1) % _cameras.length;
    final next = _cameras[nextIndex];

    _isSwitching = true;
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      await _initializeController(next);
    } finally {
      _isSwitching = false;
    }
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }
    setState(() {
      _isInitializing = false;
      _errorMessage = message;
    });
  }

  String _messageForCameraException(CameraException error) {
    switch (error.code) {
      case 'CameraAccessDenied':
        return 'Camera access was denied. Grant permission to continue.';
      case 'CameraAccessDeniedWithoutPrompt':
        return 'Camera access is blocked. Enable it in Settings > Privacy > Camera.';
      case 'CameraAccessRestricted':
        return 'Camera access is restricted on this device.';
      default:
        return error.description?.isNotEmpty == true
            ? error.description!
            : 'Camera error (${error.code}).';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildBody(),
          if (Navigator.canPop(context) && widget.expectedSign == null)
            Positioned(
              top: MediaQuery.paddingOf(context).top + 8,
              left: 8,
              child: IconButton.filledTonal(
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Back',
                icon: const Icon(Icons.arrow_back),
              ),
            ),
          if (_cameras.length > 1 &&
              _errorMessage == null &&
              widget.expectedSign == null)
            Positioned(
              right: 16,
              top: MediaQuery.paddingOf(context).top + 8,
              child: FloatingActionButton.small(
                onPressed: (_isInitializing || _isSwitching)
                    ? null
                    : _switchCamera,
                tooltip: 'Switch camera',
                child: const Icon(Icons.cameraswitch_outlined),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final controller = _controller;
    if (_errorMessage != null) {
      return _CameraStatus(
        icon: Icons.videocam_off_outlined,
        message: _errorMessage!,
        actionLabel: 'Try again',
        onAction: _startCamera,
      );
    }

    if (_isInitializing ||
        controller == null ||
        !controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final previewSize = controller.value.previewSize!;
    final plugin = _plugin;

    if (plugin == null) {
      return Column(
        children: [
          Expanded(
            flex: 3,
            child: _buildCameraPreview(controller, previewSize),
          ),
          const Expanded(
            flex: 2,
            child: ColoredBox(
              color: Color(0xFF121212),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Hand tracking with this plugin is Android-only.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    final preview = Expanded(
      flex: 3,
      child: _buildCameraPreview(controller, previewSize),
    );

    if (widget.purpose == CameraPurpose.liveTest &&
        widget.expectedSign != null) {
      final sign = widget.expectedSign!;
      final signTitle = sign.length == 1 ? 'Letter $sign' : sign;
      return Stack(
        fit: StackFit.expand,
        children: [
          _buildCameraPreview(controller, previewSize),
          _PracticeOverlay(
            signTitle: signTitle,
            started: _practiceStarted,
            countdown: _countdownRemaining,
            progress: _practiceStarted
                ? (_practiceSeconds - _countdownRemaining) / _practiceSeconds
                : 0,
            onClose: () {
              _countdownTimer?.cancel();
              Navigator.pop(context);
            },
            onStart: _startPracticeCountdown,
          ),
        ],
      );
    }

    if (widget.purpose == CameraPurpose.liveTest) {
      return Column(
        children: [
          preview,
          _LivePredictionPanel(
            label: _predictedLabel,
            confidence: _predictedConfidence,
            motionLabel: _motionLabel,
            motionConfidence: _motionConfidence,
            loadError: _classifier?.loadError,
            isLoading: _classifier == null,
            expectedSign: widget.expectedSign,
            isMatched: _expectedSignMatched,
            onConfirm: widget.expectedSign == null
                ? null
                : _confirmExpectedSign,
          ),
        ],
      );
    }

    return Column(
      children: [
        preview,
        SampleCaptureBar(
          labelController: _labelController,
          sampleCount: _log?.count ?? 0,
          gestureCount: _gestureLog?.count ?? 0,
          isBusy: _isRecording,
          statusLabel: _isRecording ? 'Recording…' : null,
          onCapture: () => _captureSample(),
          onRecordGesture: _recordGesture,
          onExport: _exportSamples,
        ),
        const Divider(height: 1, color: Colors.white24),
        Expanded(
          flex: 2,
          child: ValueListenableBuilder<List<Hand>>(
            valueListenable: _hands,
            builder: (context, hands, _) {
              return LandmarkValuesPanel(hands: hands);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCameraPreview(CameraController controller, Size previewSize) {
    return ColoredBox(
      color: Colors.black,
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: previewSize.height,
          height: previewSize.width,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CameraPreview(
                controller,
                key: ValueKey(controller.description.name),
              ),
              ValueListenableBuilder<List<Hand>>(
                valueListenable: _hands,
                builder: (context, hands, _) {
                  return CustomPaint(
                    painter: HandLandmarkPainter(
                      hands: hands,
                      previewSize: previewSize,
                      lensDirection: controller.description.lensDirection,
                      sensorOrientation:
                          controller.description.sensorOrientation,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PracticeOverlay extends StatelessWidget {
  const _PracticeOverlay({
    required this.signTitle,
    required this.started,
    required this.countdown,
    required this.progress,
    required this.onClose,
    required this.onStart,
  });

  final String signTitle;
  final bool started;
  final int countdown;
  final double progress;
  final VoidCallback onClose;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: started ? null : onStart,
      child: Container(
        color: started ? Colors.transparent : const Color(0x33000000),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, top + 12, 20, 28),
          child: Column(
            children: [
              Row(
                children: [
                  _RoundIconButton(
                    icon: Icons.close,
                    background: Colors.white,
                    foreground: const Color(0xFF1C6BFF),
                    onPressed: onClose,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        borderRadius: BorderRadius.circular(10),
                        value: progress,
                        minHeight: 14,
                        backgroundColor: const Color(0x66FFFFFF),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.blueDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                ],
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xCC2B2B2B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  signTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                started ? '$countdown' : 'Tap anywhere\nto start',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: started ? 72 : 34,
                  fontWeight: FontWeight.w700,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Keep signing till the end\nof the countdown',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  height: 1.25,
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onPressed,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, color: foreground, size: 28),
        ),
      ),
    );
  }
}

class _LivePredictionPanel extends StatelessWidget {
  const _LivePredictionPanel({
    required this.label,
    required this.confidence,
    required this.motionLabel,
    required this.motionConfidence,
    required this.loadError,
    required this.isLoading,
    this.expectedSign,
    this.isMatched = false,
    this.onConfirm,
  });

  final String? label;
  final double confidence;
  final String? motionLabel;
  final double motionConfidence;
  final String? loadError;
  final bool isLoading;
  final String? expectedSign;
  final bool isMatched;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF121212),
      child: SizedBox(
        height: expectedSign == null ? 180 : 320,
        width: double.infinity,
        child: isLoading
            ? const Center(
                child: Text(
                  'Loading sign models…',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (loadError != null)
                      Text(
                        loadError!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    _PredictionLine(
                      title: 'Still sign',
                      label: label,
                      confidence: confidence,
                      emptyText: 'Show a hand sign',
                    ),
                    const SizedBox(height: 12),
                    _PredictionLine(
                      title: 'Motion',
                      label: motionLabel,
                      confidence: motionConfidence,
                      emptyText: 'Perform a motion',
                    ),
                    if (expectedSign != null && onConfirm != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        isMatched
                            ? '$expectedSign recognized'
                            : 'Make the $expectedSign sign',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isMatched
                              ? const Color(0xFF249689)
                              : Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: FilledButton(
                          onPressed: onConfirm,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF249689),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Confirm'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}

class _PredictionLine extends StatelessWidget {
  const _PredictionLine({
    required this.title,
    required this.label,
    required this.confidence,
    required this.emptyText,
  });

  final String title;
  final String? label;
  final double confidence;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          label ?? emptyText,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: label == null ? 16 : 28,
            fontWeight: FontWeight.w600,
            height: 1.1,
          ),
        ),
        if (label != null)
          Text(
            '${(confidence * 100).round()}% confident',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
      ],
    );
  }
}

bool _isSameSign(String? predicted, String expected) {
  if (predicted == null) {
    return false;
  }
  return _canonicalSign(predicted) == _canonicalSign(expected);
}

String _canonicalSign(String value) {
  final normalized = value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  return switch (normalized) {
    'yes' || 'ya' => 'ya',
    'no' || 'tidak' => 'tidak',
    _ => normalized,
  };
}

class _CameraStatus extends StatelessWidget {
  const _CameraStatus({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Colors.white70),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
