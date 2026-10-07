import 'package:flutter/material.dart';
import 'package:handy/features/chapters/chapter 1/learn_sign_question.dart';
import 'package:handy/features/chapters/chapter 1/lesson_flow.dart';
import 'package:handy/features/chapters/chapter 1/match_video_quiz.dart';
import 'package:handy/features/chapters/chapter 1/video_quiz_question.dart';

class Lesson1View extends StatelessWidget {
  const Lesson1View({super.key});

  static const _helloVideo = 'assets/chapter_1/hello.mp4';
  static const _assalamualaikumVideo = 'assets/chapter_1/assalamualaikum.mp4';
  static const _waalaikumussalamVideo = 'assets/chapter_1/waalaikumussalam.mp4';

  @override
  Widget build(BuildContext context) {
    return LessonFlow(
      questions: [
        (onContinue) => LearnSignQuestion(
          key: const ValueKey('lesson-1-question-1'),
          videoAsset: _helloVideo,
          sign: 'Hello',
          onContinue: onContinue,
        ),
        (onContinue) => LearnSignQuestion(
          key: const ValueKey('lesson-1-question-2'),
          videoAsset: _assalamualaikumVideo,
          sign: 'Assalamualaikum',
          onContinue: onContinue,
        ),
        (onContinue) => VideoQuizQuestion(
          key: const ValueKey('lesson-1-question-3'),
          videoAsset: _helloVideo,
          options: const ['Hello', 'Thank you', 'Assalamualaikum'],
          correctAnswer: 'Hello',
          onContinue: onContinue,
        ),
        (onContinue) => LearnSignQuestion(
          key: const ValueKey('lesson-1-question-4'),
          videoAsset: _waalaikumussalamVideo,
          sign: 'Waalaikumussalam',
          onContinue: onContinue,
        ),
        (onContinue) => VideoQuizQuestion(
          key: const ValueKey('lesson-1-question-5'),
          videoAsset: _assalamualaikumVideo,
          options: const ['Hello', 'Assalamualaikum', 'Waalaikumussalam'],
          correctAnswer: 'Assalamualaikum',
          onContinue: onContinue,
        ),
        (onContinue) => VideoQuizQuestion(
          key: const ValueKey('lesson-1-question-6'),
          videoAsset: _waalaikumussalamVideo,
          options: const ['Hello', 'Assalamualaikum', 'Waalaikumussalam'],
          correctAnswer: 'Waalaikumussalam',
          onContinue: onContinue,
        ),
        (onContinue) => MatchVideoQuiz(
          key: const ValueKey('lesson-1-question-7'),
          pairs: const [
            VideoMatchPair(videoAsset: _helloVideo, label: 'Hello'),
            VideoMatchPair(
              videoAsset: _assalamualaikumVideo,
              label: 'Assalamualaikum',
            ),
            VideoMatchPair(
              videoAsset: _waalaikumussalamVideo,
              label: 'Waalaikumussalam',
            ),
          ],
          onContinue: onContinue,
        ),
      ],
    );
  }
}
