import 'package:flutter/material.dart';
import 'package:handy/features/chapters/chapter 1/learn_sign_question.dart';
import 'package:handy/features/chapters/chapter 1/lesson_flow.dart';
import 'package:handy/features/chapters/chapter_controller.dart';

class Chapter1View extends StatelessWidget {
  const Chapter1View({required this.lesson, super.key});

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    final questions = lesson.lessonQuestions.toList()
      ..sort((a, b) => a.questionNo.compareTo(b.questionNo));

    return LessonFlow(
      questions: [
        for (final question in questions)
          (onContinue) => LearnSignQuestion(
            key: ValueKey('question-${question.questionNo}'),
            videoUrl: question.playableVideoUrl,
            sign: question.questionText,
            onContinue: onContinue,
          ),
      ],
    );
  }
}
