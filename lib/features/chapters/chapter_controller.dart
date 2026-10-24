import 'dart:convert';

import 'package:handy/core/config/api_config.dart';
import 'package:http/http.dart' as http;

class LessonQuestion {
  const LessonQuestion({
    required this.questionNo,
    required this.questionTitle,
    required this.questionText,
    required this.questionQuiz,
    required this.questionVideos,
    required this.questionVideo,
  });

  final int questionNo;
  final String questionTitle;
  final String questionText;
  final List<String> questionQuiz;
  final List<String> questionVideos;
  final String questionVideo;

  factory LessonQuestion.fromJson(Map<String, dynamic> json) {
    final quiz = json['questionQuiz'];
    final video = json['questionVideo'];
    final videos = video is List
        ? video
              .map((item) => item.toString())
              .where((item) => item.isNotEmpty)
              .toList()
        : video is String && video.isNotEmpty
        ? [video]
        : <String>[];
    return LessonQuestion(
      questionNo: (json['questionNo'] as num).toInt(),
      questionTitle: json['questionTitle'] as String? ?? '',
      questionText: json['questionText'] as String? ?? '',
      questionQuiz: quiz is List
          ? quiz.map((item) => item.toString()).toList()
          : const [],
      questionVideos: videos,
      questionVideo: videos.isEmpty ? '' : videos.first,
    );
  }

  String get playableVideoUrl => _playable(questionVideo);

  List<String> get playableVideoUrls =>
      questionVideos.map(_playable).toList();

  static String _playable(String videoUrl) {
    if (videoUrl.isEmpty) return videoUrl;
    final video = Uri.parse(videoUrl);
    final base = Uri.parse(ApiConfig.baseUrl);
    final isLocalHost = video.host == '127.0.0.1' || video.host == 'localhost';
    if (!isLocalHost) return videoUrl;

    return Uri(
      scheme: base.scheme,
      host: base.host,
      port: base.hasPort ? base.port : null,
      path: video.path,
    ).toString();
  }
}

class Lesson {
  const Lesson({
    required this.lessonTitle,
    required this.lessonNo,
    required this.lessonDesc,
    required this.lessonQuestions,
  });

  final int lessonNo;
  final String lessonTitle;
  final String lessonDesc;
  final List<LessonQuestion> lessonQuestions;

  factory Lesson.fromJson(Map<String, dynamic> json) {
    final questions = json['lessonQuestions'] as List<dynamic>? ?? [];
    return Lesson(
      lessonNo: (json['lessonNo'] as num).toInt(),
      lessonTitle: json['lessonTitle'] as String? ?? '',
      lessonDesc: json['lessonDesc'] as String? ?? '',
      lessonQuestions: questions
          .map((item) => LessonQuestion.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ChapterStory {
  const ChapterStory({
    required this.chapterTitle,
    required this.chapterDesc,
    required this.chapterContent,
  });

  final String chapterTitle;
  final String chapterDesc;
  final List<Lesson> chapterContent;

  factory ChapterStory.fromJson(Map<String, dynamic> json) {
    final content = json['chapterContent'] as List<dynamic>? ?? [];
    return ChapterStory(
      chapterTitle: json['chapterTitle'] as String,
      chapterDesc: json['chapterDesc'] as String,
      chapterContent: content
          .map((item) => Lesson.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Chapter {
  const Chapter({
    required this.chapterID,
    required this.chapterLevel,
    required this.chapterStory,
    required this.chapterStatus,
    required this.chapterDateCreated,
  });

  final int chapterID;
  final int chapterLevel;
  final ChapterStory chapterStory;
  final int chapterStatus;
  final String chapterDateCreated;

  bool get isUnlocked => chapterStatus == 1;

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      chapterID: (json['chapterID'] as num).toInt(),
      chapterLevel: (json['chapterLevel'] as num).toInt(),
      chapterStory: ChapterStory.fromJson(
        json['chapterStory'] as Map<String, dynamic>,
      ),
      chapterStatus: (json['chapterStatus'] as num).toInt(),
      chapterDateCreated: json['chapterDateCreated'] as String,
    );
  }
}

class ChapterController {
  Future<List<Chapter>> fetchChapters() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/chapters/'),
    );

    if (response.statusCode != 200) {
      throw Exception('Chapter request failed (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    final chapters = data
        .map((item) => Chapter.fromJson(item as Map<String, dynamic>))
        .toList();
    chapters.sort((a, b) => a.chapterLevel.compareTo(b.chapterLevel));
    return chapters;
  }
}
