import 'package:flutter/material.dart';
import 'package:handy/features/chapters/chapter 1/lesson_flow.dart';
import 'package:handy/features/chapters/chapter 1/learn_sign_question.dart';
import 'package:handy/features/chapters/chapter 1/video_quiz_question.dart';
import 'package:handy/features/chapters/chapter 1/match_video_quiz.dart';

class Lesson2View extends StatelessWidget {
  static const _helloVideoAsset = 'assets/chapter_1/hello.mp4';
  static const _assalamualaikumVideoAsset =
      'assets/chapter_1/assalamualaikum.mp4';
  static const _waalaikumussalamVideoAsset =
      'assets/chapter_1/waalaikumussalam.mp4';
  const Lesson2View({super.key});

  @override
  Widget build(BuildContext context) {
    return LessonFlow(
      questions: [
        (onContinue) => LearnSignQuestion(
          key: ValueKey('lesson-1-question-1'),
          videoAsset: _helloVideoAsset,
          sign: 'Hello',
          onContinue: onContinue,
        ),
        (onContinue) => LearnSignQuestion(
          key: const ValueKey('lesson-1-question-2'),
          videoAsset: _assalamualaikumVideoAsset,
          sign: 'Assalamualaikum',
          onContinue: onContinue,
        ),
        (onContinue) => VideoQuizQuestion(
          key: const ValueKey('lesson-1-question-3'),
          videoAsset: _helloVideoAsset,
          options: const ['Hello', 'Thank you', 'Assalamualaikum'],
          correctAnswer: 'Hello',
          onContinue: onContinue,
        ),
        (onContinue) => LearnSignQuestion(
          key: const ValueKey('lesson-1-question-4'),
          videoAsset: _waalaikumussalamVideoAsset,
          sign: 'Waalaikumussalam',
          onContinue: onContinue,
        ),
        (onContinue) => VideoQuizQuestion(
          key: const ValueKey('lesson-1-question-5'),
          videoAsset: _assalamualaikumVideoAsset,
          options: const ['Hello', 'Assalamualaikum', 'Waalaikumussalam'],
          correctAnswer: 'Assalamualaikum',
          onContinue: onContinue,
        ),
        (onContinue) => VideoQuizQuestion(
          key: const ValueKey('lesson-1-question-6'),
          videoAsset: _waalaikumussalamVideoAsset,
          options: const ['Hello', 'Assalamualaikum', 'Waalaikumussalam'],
          correctAnswer: 'Waalaikumussalam',
          onContinue: onContinue,
        ),
        (onContinue) => MatchVideoQuiz(
          key: const ValueKey('lesson-1-question-7'),
          pairs: const [
            VideoMatchPair(videoAsset: _helloVideoAsset, label: 'Hello'),
            VideoMatchPair(
              videoAsset: _assalamualaikumVideoAsset,
              label: 'Assalamualaikum',
            ),
            VideoMatchPair(
              videoAsset: _waalaikumussalamVideoAsset,
              label: 'Waalaikumussalam',
            ),
          ],
          onContinue: onContinue,
        ),
      ],
    );
  }
}
