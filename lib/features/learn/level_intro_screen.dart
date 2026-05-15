import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/theme.dart';
import '../../application/player_provider.dart';
import '../../application/session_provider.dart';
import '../../application/theme_provider.dart';

class LevelIntroScreen extends ConsumerStatefulWidget {
  const LevelIntroScreen({super.key});

  @override
  ConsumerState<LevelIntroScreen> createState() => _LevelIntroScreenState();
}

class _LevelIntroScreenState extends ConsumerState<LevelIntroScreen> {
  @override
  void initState() {
    super.initState();
    // Start the session immediately so the intro can show real word counts.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final p = ref.read(currentProfileProvider);
      if (p == null || !mounted) return;
      // Abandon any prior session, then start fresh for the current level.
      ref.read(sessionProvider.notifier).abandonSession();
      await ref
          .read(sessionProvider.notifier)
          .startLevel(p.currentWorld, p.currentLevel);
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentProfileProvider);
    final levelNum = (profile?.globalLevel ?? 1);
    final worldName =
        ref.watch(themedWorldNameProvider(profile?.currentWorld ?? 0));
    final sessionState = ref.watch(sessionProvider);
    final session = sessionState.session;
    final newWordCount = session?.newWordIds.length;
    final reviewWordCount = session?.reviewWordIds.length;
    final sessionReady = session != null;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    SizedBox(height: 16),
                    _buildLevelBadge(levelNum),
                    SizedBox(height: 16),
                    Text(
                      worldName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    _buildSpeechBubble(),
                    SizedBox(height: 20),
                    _buildOwlGuide(),
                    SizedBox(height: 32),
                    _buildMissionBriefSection(
                      context,
                      newWordCount: newWordCount,
                      reviewWordCount: reviewWordCount,
                    ),
                    SizedBox(height: 24),
                    _buildPotentialRewards(),
                    SizedBox(height: 32),
                    _buildStartButton(context, ref, enabled: sessionReady),
                    SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () =>
                context.canPop() ? context.pop() : context.go('/home'),
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
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Vocoro',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.onSurface,
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.star_rounded, color: AppTheme.secondary, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelBadge(int levelNum) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'LEVEL $levelNum',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: AppTheme.secondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSpeechBubble() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.surfaceContainerHigh,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Welcome to the Whisper Wood! The trees here speak in ancient words. Can you help me collect the hidden keys?',
            style: GoogleFonts.lexend(
              fontSize: 15,
              fontStyle: FontStyle.italic,
              color: AppTheme.onSurface.withValues(alpha: 0.8),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOwlGuide() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: AppTheme.primaryDim,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryDim.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Image.asset(
            'assets/images/vocoro_mascot.png',
            fit: BoxFit.cover,
            errorBuilder: (_, e, s) => Icon(
              Icons.emoji_nature_rounded,
              color: AppTheme.primaryContainer,
              size: 54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMissionBriefSection(
    BuildContext context, {
    int? newWordCount,
    int? reviewWordCount,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.surfaceContainerHigh, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Text(
              'Mission Brief',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.onSurface,
              ),
            ),
          ),
          Divider(color: AppTheme.surfaceContainerHigh, height: 1),
          _buildMissionRow(
            icon: Icons.auto_awesome_rounded,
            iconColor: AppTheme.primary,
            label: 'New Words',
            value: newWordCount?.toString() ?? '…',
            showChevron: true,
          ),
          Divider(color: AppTheme.surfaceContainerHigh, height: 1, indent: 20, endIndent: 20),
          _buildMissionRow(
            icon: Icons.refresh_rounded,
            iconColor: AppTheme.secondary,
            label: 'Review Words',
            value: reviewWordCount?.toString() ?? '…',
            showChevron: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMissionRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    bool showChevron = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.lexend(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppTheme.onSurface,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurface,
            ),
          ),
          if (showChevron) ...[
            SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, color: AppTheme.onSurface.withValues(alpha: 0.4), size: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildPotentialRewards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Potential Rewards',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurface,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(child: _buildRewardBadge(Icons.star_rounded, '80', AppTheme.secondaryContainer, AppTheme.secondary)),
            SizedBox(width: 12),
            Expanded(child: _buildRewardBadge(Icons.vpn_key_rounded, 'x1', AppTheme.primaryContainer.withValues(alpha: 0.4), AppTheme.primary)),
            SizedBox(width: 12),
            Expanded(child: _buildRewardBadge(Icons.bolt_rounded, 'x66', AppTheme.surfaceContainerLow, AppTheme.onSurface)),
          ],
        ),
      ],
    );
  }

  Widget _buildRewardBadge(IconData icon, String label, Color bgColor, Color iconColor) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceContainerHigh, width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 28),
          SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton(BuildContext context, WidgetRef ref,
      {bool enabled = true}) {
    return GestureDetector(
      onTap: enabled
          ? () {
              // Session was already started in initState; just navigate.
              context.push('/learn_card');
            }
          : null,
      child: Container(
        width: double.infinity,
        height: 64,
        decoration: BoxDecoration(
          color: enabled ? AppTheme.primary : AppTheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(24),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppTheme.primaryDim,
                    offset: Offset(0, 5),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            enabled ? 'START LEVEL' : 'Loading…',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: enabled
                  ? Colors.white
                  : AppTheme.onSurface.withValues(alpha: 0.5),
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}
