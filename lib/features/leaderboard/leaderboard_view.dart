import 'package:flutter/material.dart';
import 'package:handy/features/leaderboard/leaderboard_controller.dart';
import 'package:handy/services/auth_service.dart';

class _Medal {
  const _Medal(this.main, this.dark, this.onMain);

  final Color main;
  final Color dark;
  final Color onMain;

  static const gold = _Medal(
    Color(0xFFFFD86B),
    Color(0xFFFFB800),
    Color(0xFF14181B),
  );
  static const silver = _Medal(
    Color(0xFF7CE0FF),
    Color(0xFF22A2F2),
    Color(0xFF14181B),
  );
  static const bronze = _Medal(
    Color(0xFFFFA88A),
    Color(0xFFFF6D3F),
    Color(0xFF14181B),
  );

  static _Medal? forRank(int rank) => switch (rank) {
    1 => gold,
    2 => silver,
    3 => bronze,
    _ => null,
  };
}

class LeaderboardView extends StatefulWidget {
  const LeaderboardView({this.isActive = false, super.key});

  final bool isActive;

  static const Color skyBgTop = Color(0xFFDDF1FF);
  static const Color skyBgBottom = Color(0xFFF3FAFF);
  static const Color inkBlack = Color(0xFF14181B);
  static const Color primaryBlue = Color(0xFF22A2F2);
  static const Color sunnyYellow = Color(0xFFFFD86B);
  static const Color slateText = Color(0xFF57636C);
  static const Color skeletonColor = Color(0xFFD6E6F2);

  static const body = TextStyle(
    fontFamily: 'Inter',
    color: inkBlack,
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  static const caption = TextStyle(
    fontFamily: 'Inter',
    color: slateText,
    fontSize: 11.5,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.4,
  );

  static const title = TextStyle(
    fontFamily: 'Inter',
    color: inkBlack,
    fontSize: 26,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.5,
  );

  @override
  State<LeaderboardView> createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends State<LeaderboardView> {
  static const double _rowHeight = 60;
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

  List<int> get _listRanks {
    return [for (var rank = 4; rank <= 10; rank++) rank];
  }

  LeaderboardUser? _userAtRank(int rank) {
    for (final user in _users) {
      if (user.userRank == rank) return user;
    }
    return null;
  }

  Widget _buildList() {
    if (_loading) {
      return _Shimmer(
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemExtent: _rowHeight,
          itemCount: 8,
          itemBuilder: (context, index) =>
              _SkeletonRow(showDivider: index < 7),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 36,
              color: LeaderboardView.slateText,
            ),
            const SizedBox(height: 8),
            Text(_error!, style: LeaderboardView.body),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _load,
              style: ElevatedButton.styleFrom(
                backgroundColor: LeaderboardView.inkBlack,
                foregroundColor: Colors.white,
              ),
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }

    final ranks = _listRanks;
    final myId = _me?.userID;
    return RefreshIndicator(
      color: LeaderboardView.inkBlack,
      backgroundColor: LeaderboardView.sunnyYellow,
      onRefresh: _load,
      child: ListView.builder(
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showMyCard = !_loading && _error == null;

    return Scaffold(
      backgroundColor: LeaderboardView.skyBgBottom,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    LeaderboardView.skyBgTop,
                    LeaderboardView.skyBgBottom,
                  ],
                ),
              ),
              child: CustomPaint(
                painter: _SubtleDotGridPainter(),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const Text('Leaderboard', style: LeaderboardView.title),
                  const SizedBox(height: 4),
                  // Date Pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: LeaderboardView.inkBlack,
                        width: 1.4,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: LeaderboardView.inkBlack,
                          offset: Offset(0, 2),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 13,
                          color: LeaderboardView.inkBlack,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _today,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            color: LeaderboardView.inkBlack,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Podium (Tighter spacing, Crown on #1, Festive stars)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _PodiumPlace(
                        user: _userAtRank(2),
                        rank: 2,
                        barHeight: 56,
                        loading: _loading,
                      ),
                      const SizedBox(width: 10),
                      _PodiumPlace(
                        user: _userAtRank(1),
                        rank: 1,
                        barHeight: 78,
                        loading: _loading,
                      ),
                      const SizedBox(width: 10),
                      _PodiumPlace(
                        user: _userAtRank(3),
                        rank: 3,
                        barHeight: 40,
                        loading: _loading,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Middle Table (Fixed Corner Clipping)
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: LeaderboardView.inkBlack,
                          width: 2.0,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: LeaderboardView.inkBlack,
                            offset: Offset(0, 6),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Column(
                          children: [
                            const _LeaderboardHeader(),
                            Expanded(child: _buildList()),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Bottom My Rank Bar
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
    required this.loading,
  });

  final LeaderboardUser? user;
  final int rank;
  final double barHeight;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final medal = _Medal.forRank(rank)!;
    final isFirst = rank == 1;
    final avatarSize = isFirst ? 72.0 : 58.0;

    return SizedBox(
      width: 98,
      child: Column(
        children: [
          if (isFirst) ...[
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 14),
                SizedBox(width: 2),
                Icon(Icons.workspace_premium_rounded, color: Color(0xFFFFB800), size: 26),
                SizedBox(width: 2),
                Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 14),
              ],
            ),
            const SizedBox(height: 2),
          ],
          SizedBox(
            width: avatarSize,
            height: avatarSize + 8,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9), // Subtle background for avatar container
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: LeaderboardView.inkBlack,
                      width: 2.2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: LeaderboardView.inkBlack,
                        offset: Offset(0, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0), // Smaller inset padding so image doesn't burst out
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/profile_pic.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: _RankBadge(rank: rank, size: 22),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          if (loading)
            _Shimmer(
              child: Column(
                children: [
                  _bone(width: 54, height: 12),
                  const SizedBox(height: 4),
                  _bone(width: 32, height: 10),
                ],
              ),
            )
          else ...[
            Text(
              user?.userName ?? '-',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                color: LeaderboardView.inkBlack,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: LeaderboardView.inkBlack, width: 1.1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/trophy.png', width: 12, height: 12),
                  const SizedBox(width: 3),
                  Text(
                    '${user?.userXP ?? 0}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      color: LeaderboardView.inkBlack,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 6),
          // Retro 3D Podium Block
          Container(
            width: 86,
            height: barHeight,
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: medal.main,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              border: Border.all(
                color: LeaderboardView.inkBlack,
                width: 1.8,
              ),
              boxShadow: const [
                BoxShadow(
                  color: LeaderboardView.inkBlack,
                  offset: Offset(0, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Text(
              '$rank',
              style: const TextStyle(
                fontFamily: 'Inter',
                color: LeaderboardView.inkBlack,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank, this.size = 24});

  final int rank;
  final double size;

  @override
  Widget build(BuildContext context) {
    final medal = _Medal.forRank(rank);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: medal?.main ?? Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: LeaderboardView.inkBlack,
          width: 1.4,
        ),
      ),
      child: Text(
        '$rank',
        style: TextStyle(
          fontFamily: 'Inter',
          color: LeaderboardView.inkBlack,
          fontSize: size * 0.45,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _LeaderboardHeader extends StatelessWidget {
  const _LeaderboardHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(
          bottom: BorderSide(
            color: LeaderboardView.inkBlack,
            width: 1.8,
          ),
        ),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 44,
            child: Text('RANK', style: LeaderboardView.caption),
          ),
          Expanded(child: Text('NAME', style: LeaderboardView.caption)),
          Text('POINTS', style: LeaderboardView.caption),
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFFFFFBEB) : Colors.white,
        border: Border(
          bottom: showDivider
              ? const BorderSide(
                  color: Color(0xFFE2E8F0),
                  width: 1.2,
                )
              : BorderSide.none,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _RankBadge(rank: rank),
            ),
          ),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
              border: Border.all(
                color: LeaderboardView.inkBlack,
                width: 1.4,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(3.0), // Inset padding for clean fit inside border
              child: ClipOval(
                child: Image.asset(
                  'assets/images/profile_pic.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: LeaderboardView.body.copyWith(
                fontWeight: isMe ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ),
          if (isMe) ...[const _YouTag(), const SizedBox(width: 8)],
          Image.asset('assets/images/trophy.png', width: 14, height: 14),
          const SizedBox(width: 4),
          Text(
            points,
            style: LeaderboardView.body.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
              )
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Opacity(opacity: 0.5, child: _RankBadge(rank: rank)),
            ),
          ),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFCBD5E1),
                width: 1.2,
              ),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              size: 18,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Open spot',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Inter',
                color: Color(0xFF94A3B8),
                fontSize: 13,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(
            '—',
            style: TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow({required this.showDivider});

  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
              )
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _bone(width: 26, height: 26, circle: true),
            ),
          ),
          _bone(width: 34, height: 34, circle: true),
          const SizedBox(width: 10),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _bone(width: 110, height: 12),
            ),
          ),
          _bone(width: 40, height: 12),
        ],
      ),
    );
  }
}

Widget _bone({
  required double width,
  required double height,
  bool circle = false,
}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: LeaderboardView.skeletonColor,
      shape: circle ? BoxShape.circle : BoxShape.rectangle,
      borderRadius: circle ? null : BorderRadius.circular(6),
    ),
  );
}

class _Shimmer extends StatefulWidget {
  const _Shimmer({required this.child});

  final Widget child;

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      child: widget.child,
      builder: (context, child) {
        final t = _anim.value * 3 - 1;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: const [
              LeaderboardView.skeletonColor,
              Colors.white,
              LeaderboardView.skeletonColor,
            ],
            stops: [
              (t - 0.3).clamp(0.0, 1.0),
              t.clamp(0.0, 1.0),
              (t + 0.3).clamp(0.0, 1.0),
            ],
          ).createShader(bounds),
          child: child,
        );
      },
    );
  }
}

class _YouTag extends StatelessWidget {
  const _YouTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: LeaderboardView.sunnyYellow,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: LeaderboardView.inkBlack, width: 1.2),
      ),
      child: const Text(
        'YOU',
        style: TextStyle(
          fontFamily: 'Inter',
          color: LeaderboardView.inkBlack,
          fontSize: 10,
          fontWeight: FontWeight.w900,
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
    final points = profile == null ? '-' : '${profile!.userXP} pts';
    final rankLabel = rank == null ? '#-' : '#$rank';
    final medal = rank == null ? null : _Medal.forRank(rank!);

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 12, 0, 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: LeaderboardView.inkBlack,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: LeaderboardView.inkBlack, width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: LeaderboardView.inkBlack,
            offset: Offset(0, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: medal?.main ?? LeaderboardView.sunnyYellow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white, width: 1.4),
            ),
            child: Text(
              rankLabel,
              style: const TextStyle(
                fontFamily: 'Inter',
                color: LeaderboardView.inkBlack,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.8),
            ),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(3.5), // Inset padding for neat fit
              child: ClipOval(
                child: Image.asset(
                  'assets/images/profile_pic.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
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
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const _YouTag(),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'Your current rank',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Color(0xFF94A3B8),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Image.asset('assets/images/trophy.png', width: 16, height: 16),
          const SizedBox(width: 6),
          Text(
            points,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubtleDotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF22A2F2).withOpacity(0.10)
      ..style = PaintingStyle.fill;

    const spacing = 26.0;
    const radius = 1.6;

    for (double x = 14; x < size.width; x += spacing) {
      for (double y = 14; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}