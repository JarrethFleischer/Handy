import 'dart:math' as math;

import 'package:handy/features/camera/landmarks/gesture_sample_log.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class SignPrediction {
  const SignPrediction({required this.label, required this.confidence});

  final String label;
  final double confidence;
}

/// Runs the still-sign model and the motion model on the same landmark stream.
///
/// The still-sign model is [assets/ai/hand_sign_model.tflite] with input `[1, 63]`.
/// The motion model is [assets/ai/motion_model.tflite] with input `[1, 30, 63]`.
class SignClassifier {
  Interpreter? _staticInterpreter;
  Interpreter? _motionInterpreter;
  List<String> _staticLabels = const [];
  List<String> _motionLabels = const [];
  String? loadError;

  bool get isReady =>
      (_staticInterpreter != null && _staticLabels.isNotEmpty) ||
      (_motionInterpreter != null && _motionLabels.isNotEmpty);

  Future<void> load() async {
    final errors = <String>[];

    try {
      _staticInterpreter = await Interpreter.fromAsset(
        'assets/ai/hand_sign_model.tflite',
      );
      _staticLabels = await _readLabels('assets/ai/labels.txt');
      if (_staticLabels.isEmpty) {
        errors.add('labels.txt does not contain any signs.');
      }
    } catch (error) {
      errors.add('Could not load the still-sign model.\n$error');
    }

    try {
      _motionInterpreter = await Interpreter.fromAsset(
        'assets/ai/motion_model.tflite',
      );
      _motionLabels = await _readLabels('assets/ai/motion_labels.txt');
      if (_motionLabels.isEmpty) {
        errors.add('motion_labels.txt does not contain any signs.');
      }
    } catch (error) {
      errors.add('Could not load the motion model.\n$error');
    }

    loadError = errors.isEmpty ? null : errors.join('\n');
  }

  /// Classifies one normalized frame. Input shape is `[1, 63]`.
  SignPrediction? predictStatic(List<double> features) {
    return _predict(_staticInterpreter, _staticLabels, features);
  }

  /// Classifies the last [gestureFrameCount] frames. Input shape is `[1, 30, 63]`.
  SignPrediction? predictMotion(List<List<double>> frames) {
    if (_motionInterpreter == null || frames.length < gestureFrameCount) {
      return null;
    }
    final window = frames.length == gestureFrameCount
        ? frames
        : frames.sublist(frames.length - gestureFrameCount);
    final flat = window.expand((frame) => frame).toList(growable: false);
    return _predict(_motionInterpreter, _motionLabels, flat);
  }

  SignPrediction? _predict(
    Interpreter? interpreter,
    List<String> labels,
    List<double> features,
  ) {
    if (interpreter == null || labels.isEmpty) {
      return null;
    }

    final inputTensor = interpreter.getInputTensor(0);
    final outputTensor = interpreter.getOutputTensor(0);
    final input = _shapeFeatures(features, inputTensor.shape);
    final output = _zeros(outputTensor.shape);
    interpreter.run(input, output);

    final scores = _flatten(output);
    if (scores.isEmpty) {
      return null;
    }

    final probabilities = _asProbabilities(scores);
    var bestIndex = 0;
    var bestScore = probabilities[0];
    for (var index = 1; index < probabilities.length; index++) {
      if (probabilities[index] > bestScore) {
        bestScore = probabilities[index];
        bestIndex = index;
      }
    }

    final label = bestIndex < labels.length ? labels[bestIndex] : 'Unknown';
    return SignPrediction(label: label, confidence: bestScore);
  }

  Future<List<String>> _readLabels(String assetPath) async {
    final rawLabels = await rootBundle.loadString(assetPath);
    return rawLabels
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);
  }

  void close() {
    _staticInterpreter?.close();
    _motionInterpreter?.close();
    _staticInterpreter = null;
    _motionInterpreter = null;
  }

  Object _shapeFeatures(List<double> features, List<int> shape) {
    final expected = shape
        .where((size) => size > 0)
        .fold<int>(1, (a, b) => a * b);
    final values = features.length == expected
        ? features
        : List<double>.generate(
            expected,
            (index) => index < features.length ? features[index] : 0,
          );
    return _nest(values, shape);
  }

  Object _nest(List<double> values, List<int> shape) {
    if (shape.length <= 1) {
      return values;
    }
    final innerCount = shape.sublist(1).fold<int>(1, (a, b) => a * b);
    return List<Object>.generate(shape[0], (index) {
      final start = index * innerCount;
      return _nest(values.sublist(start, start + innerCount), shape.sublist(1));
    });
  }

  Object _zeros(List<int> shape) {
    if (shape.length <= 1) {
      return List<double>.filled(shape.isEmpty ? 1 : shape[0], 0);
    }
    return List<Object>.generate(shape[0], (_) => _zeros(shape.sublist(1)));
  }

  List<double> _flatten(Object value) {
    if (value is double) {
      return [value];
    }
    if (value is int) {
      return [value.toDouble()];
    }
    if (value is List) {
      final scores = <double>[];
      for (final item in value) {
        scores.addAll(_flatten(item as Object));
      }
      return scores;
    }
    return const [];
  }

  List<double> _asProbabilities(List<double> scores) {
    final sum = scores.fold<double>(0, (total, score) => total + score);
    final alreadyProbabilities =
        scores.every((score) => score >= 0 && score <= 1) &&
        (sum - 1).abs() < 0.15;
    if (alreadyProbabilities) {
      return scores;
    }

    final maxScore = scores.reduce(math.max);
    final shifted = scores.map((score) => math.exp(score - maxScore)).toList();
    final total = shifted.fold<double>(0, (sum, score) => sum + score);
    if (total == 0) {
      return scores;
    }
    return shifted.map((score) => score / total).toList(growable: false);
  }
}
