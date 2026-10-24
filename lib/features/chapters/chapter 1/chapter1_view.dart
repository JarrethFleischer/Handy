import 'package:flutter/material.dart';
import 'package:handy/features/chapters/chapter 1/learn_sign_question.dart';
import 'package:handy/features/chapters/chapter 1/lesson_flow.dart';
import 'package:handy/features/chapters/chapter 1/match_video_quiz.dart';
import 'package:handy/features/chapters/chapter 1/true_or_false_question.dart';
import 'package:handy/features/chapters/chapter 1/video_quiz_question.dart';
import 'package:handy/features/chapters/chapter_controller.dart';

class Chapter1View extends StatelessWidget {
  const Chapter1View({
    required this.lesson,
    this.awardsXp = true,
    super.key,
  });

  final Lesson lesson;
  final bool awardsXp;

  @override
  Widget build(BuildContext context) {
    final questions = lesson.lessonQuestions.toList()
      ..sort((a, b) => a.questionNo.compareTo(b.questionNo));

    return LessonFlow(
      awardsXp: awardsXp,
      questions: [
        for (final question in questions) _questionBuilder(question),
      ],
    );
  }

  Widget Function(LessonContinue onContinue) _questionBuilder(
    LessonQuestion question,
  ) {
    if (question.questionVideos.length > 1 &&
        question.questionQuiz.isNotEmpty) {
      final videos = question.playableVideoUrls;
      return (onContinue) => MatchVideoQuiz(
        key: ValueKey('match-${question.questionNo}'),
        pairs: [
          for (final video in videos)
            VideoMatchPair(
              videoUrl: video,
              label: _labelForVideo(video, question.questionQuiz),
            ),
        ],
        onContinue: onContinue,
      );
    }

    if (_isTrueOrFalse(question)) {
      return (onContinue) => TrueOrFalseQuestion(
        key: ValueKey('true-false-${question.questionNo}'),
        videoUrl: question.playableVideoUrl,
        statement: question.questionText,
        correctAnswer: _statementMatchesVideo(
          question.questionText,
          question.playableVideoUrl,
        ),
        onContinue: onContinue,
      );
    }

    if (question.questionQuiz.isNotEmpty) {
      return (onContinue) => VideoQuizQuestion(
        key: ValueKey('quiz-${question.questionNo}'),
        videoUrl: question.playableVideoUrl,
        title: question.questionTitle,
        options: question.questionQuiz,
        correctAnswer: _labelForVideo(
          question.playableVideoUrl,
          question.questionQuiz,
        ),
        onContinue: onContinue,
      );
    }

    return (onContinue) => LearnSignQuestion(
      key: ValueKey('learn-${question.questionNo}'),
      videoUrl: question.playableVideoUrl,
      sign: question.questionText,
      onContinue: onContinue,
    );
  }

  bool _isTrueOrFalse(LessonQuestion question) {
    final choices = question.questionQuiz.map((choice) => choice.toLowerCase());
    return choices.contains('true') && choices.contains('false');
  }

  bool _statementMatchesVideo(String statement, String videoUrl) {
    return _words(statement) == _signFromVideo(videoUrl);
  }

  String _words(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .trim();
  }

  String _labelForVideo(String videoUrl, List<String> options) {
    final sign = _signFromVideo(videoUrl);
    for (final option in options) {
      if (_words(option) == sign) return option;
    }
    return options.first;
  }

  String _signFromVideo(String videoUrl) {
    final fileName = Uri.parse(videoUrl).pathSegments.last;
    return _words(fileName.replaceAll(RegExp(r'\.mp4$', caseSensitive: false), ''));
  }
}
