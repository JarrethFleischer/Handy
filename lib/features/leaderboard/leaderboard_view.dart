import 'package:flutter/material.dart';
import 'package:handy/features/leaderboard/leaderboard_controller.dart';
import 'package:handy/theme/app_colors.dart';

class LeaderboardView extends StatefulWidget {
  const LeaderboardView({super.key});

  static const primaryText = Color(0xFF14181B);
  static const card = Color(0xFFFFFFFF);

  static const body = TextStyle(
    fontFamily: 'Inter',
    color: primaryText,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const title = TextStyle(
    fontFamily: 'Inter',
    color: primaryText,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  @override
  State<LeaderboardView> createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends State<LeaderboardView> {
  final _controller = LeaderboardController();

  List<LeaderboardUser> _users = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final users = await _controller.fetchLeaderboard();
      if (!mounted) return;
      setState(() {
        _users = users;
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

    return ListView.separated(
      itemCount: 7,
      separatorBuilder: (context, index) =>
          const Divider(color: AppColors.gray, height: 1, thickness: 0.5),
      itemBuilder: (context, index) {
        final rank = index + 4;
        final entry = _userAtRank(rank);
        return _LeaderboardRow(
          rank: rank,
          name: entry?.userName ?? '-',
          points: entry == null ? '-' : '${entry.userXP}',
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
            opacity: 0.5,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            top: true,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          const Text(
                            'Leaderboard',
                            style: LeaderboardView.title,
                          ),
                          Text('18 October 2026', style: LeaderboardView.body),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 30, 0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        _PodiumPlace(
                          user: _userAtRank(2),
                          rank: 2,
                          barHeight: 70,
                          color: const Color(0xFFAAA9AD),
                        ),
                        _PodiumPlace(
                          user: _userAtRank(1),
                          rank: 1,
                          barHeight: 100,
                          color: const Color(0xFFFFD700),
                        ),
                        _PodiumPlace(
                          user: _userAtRank(3),
                          rank: 3,
                          barHeight: 50,
                          color: const Color(0xFFCD7F32),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
                      decoration: BoxDecoration(
                        color: LeaderboardView.card,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.gray, width: 0.5),
                      ),
                      child: Column(
                        children: [
                          const _LeaderboardHeader(),
                          const Divider(
                            color: AppColors.gray,
                            height: 1,
                            thickness: 0.5,
                          ),
                          Expanded(child: _buildList()),
                        ],
                      ),
                    ),
                  ),
                  const _MyRankBar(),
                ],
              ),
            ),
          ),
        ),
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
    return Column(
      children: [
        SizedBox(
          width: 78,
          height: rank == 1 ? 92 : 78,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: color, width: 1),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/images/profile_pic.png',
                  fit: BoxFit.fill,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user?.userName ?? '-',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        Row(
          children: [
            Image.asset('assets/images/trophy.png', width: 14, height: 14),
            const SizedBox(width: 4),
            Text('${user?.userXP ?? 0}', style: LeaderboardView.body),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: 100,
          height: barHeight,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            color: color,
          ),
        ),
      ],
    );
  }
}

class _LeaderboardHeader extends StatelessWidget {
  const _LeaderboardHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        children: [
          SizedBox(width: 48, child: Text('Rank', style: LeaderboardView.body)),
          Expanded(child: Text('Name', style: LeaderboardView.body)),
          Text('Points', style: LeaderboardView.body),
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
  });

  final int rank;
  final String name;
  final String points;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
      child: Row(
        children: [
          SizedBox(
            width: 42,
            child: Text(
              '$rank',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(shape: BoxShape.circle),
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
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Image.asset('assets/images/trophy.png', width: 14, height: 14),
              SizedBox(width: 4),
              Text(
                points,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MyRankBar extends StatelessWidget {
  const _MyRankBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 12, 0, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
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
              color: AppColors.blueLight,
              shape: BoxShape.circle,
            ),
            child: const Text(
              '#1',
              style: TextStyle(
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
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gray, width: 0.5),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/images/profile_pic.png',
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Zainal',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: LeaderboardView.primaryText,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(width: 6),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.blueLight,
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
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
                    ),
                  ],
                ),
                SizedBox(height: 2),
                Text(
                  '169 Points',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
