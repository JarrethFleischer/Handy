import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Simple API client for login / sign up / forgot password.
/// Uses dart:io (no extra packages).
class AuthService {
  static const String baseUrl = 'http://103.71.176.196';
  static const Duration _timeout = Duration(seconds: 15);

  /// Returns decoded response body on success, throws [AuthException] on failure.
  static Future<dynamic> login({
    required String username,
    required String password,
  }) {
    return _post('/api/user/login', {
      'username': username,
      'password': password,
    });
  }

  static Future<dynamic> signup({
    required String name,
    required String email,
    required String password,
  }) {
    return _post('/api/user/create', {
      'userName': name,
      'userUsername': email,
      'userPassword': password,
      'userStatus': 1,
    });
  }

  static Future<dynamic> sendOtp({required String email}) {
    return _post('/api/user/forgot-password/send-otp', {
      'userUsername': email,
    });
  }

  static Future<dynamic> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) {
    return _post('/api/user/forgot-password/reset', {
      'userUsername': email,
      'otpCode': otp,
      'newPassword': newPassword,
    });
  }

  static Future<dynamic> _post(String path, Map<String, dynamic> body) async {
    final client = HttpClient()..connectionTimeout = _timeout;
    try {
      final request = await client.postUrl(Uri.parse('$baseUrl$path'));
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(body));

      final response = await request.close().timeout(_timeout);
      final text = await response.transform(utf8.decoder).join();

      dynamic data;
      try {
        data = text.isEmpty ? null : jsonDecode(text);
      } catch (_) {
        data = text;
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      }
      throw AuthException(_extractMessage(data, response.statusCode));
    } on AuthException {
      rethrow;
    } on SocketException {
      throw AuthException('Cannot reach server. Check your internet connection.');
    } on TimeoutException {
      throw AuthException('Server took too long to respond.');
    } on HttpException catch (e) {
      throw AuthException('Network error: ${e.message}');
    } catch (e) {
      throw AuthException('Unexpected error: $e');
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
        return 'Invalid request (400).';
      case 401:
        return 'Incorrect email or password.';
      case 404:
        return 'Account not found (404).';
      case 409:
        return 'Account already exists.';
      default:
        return 'Server error ($status).';
    }
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

final RegExp emailRegex = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');
