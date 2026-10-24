import 'dart:convert';

import 'package:handy/core/config/api_config.dart';
import 'package:handy/services/auth_service.dart';
import 'package:http/http.dart' as http;

class LeaderboardUser {
  const LeaderboardUser({
    required this.userRank,
    required this.userID,
    required this.userName,
    required this.userLevel,
    required this.userXP,
    required this.userStreakCount,
  });

  final int userRank;
  final int userID;
  final String userName;
  final int userLevel;
  final int userXP;
  final int userStreakCount;

  factory LeaderboardUser.fromJson(Map<String, dynamic> json) {
    return LeaderboardUser(
      userRank: (json['userRank'] as num).toInt(),
      userID: (json['userID'] as num).toInt(),
      userName: json['userName'] as String,
      userLevel: (json['userLevel'] as num).toInt(),
      userXP: (json['userXP'] as num).toInt(),
      userStreakCount: (json['userStreakCount'] as num).toInt(),
    );
  }
}

class CurrentUserProfile {
  const CurrentUserProfile({
    required this.userID,
    required this.userName,
    required this.userUsername,
    required this.userXP,
    required this.userStreakCount,
  });

  final int userID;
  final String userName;
  final String userUsername;
  final int userXP;
  final int userStreakCount;

  factory CurrentUserProfile.fromJson(Map<String, dynamic> json) {
    final details = json['details'] as Map<String, dynamic>? ?? {};
    return CurrentUserProfile(
      userID: (json['userID'] as num).toInt(),
      userName: json['userName'] as String,
      userUsername: json['userUsername'] as String? ?? '',
      userXP: (details['userDetailsXP'] as num?)?.toInt() ?? 0,
      userStreakCount: (details['userDetailsStreakCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class LeaderboardController {
  Future<CurrentUserProfile> fetchCurrentUser(int userId) async {
    final token = AuthService.accessToken;
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/user/$userId'),
      headers: token == null ? null : {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('User request failed (${response.statusCode})');
    }

    return CurrentUserProfile.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<List<LeaderboardUser>> fetchLeaderboard() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/user/leaderboard'),
    );

    if (response.statusCode != 200) {
      throw Exception('Leaderboard request failed (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    final users = data
        .map((item) => LeaderboardUser.fromJson(item as Map<String, dynamic>))
        .toList();
    users.sort((a, b) => a.userRank.compareTo(b.userRank));
    return users;
  }
}
