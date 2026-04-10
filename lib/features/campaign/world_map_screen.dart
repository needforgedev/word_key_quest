import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/theme.dart';
import '../../application/campaign_provider.dart';
import '../../application/player_provider.dart';
import '../../application/theme_provider.dart';
import '../../data/models/player_profile.dart';

class WorldMapScreen extends ConsumerStatefulWidget {
  const WorldMapScreen({super.key});

  @override
  ConsumerState<WorldMapScreen> createState() => _WorldMapScreenState();
}

class _WorldMapScreenState extends ConsumerState<WorldMapScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    // Auto-scroll to the active level after the frame renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToActiveLevel();
    });
  }

  void _scrollToActiveLevel() {
    if (!_scrollController.hasClients) return;
    // Scroll to the bottom where the active level node is
    // (map renders top=locked future, bottom=current active)
    final maxScroll = _scrollController.position.maxScrollExtent;
    _scrollController.animateTo(
      maxScroll,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Determine the status of a level node given world and level indices.
  _LevelStatus _levelStatus(int worldIndex, int levelIndex) {
    final notifier = ref.read(campaignProvider.notifier);
    if (notifier.isLevelCompleted(worldIndex, levelIndex)) {
      return _LevelStatus.completed;
    }
    if (notifier.isLevelUnlocked(worldIndex, levelIndex)) {
      return _LevelStatus.active;
    }
    return _LevelStatus.locked;
  }

  /// Whether this level is the player's current active level.
  bool _isCurrentLevel(int worldIndex, int levelIndex) {
    final profile = ref.read(currentProfileProvider);
    if (profile == null) return false;
    return worldIndex == profile.currentWorld &&
        levelIndex == profile.currentLevel;
  }

  @override
  Widget build(BuildContext context) {
    final campaign = ref.watch(campaignProvider);
    final profile = ref.watch(currentProfileProvider);

    final currentWorldName = ref.watch(themedWorldNameProvider(campaign.currentWorldIndex));
    final completedCount = campaign.currentWorldLevels.isEmpty
        ? 0
        : campaign.currentLevelIndex;
    final totalLevels = campaign.currentWorldLevels.isEmpty
        ? 10
        : campaign.currentWorldLevels.length;

    // Build the next world info (one after current).
    final nextWorldIndex = campaign.currentWorldIndex + 1;
    final nextWorld = campaign.worlds.length > nextWorldIndex
        ? campaign.worlds[nextWorldIndex]
        : null;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context, profile),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    _buildBiomeSection(
                      context,
                      title: nextWorld != null ? ref.watch(themedWorldNameProvider(nextWorldIndex)) : 'Next World',
                      subtitle: nextWorld != null
                          ? '${nextWorld.levelCount} levels \u2022 locked'
                          : 'locked',
                      iconData: Icons.lock_rounded,
                      iconColor: Colors.grey.shade400,
                      bgColor: Colors.grey.shade200,
                      isLocked: true,
                    ),
                    const SizedBox(height: 8),
                    _buildDashedPathConnector(),
                    const SizedBox(height: 8),
                    _buildBiomeSection(
                      context,
                      title: currentWorldName,
                      subtitle: '$totalLevels levels \u2022 $completedCount complete',
                      iconData: Icons.park_rounded,
                      iconColor: AppTheme.primary,
                      bgColor: AppTheme.primaryContainer.withValues(alpha: 0.3),
                      isLocked: false,
                    ),
                    const SizedBox(height: 24),
                    _buildLevelMap(context, campaign),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, PlayerProfile? profile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.arrow_back_rounded, color: AppTheme.onSurface, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Word Key Quest',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.onSurface,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.secondaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star_rounded, color: AppTheme.secondary, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${profile?.stars ?? 0}',
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBiomeSection(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData iconData,
    required Color iconColor,
    required Color bgColor,
    required bool isLocked,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: isLocked
            ? Border.all(color: Colors.grey.shade300, width: 1)
            : Border.all(color: AppTheme.primaryContainer, width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isLocked ? Icons.lock_rounded : iconData,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isLocked ? Colors.grey : AppTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.lexend(
                    fontSize: 13,
                    color: isLocked ? Colors.grey : AppTheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          if (!isLocked)
            Icon(Icons.chevron_right_rounded, color: AppTheme.primary, size: 24),
        ],
      ),
    );
  }

  Widget _buildDashedPathConnector() {
    return SizedBox(
      height: 48,
      width: 40,
      child: CustomPaint(
        painter: _DashedLinePainter(
          color: Colors.grey.shade400,
          dashWidth: 4,
          dashGap: 4,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildLevelMap(BuildContext context, CampaignState campaign) {
    final worldIndex = campaign.currentWorldIndex;
    final levelCount = campaign.currentWorldLevels.isNotEmpty
        ? campaign.currentWorldLevels.length
        : 10;

    // Horizontal offsets for visual interest
    final offsets = <double>[0, 30, -20, 40, -10, 25, -30, 15, -5, 35];

    return Stack(
      children: [
        // Background tree images
        Positioned(
          right: -20,
          top: 60,
          child: Opacity(
            opacity: 0.15,
            child: Image.asset(
              'assets/images/image_1c0642fb.jpg',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
              errorBuilder: (_, e, s) => const SizedBox.shrink(),
            ),
          ),
        ),
        Positioned(
          left: -10,
          top: 400,
          child: Opacity(
            opacity: 0.12,
            child: Image.asset(
              'assets/images/image_0a13f689.jpg',
              width: 100,
              height: 100,
              fit: BoxFit.contain,
              errorBuilder: (_, e, s) => const SizedBox.shrink(),
            ),
          ),
        ),
        // Level nodes (bottom to top: level 1 at bottom, level 10 at top)
        Column(
          children: List.generate(levelCount, (index) {
            final reversedIndex = levelCount - 1 - index;
            final levelIndex = reversedIndex;
            final status = _levelStatus(worldIndex, levelIndex);
            final isCurrent = _isCurrentLevel(worldIndex, levelIndex);
            final offset = offsets[reversedIndex % offsets.length];

            // For path coloring, check the level below (reversedIndex + 1)
            final bool pathCompleted;
            if (index > 0) {
              final prevReversedIndex = reversedIndex + 1;
              final prevStatus = _levelStatus(worldIndex, prevReversedIndex);
              pathCompleted = status == _LevelStatus.completed ||
                  prevStatus == _LevelStatus.completed;
            } else {
              pathCompleted = false;
            }

            return Column(
              children: [
                if (index > 0)
                  _buildCurvedPath(
                    fromOffset: offsets[(reversedIndex + 1) % offsets.length],
                    toOffset: offset,
                    isCompleted: pathCompleted,
                  ),
                Transform.translate(
                  offset: Offset(offset, 0),
                  child: _buildLevelNode(
                    context,
                    levelNumber: levelIndex + 1,
                    status: isCurrent && status != _LevelStatus.completed
                        ? _LevelStatus.active
                        : status,
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCurvedPath({
    required double fromOffset,
    required double toOffset,
    required bool isCompleted,
  }) {
    return SizedBox(
      height: 40,
      width: double.infinity,
      child: CustomPaint(
        painter: _CurvedPathPainter(
          fromOffset: fromOffset,
          toOffset: toOffset,
          color: isCompleted ? AppTheme.primaryContainer : Colors.grey.shade300,
          strokeWidth: 3,
        ),
      ),
    );
  }

  Widget _buildLevelNode(
    BuildContext context, {
    required int levelNumber,
    required _LevelStatus status,
  }) {
    switch (status) {
      case _LevelStatus.completed:
        return _buildCompletedNode(levelNumber);
      case _LevelStatus.active:
        return _buildActiveNode(context, levelNumber);
      case _LevelStatus.locked:
        return _buildLockedNode(levelNumber);
    }
  }

  Widget _buildCompletedNode(int number) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppTheme.primaryContainer,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryContainer.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(Icons.check_rounded, color: Colors.white, size: 26),
      ),
    );
  }

  Widget _buildActiveNode(BuildContext context, int number) {
    return Column(
      children: [
        // Floating tooltip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Level $number',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => context.push('/level_intro'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'ENTER LEVEL',
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Triangle pointer
        CustomPaint(
          size: const Size(16, 8),
          painter: _TrianglePainter(color: AppTheme.surfaceContainerLowest),
        ),
        const SizedBox(height: 4),
        // Pulsing node
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            final pulseValue = _pulseAnimation.value;
            return Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primaryContainer.withValues(alpha: 0.5 + pulseValue * 0.5),
                  width: 3 + pulseValue * 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryContainer.withValues(alpha: 0.3 + pulseValue * 0.2),
                    blurRadius: 12 + pulseValue * 6,
                    spreadRadius: pulseValue * 3,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLockedNode(int number) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(Icons.lock_rounded, color: Colors.grey.shade500, size: 22),
      ),
    );
  }
}

// Data models
enum _LevelStatus { completed, active, locked }

// Custom painters
class _DashedLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashGap;
  final double strokeWidth;

  _DashedLinePainter({
    required this.color,
    required this.dashWidth,
    required this.dashGap,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double startY = 0;
    final centerX = size.width / 2;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(centerX, startY),
        Offset(centerX, min(startY + dashWidth, size.height)),
        paint,
      );
      startY += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CurvedPathPainter extends CustomPainter {
  final double fromOffset;
  final double toOffset;
  final Color color;
  final double strokeWidth;

  _CurvedPathPainter({
    required this.fromOffset,
    required this.toOffset,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final centerX = size.width / 2;
    final path = Path();
    path.moveTo(centerX + fromOffset, 0);
    path.quadraticBezierTo(
      centerX + (fromOffset + toOffset) / 2,
      size.height / 2,
      centerX + toOffset,
      size.height,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
