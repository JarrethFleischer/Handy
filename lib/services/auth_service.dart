import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple API client for login / sign up / forgot password.
/// Uses dart:io (no extra packages).
class AuthService {
  static const String baseUrl = 'http://103.71.176.196';
  static const Duration _timeout = Duration(seconds: 15);
  static const String _tokenKey = 'access_token';

  /// Signed-in account, taken from the JWT `sub` claim.
  static int? currentUserId;
  static String? accessToken;

  /// Latest streak count returned by the server, so streak UI can update
  /// immediately instead of waiting for the next profile fetch.
  static final ValueNotifier<int?> streakCount = ValueNotifier<int?>(null);

  /// Loads a saved token from the last login. Returns false when missing or expired.
  static Future<bool> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token == null || token.isEmpty) {
      currentUserId = null;
      accessToken = null;
      return false;
    }
    final userId = _userIdFromToken(token);
    if (userId == null || _isExpired(token)) {
      await logout();
      return false;
    }
    accessToken = token;
    currentUserId = userId;
    return true;
  }

  static Future<void> logout() async {
    currentUserId = null;
    accessToken = null;
    streakCount.value = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  /// Returns decoded response body on success, throws [AuthException] on failure.
  static Future<dynamic> login({
    required String username,
    required String password,
  }) async {
    final data = await _post('/api/user/login', {
      'username': username,
      'password': password,
    });
    if (data is Map && data['access_token'] is String) {
      final token = data['access_token'] as String;
      final userId = _userIdFromToken(token);
      if (userId == null) {
        throw AuthException('Login succeeded, but the token was invalid.');
      }
      accessToken = token;
      currentUserId = userId;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    }
    return data;
  }

  static Future<dynamic> updateUser({
    required String name,
    required String email,
  }) {
    final userId = currentUserId;
    if (userId == null) {
      throw AuthException('You are not logged in.');
    }
    return _post('/api/user/update/$userId', {
      'userUsername': email,
      'userName': name,
    }, authorized: true);
  }

  /// Checks the current password with login, then saves only the new password.
  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final userId = currentUserId;
    final username = _claimFromToken(accessToken, 'username');
    if (userId == null || username == null || username.isEmpty) {
      throw AuthException('You are not logged in.');
    }
    await login(
      username: username,
      password: currentPassword,
    );
    await _post('/api/user/update/$userId', {
      'userPassword': newPassword,
    }, authorized: true);
  }

  static Future<dynamic> addXp(int xpGained) {
    final userId = currentUserId;
    if (userId == null) {
      throw AuthException('You are not logged in.');
    }
    return _post('/api/user/$userId/xp', {
      'xp_gained': xpGained,
    }, authorized: true);
  }

  static Future<dynamic> resetXp() {
    final userId = currentUserId;
    if (userId == null) {
      throw AuthException('You are not logged in.');
    }
    return _post('/api/user/reset-xp/$userId', {}, authorized: true);
  }

  /// Records that the user completed a quiz today. The server increments the
  /// streak once per calendar day and ignores repeat calls that day. Only call
  /// this after a quiz is completed; login, sign-up, and app open must not
  /// count as activity.
  /// Returns the current streak count when the server provides it.
  static Future<int?> recordStreak() async {
    final userId = currentUserId;
    if (userId == null) {
      throw AuthException('You are not logged in.');
    }
    final result = await _post(
      '/api/user/$userId/log-activity',
      {},
      authorized: true,
    );
    int? count;
    if (result is Map && result['streak_count'] is num) {
      count = (result['streak_count'] as num).toInt();
    }
    if (count != null) {
      streakCount.value = count;
    }
    return count;
  }

  static Future<dynamic> restoreStreak() {
    final userId = currentUserId;
    if (userId == null) {
      throw AuthException('You are not logged in.');
    }
    return _post('/api/user/streak/restore/$userId', {}, authorized: true);
  }

  static Future<dynamic> deleteUser() {
    final userId = currentUserId;
    if (userId == null) {
      throw AuthException('You are not logged in.');
    }
    return _post('/api/user/delete/$userId', {}, authorized: true);
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
    return _post('/api/user/forgot-password/send-otp', {'userUsername': email});
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

  static Map<String, dynamic>? _payload(String? token) {
    if (token == null) return null;
    final parts = token.split('.');
    if (parts.length < 2) return null;
    try {
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      if (payload is Map<String, dynamic>) return payload;
      if (payload is Map) return Map<String, dynamic>.from(payload);
    } catch (_) {}
    return null;
  }

  static String? _claimFromToken(String? token, String claim) {
    final value = _payload(token)?[claim];
    if (value == null) return null;
    return value.toString();
  }

  static int? _userIdFromToken(String token) {
    final sub = _payload(token)?['sub'];
    if (sub is num) return sub.toInt();
    if (sub is String) return int.tryParse(sub);
    return null;
  }

  static bool _isExpired(String token) {
    final parts = token.split('.');
    if (parts.length < 2) return true;
    try {
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      if (payload is! Map || payload['exp'] is! num) return false;
      final expiry = DateTime.fromMillisecondsSinceEpoch(
        (payload['exp'] as num).toInt() * 1000,
        isUtc: true,
      );
      return DateTime.now().toUtc().isAfter(expiry);
    } catch (_) {
      return true;
    }
  }

  static Future<dynamic> _post(
    String path,
    Map<String, dynamic> body, {
    bool authorized = false,
  }) async {
    final client = HttpClient()..connectionTimeout = _timeout;
    try {
      final request = await client.postUrl(Uri.parse('$baseUrl$path'));
      request.headers.contentType = ContentType.json;
      if (authorized && accessToken != null) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $accessToken');
      }
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
      throw AuthException(
        'Cannot reach server. Check your internet connection.',
      );
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
