import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Simple API client for feedback. Kept separate from auth_service.dart.
/// Uses dart:io (no extra packages), same as the auth service.
class FeedbackService {
  static const String baseUrl = 'http://103.71.176.196';
  static const Duration _timeout = Duration(seconds: 15);

  /// Sends feedback. Returns the created feedback as a [FeedbackResult].
  /// Throws [FeedbackException] with a readable message on any failure.
  static Future<FeedbackResult> create({
    required int userId,
    required String content,
  }) async {
    final client = HttpClient()..connectionTimeout = _timeout;
    try {
      final request = await client.postUrl(
        Uri.parse('$baseUrl/api/feedbacks/create'),
      );
      request.headers.contentType = ContentType.json;
      request.write(
        jsonEncode({'feedbackUserID': userId, 'feedbackContent': content}),
      );

      final response = await request.close().timeout(_timeout);
      final text = await response.transform(utf8.decoder).join();

      dynamic data;
      try {
        data = text.isEmpty ? null : jsonDecode(text);
      } catch (_) {
        data = text;
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (data is Map<String, dynamic>) return FeedbackResult.fromJson(data);
        // Server said OK but sent something unexpected; still a success.
        return FeedbackResult(content: content, userId: userId);
      }
      throw FeedbackException(_extractMessage(data, response.statusCode));
    } on FeedbackException {
      rethrow;
    } on SocketException {
      throw FeedbackException(
        'Cannot reach server. Check your internet connection.',
      );
    } on TimeoutException {
      throw FeedbackException('Server took too long to respond.');
    } on HttpException catch (e) {
      throw FeedbackException('Network error: ${e.message}');
    } catch (e) {
      throw FeedbackException('Unexpected error: $e');
    } finally {
      client.close();
    }
  }

  static String _extractMessage(dynamic data, int status) {
    if (data is Map) {
      for (final key in ['message', 'error', 'msg', 'detail']) {
        final v = data[key];
        if (v != null && v.toString().isNotEmpty) return v.toString();
      }
    } else if (data is String && data.isNotEmpty && data.length < 200) {
      return data;
    }
    switch (status) {
      case 400:
        return 'Invalid feedback (400).';
      case 404:
        return 'User not found (404).';
      default:
        return 'Server error ($status).';
    }
  }
}

/// Mirrors the API response:
/// { feedbackContent, feedbackID, feedbackUserID, userName, feedbackDateCreated }
class FeedbackResult {
  final int? id;
  final int? userId;
  final String content;
  final String? userName;
  final String? dateCreated;

  FeedbackResult({
    this.id,
    this.userId,
    required this.content,
    this.userName,
    this.dateCreated,
  });

  factory FeedbackResult.fromJson(Map<String, dynamic> json) {
    return FeedbackResult(
      id: json['feedbackID'] as int?,
      userId: json['feedbackUserID'] as int?,
      content: (json['feedbackContent'] ?? '').toString(),
      userName: json['userName'] as String?,
      dateCreated: json['feedbackDateCreated'] as String?,
    );
  }
}

class FeedbackException implements Exception {
  final String message;
  FeedbackException(this.message);
  @override
  String toString() => message;
}
