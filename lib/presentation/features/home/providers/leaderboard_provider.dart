import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/remote/services/auth_service.dart';
import '../widgets/leaderboard_section.dart';

class LeaderboardData {
  final int myRank;
  final int myXp;
  final List<LeaderboardEntry> topUsers;

  LeaderboardData({
    required this.myRank,
    required this.myXp,
    required this.topUsers,
  });

  factory LeaderboardData.fromJson(Map<String, dynamic> json, String currentUserName) {
    final myRank = json['my_rank'] as int? ?? 0;
    final myXp = json['my_xp'] as int? ?? 0;
    final topUsersJson = json['top_users'] as List<dynamic>? ?? [];

    final topUsers = topUsersJson.map((e) {
      final user = e as Map<String, dynamic>;
      final name = user['name'] as String? ?? '';
      final xp = user['xp'] as int? ?? 0;
      return LeaderboardEntry(
        rank: topUsersJson.indexOf(e) + 1,
        name: name,
        xp: xp,
        isCurrentUser: name == currentUserName,
      );
    }).toList();

    return LeaderboardData(
      myRank: myRank,
      myXp: myXp,
      topUsers: topUsers,
    );
  }
}

final leaderboardProvider = FutureProvider.family<LeaderboardData, String>((ref, userName) async {
  final service = ref.read(authServiceProvider);
  final data = await service.getLeaderboard(limit: 10);
  return LeaderboardData.fromJson(data, userName);
});
