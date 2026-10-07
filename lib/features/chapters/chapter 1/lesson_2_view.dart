import 'package:flutter/material.dart';
import 'package:handy/features/chapters/chapter 1/lesson_flow.dart';
import 'package:handy/features/chapters/chapter 1/learn_sign_question.dart';
import 'package:handy/features/chapters/chapter 1/video_quiz_question.dart';
import 'package:handy/features/chapters/chapter 1/match_video_quiz.dart';
import 'package:handy/features/chapters/chapter 1/true_or_false_question.dart';

class Lesson2View extends StatelessWidget {
  static const _apaKhabarVideoAsset = 'assets/chapter_1/apa_khabar.mp4';
  static const _khabarBaikVideoAsset = 'assets/chapter_1/khabar_baik.mp4';
  static const _terimaKasihVideoAsset = 'assets/chapter_1/terima_kasih.mp4';
  static const _samaSamaVideoAsset = 'assets/chapter_1/sama_sama.mp4';
  const Lesson2View({super.key});

  @override
  Widget build(BuildContext context) {
    return LessonFlow(
      questions: [
        (onContinue) => LearnSignQuestion(
          key: ValueKey('lesson-2-question-1'),
          videoAsset: _apaKhabarVideoAsset,
          sign: 'Apa khabar?',
          onContinue: onContinue,
        ),
        (onContinue) => LearnSignQuestion(
          key: const ValueKey('lesson-2-question-2'),
          videoAsset: _khabarBaikVideoAsset,
          sign: 'Khabar Baik',
          onContinue: onContinue,
        ),
        (onContinue) => LearnSignQuestion(
          key: const ValueKey('lesson-2-question-3'),
          videoAsset: _terimaKasihVideoAsset,
          sign: 'Terima kasih',
          onContinue: onContinue,
        ),
        (onContinue) => LearnSignQuestion(
          key: const ValueKey('lesson-2-question-4'),
          videoAsset: _samaSamaVideoAsset,
          sign: 'Sama - sama',
          onContinue: onContinue,
        ),
        (onContinue) => VideoQuizQuestion(
          key: const ValueKey('lesson-2-question-5'),
          videoAsset: _samaSamaVideoAsset,
          options: const ['Hello', 'Sama - sama', 'Khabar Baik'],
          correctAnswer: 'Sama - sama',
          onContinue: onContinue,
        ),
        (onContinue) => VideoQuizQuestion(
          key: const ValueKey('lesson-2-question-6'),
          videoAsset: _terimaKasihVideoAsset,
          options: const ['Waalaikumussalam', 'Apa khabar?', 'Terima kasih'],
          correctAnswer: 'Terima kasih',
          onContinue: onContinue,
        ),
        (onContinue) => TrueOrFalseQuestion(
          key: const ValueKey('lesson-2-question-7'),
          videoAsset: _khabarBaikVideoAsset,
          statement: 'Apa khabar?',
          correctAnswer: false,
          onContinue: onContinue,
        ),
        (onContinue) => MatchVideoQuiz(
          key: const ValueKey('lesson-2-question-8'),
          pairs: const [
            VideoMatchPair(
              videoAsset: _apaKhabarVideoAsset,
              label: 'Apa khabar?',
            ),
            VideoMatchPair(
              videoAsset: _khabarBaikVideoAsset,
              label: 'Khabar Baik',
            ),
            VideoMatchPair(
              videoAsset: _terimaKasihVideoAsset,
              label: 'Terima kasih',
            ),
            VideoMatchPair(
              videoAsset: _samaSamaVideoAsset,
              label: 'Sama - sama',
            ),
          ],
          onContinue: onContinue,
        ),
      ],
    );
  }
}
