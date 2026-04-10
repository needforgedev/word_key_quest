import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/theme.dart';
import '../../application/session_provider.dart';
import '../../core/session_manager.dart';

class LevelCompleteScreen extends ConsumerStatefulWidget {
  const LevelCompleteScreen({super.key});

  @override
  ConsumerState<LevelCompleteScreen> createState() =>
      _LevelCompleteScreenState();
}

class _LevelCompleteScreenState extends ConsumerState<LevelCompleteScreen> {
  SessionCompletionResult? _result;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _completeSession();
  }

  Future<void> _completeSession() async {
    try {
      final result = await ref.read(sessionProvider.notifier).completeSession();
      if (mounted) {
        setState(() {
          _result = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.surface,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Stack(
        children: [
          // Celebration radial gradient background
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.3),
                radius: 1.2,
                colors: [
                  Color(0xFFFFF8E1),
                  Color(0xFFFDF6E3),
                  Color(0xFFF8F0DC),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        SizedBox(height: 24),
                        _buildStars(),
                        SizedBox(height: 16),
                        _buildAmazingBadge(),
                        SizedBox(height: 8),
                        Text(
                          _result != null
                              ? '${_result!.totalCorrect}/${_result!.totalAnswered} correct — ${(_result!.accuracy * 100).toInt()}% accuracy!'
                              : 'You found all the missing words!',
                          style: GoogleFonts.lexend(
                            fontSize: 16,
                            color: AppTheme.onSurface.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24),
                        _buildStatsBento(),
                        SizedBox(height: 16),
                        _buildRewardCard(),
                        SizedBox(height: 20),
                        _buildTreasureChest(),
                        SizedBox(height: 24),
                        _buildContinueButton(context),
                        SizedBox(height: 12),
                        _buildReplayButton(context),
                        SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Word Key Quest',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _result?.isDailyQuest == true
                  ? 'Quest Complete'
                  : 'Level ${_result?.session.worldIndex != null ? _result!.session.worldIndex * 10 + _result!.session.levelIndex + 1 : ''} Complete',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStars() {
    final earned = _result?.starsEarned ?? 3;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Icon(
          Icons.star_rounded,
          size: 56,
          color: earned >= 1
              ? AppTheme.secondaryContainer
              : AppTheme.surfaceContainerHigh,
        ),
        SizedBox(width: 4),
        Icon(
          Icons.star_rounded,
          size: 72,
          color: earned >= 2
              ? AppTheme.secondaryContainer
              : AppTheme.surfaceContainerHigh,
        ),
        SizedBox(width: 4),
        Icon(
          Icons.star_rounded,
          size: 56,
          color: earned >= 3
              ? AppTheme.secondaryContainer
              : AppTheme.surfaceContainerHigh,
        ),
      ],
    );
  }

  Widget _buildAmazingBadge() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'AMAZING!',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: AppTheme.onSurface,
            letterSpacing: -1.0,
          ),
        ),
        SizedBox(width: 8),
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppTheme.errorContainer.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.local_fire_department_rounded,
            color: AppTheme.errorContainer,
            size: 28,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsBento() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  offset: Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'WORDS MASTERED',
                  style: GoogleFonts.lexend(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurface.withOpacity(0.5),
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '${_result?.wordsPromoted ?? 0}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  offset: Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'STARS EARNED',
                  style: GoogleFonts.lexend(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurface.withOpacity(0.5),
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 28,
                      color: AppTheme.secondaryContainer,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${(_result?.starsEarned ?? 0) * 10}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRewardCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.secondaryContainer,
          width: 2,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
        // Dashed border effect simulated with a dashed-like appearance
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.secondaryContainer.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.vpn_key_rounded,
              color: AppTheme.secondary,
              size: 28,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SPECIAL REWARD',
                  style: GoogleFonts.lexend(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurface.withOpacity(0.5),
                    letterSpacing: 1.0,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${_result?.keysEarned ?? 1} Golden Key${(_result?.keysEarned ?? 1) > 1 ? 's' : ''}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.auto_awesome_rounded,
            color: AppTheme.secondaryContainer,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildTreasureChest() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Golden glow behind the chest
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppTheme.secondaryContainer.withOpacity(0.4),
                AppTheme.secondaryContainer.withOpacity(0.1),
                Colors.transparent,
              ],
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            'assets/images/image_9a9dbe13.jpg',
            width: 180,
            height: 180,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: AppTheme.secondaryContainer.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.inventory_2_rounded,
                size: 80,
                color: AppTheme.secondaryContainer,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryDim,
            offset: Offset(0, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: () => context.go('/home'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'CONTINUE ADVENTURE',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReplayButton(BuildContext context) {
    return TextButton(
      onPressed: () => context.go('/level_intro'),
      child: Text(
        'Replay Level',
        style: GoogleFonts.lexend(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: Offset(0, -2),
            blurRadius: 12,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                icon: Icons.home_rounded,
                label: 'Home',
                onTap: () => context.go('/home'),
              ),
              _buildNavItem(
                context,
                icon: Icons.map_rounded,
                label: 'Map',
                onTap: () => context.push('/map'),
              ),
              _buildNavItem(
                context,
                icon: Icons.inventory_2_rounded,
                label: 'Vault',
                onTap: () => context.push('/vault'),
              ),
              _buildNavItem(
                context,
                icon: Icons.card_giftcard_rounded,
                label: 'Rewards',
                onTap: () => context.push('/rewards'),
              ),
              _buildNavItem(
                context,
                icon: Icons.supervisor_account_rounded,
                label: 'Parent',
                onTap: () => context.push('/settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color:
                  isActive ? Colors.white : AppTheme.onSurface.withOpacity(0.5),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.lexend(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive
                    ? Colors.white
                    : AppTheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
