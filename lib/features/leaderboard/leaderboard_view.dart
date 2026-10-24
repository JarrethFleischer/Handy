import 'package:flutter/material.dart';
import 'package:handy/features/leaderboard/leaderboard_controller.dart';
import 'package:handy/services/auth_service.dart';
import 'package:handy/theme/app_colors.dart';

class LeaderboardView extends StatefulWidget {
  const LeaderboardView({this.isActive = false, super.key});

  final bool isActive;

  static const navy = Color(0xFF14304A);
  static const page = Color(0xFFEAF5FF);
  static const header = Color(0xFF9AD5FF);
  static const accent = Color(0xFF67B5FF);
  static const muted = Color(0xFF6B7280);
  static const divider = Color(0xFFEDF1F3);

  static const body = TextStyle(
    fontFamily: 'Inter',
    color: navy,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static const caption = TextStyle(
    fontFamily: 'Inter',
    color: muted,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static const title = TextStyle(
    fontFamily: 'Inter',
    color: navy,
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  @override
  State<LeaderboardView> createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends State<LeaderboardView> {
  static const double _rowHeight = 56;
  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  final _controller = LeaderboardController();

  List<LeaderboardUser> _users = [];
  CurrentUserProfile? _me;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.isActive) _load();
  }

  @override
  void didUpdateWidget(LeaderboardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final userId = AuthService.currentUserId;
    if (userId == null) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load the leaderboard';
        _loading = false;
      });
      return;
    }

    try {
      final results = await Future.wait([
        _controller.fetchLeaderboard(),
        _controller.fetchCurrentUser(userId),
      ]);
      if (!mounted) return;
      setState(() {
        _users = results[0] as List<LeaderboardUser>;
        _me = results[1] as CurrentUserProfile;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load the leaderboard';
        _loading = false;
      });
    }
  }

  String get _today {
    final now = DateTime.now();
    return '${now.day} ${_months[now.month - 1]} ${now.year}';
  }

  int? get _myRank {
    final me = _me;
    if (me == null) return null;
    for (final user in _users) {
      if (user.userID == me.userID) return user.userRank;
    }
    return null;
  }

  /// Ranks shown in the list: always 4 to 10, plus any real ranks beyond 10.
  List<int> get _listRanks {
    final ranks = <int>{for (var r = 4; r <= 10; r++) r};
    for (final user in _users) {
      if (user.userRank > 3) ranks.add(user.userRank);
    }
    return ranks.toList()..sort();
  }

  LeaderboardUser? _userAtRank(int rank) {
    for (final user in _users) {
      if (user.userRank == rank) return user;
    }
    return null;
  }

  Widget _buildList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: LeaderboardView.body),
            TextButton(onPressed: _load, child: const Text('Try again')),
          ],
        ),
      );
    }

    final ranks = _listRanks;
    final myId = _me?.userID;
    return ListView.builder(
      itemExtent: _rowHeight,
      itemCount: ranks.length,
      itemBuilder: (context, index) {
        final rank = ranks[index];
        final user = _userAtRank(rank);
        final showDivider = index < ranks.length - 1;
        if (user == null) {
          return _PlaceholderRow(rank: rank, showDivider: showDivider);
        }
        return _LeaderboardRow(
          rank: rank,
          name: user.userName,
          points: '${user.userXP}',
          isMe: user.userID == myId,
          showDivider: showDivider,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final showMyCard = !_loading && _error == null;

    return Scaffold(
      backgroundColor: LeaderboardView.page,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: LeaderboardView.header,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.elliptical(
                    MediaQuery.of(context).size.width,
                    150,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  const Text('Leaderboard', style: LeaderboardView.title),
                  const SizedBox(height: 2),
                  Text(_today, style: LeaderboardView.body),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _PodiumPlace(
                        user: _userAtRank(2),
                        rank: 2,
                        barHeight: 72,
                        color: LeaderboardView.accent,
                      ),
                      _PodiumPlace(
                        user: _userAtRank(1),
                        rank: 1,
                        barHeight: 100,
                        color: AppColors.yellow,
                      ),
                      _PodiumPlace(
                        user: _userAtRank(3),
                        rank: 3,
                        barHeight: 52,
                        color: AppColors.blueLight,
                      ),
                    ],
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          const _LeaderboardHeader(),
                          Expanded(child: _buildList()),
                        ],
                      ),
                    ),
                  ),
                  if (showMyCard)
                    _MyRankBar(profile: _me, rank: _myRank)
                  else
                    const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PodiumPlace extends StatelessWidget {
  const _PodiumPlace({
    required this.user,
    required this.rank,
    required this.barHeight,
    required this.color,
  });

  final LeaderboardUser? user;
  final int rank;
  final double barHeight;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isFirst = rank == 1;
    final avatarSize = isFirst ? 80.0 : 64.0;
    final badgeText = isFirst ? LeaderboardView.navy : Colors.white;

    return SizedBox(
      width: 100,
      child: Column(
        children: [
          if (isFirst)
            const Icon(
              Icons.workspace_premium,
              color: AppColors.yellowDark,
              size: 28,
            ),
          SizedBox(
            width: avatarSize,
            height: avatarSize + 10,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 3),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/images/profile_pic.png',
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Text(
                      '$rank',
                      style: TextStyle(
                        color: badgeText,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            user?.userName ?? '-',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: LeaderboardView.navy,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/trophy.png', width: 14, height: 14),
              const SizedBox(width: 4),
              Text('${user?.userXP ?? 0}', style: LeaderboardView.body),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: 96,
            height: barHeight,
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Text(
              '$rank',
              style: TextStyle(
                color: badgeText,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardHeader extends StatelessWidget {
  const _LeaderboardHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: LeaderboardView.divider)),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 42,
            child: Text('Rank', style: LeaderboardView.caption),
          ),
          Expanded(child: Text('Name', style: LeaderboardView.caption)),
          Text('Points', style: LeaderboardView.caption),
        ],
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({
    required this.rank,
    required this.name,
    required this.points,
    required this.isMe,
    required this.showDivider,
  });

  final int rank;
  final String name;
  final String points;
  final bool isMe;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: isMe ? LeaderboardView.page : Colors.white,
        border: showDivider
            ? const Border(bottom: BorderSide(color: LeaderboardView.divider))
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 42,
            child: Text('$rank', style: LeaderboardView.body),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/images/profile_pic.png',
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: LeaderboardView.body.copyWith(
                fontWeight: isMe ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          if (isMe) ...[const _YouTag(), const SizedBox(width: 10)],
          Image.asset('assets/images/trophy.png', width: 14, height: 14),
          const SizedBox(width: 4),
          Text(points, style: LeaderboardView.body),
        ],
      ),
    );
  }
}

class _PlaceholderRow extends StatelessWidget {
  const _PlaceholderRow({required this.rank, required this.showDivider});

  final int rank;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: LeaderboardView.divider))
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 42,
            child: Text(
              '$rank',
              style: LeaderboardView.body.copyWith(color: AppColors.gray),
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: LeaderboardView.page,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline,
              size: 18,
              color: LeaderboardView.accent,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              '-',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Inter',
                color: AppColors.gray,
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          Container(
            width: 36,
            height: 10,
            decoration: BoxDecoration(
              color: AppColors.grayLight,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ],
      ),
    );
  }
}

class _YouTag extends StatelessWidget {
  const _YouTag();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: LeaderboardView.accent,
        borderRadius: BorderRadius.all(Radius.circular(6)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Text(
          'YOU',
          style: TextStyle(
            fontFamily: 'Inter',
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _MyRankBar extends StatelessWidget {
  const _MyRankBar({required this.profile, required this.rank});

  final CurrentUserProfile? profile;
  final int? rank;

  @override
  Widget build(BuildContext context) {
    final name = profile?.userName ?? '-';
    final points = profile == null ? 'Score: -' : 'Score: ${profile!.userXP} Pts';
    final rankLabel = rank == null ? '#-' : '#$rank';
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 12, 0, 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A14304A),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: LeaderboardView.accent,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Text(
              rankLabel,
              style: const TextStyle(
                fontFamily: 'Inter',
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/images/profile_pic.png',
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          color: LeaderboardView.navy,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const _YouTag(),
                  ],
                ),
                const SizedBox(height: 2),
                Text(points, style: LeaderboardView.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
