import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:handy/models/auth_exception.dart';

class AuthService {
  static const String _baseUrlKey = 'api_base_url';
  static const String _tokenKey = 'auth_token';

  final String baseUrl;
  final http.Client? client;

  AuthService({required this.baseUrl, this.client}) {
    if (baseUrl.isEmpty) {
      throw ArgumentError('baseUrl must not be empty');
    }
  }

  static Future<AuthService> create() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString(_baseUrlKey);
    final resolvedUrl = savedUrl ?? 'http://10.0.2.2:8080';
    return AuthService(baseUrl: resolvedUrl);
  }

  static Future<void> saveBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baseUrlKey, url);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$baseUrl$path');

    final response = await client != null
        ? await client!.post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
        : await http.post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    }

    final message = data['message'] as String? ??
        data['error'] as String? ??
        'An unknown error occurred';

    _throwFromStatus(response.statusCode, message, data);
    throw AuthException(message);
  }

  void _throwFromStatus(
    int statusCode,
    String message,
    Map<String, dynamic> data,
  ) {
    switch (statusCode) {
      case 400:
        if (message.toLowerCase().contains('password')) {
          throw AuthException(message);
        }
        if (message.toLowerCase().contains('email') ||
            message.toLowerCase().contains('already')) {
          throw AuthException(message);
        }
        throw AuthException(message);
      case 401:
        if (message.toLowerCase().contains('password') ||
            message.toLowerCase().contains('credential') ||
            message.toLowerCase().contains('invalid')) {
          throw AuthException(message);
        }
        throw AuthException(message);
      case 404:
        throw AuthException('User not found. Please check your email and try again.');
      case 409:
        throw AuthException(message);
      case 422:
        throw AuthException(message);
      case 500:
        throw AuthException('Server error. Please try again later.');
      default:
        throw AuthException(message);
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String dateOfBirth,
    required String phone,
    required String password,
  }) async {
    final data = await _post('/auth/signup', {
      'name': name,
      'email': email,
      'dateOfBirth': dateOfBirth,
      'phone': phone,
      'password': password,
    });

    if (data['token'] != null) {
      await saveToken(data['token'] as String);
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final data = await _post('/auth/login', {
      'email': email,
      'password': password,
    });

    if (data['token'] != null) {
      await saveToken(data['token'] as String);
    }
  }

  Future<void> logout() async {
    await clearToken();
  }
}
