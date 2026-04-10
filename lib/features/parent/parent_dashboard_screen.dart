import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/theme.dart';
import '../../application/player_provider.dart';
import '../../application/mastery_provider.dart';
import '../../application/settings_provider.dart';

class ParentDashboardScreen extends ConsumerWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);
    final name = profile?.name ?? 'Explorer';
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                children: [
                  SizedBox(height: 16),
                  _buildHeroCard(context, name),
                  SizedBox(height: 16),
                  _buildQuickTasksCard(context),
                  SizedBox(height: 20),
                  _buildStatsRow(context, ref),
                  SizedBox(height: 24),
                  _buildVocabularyMasterySection(context),
                  SizedBox(height: 24),
                  _buildGameSettingsSection(context, settings),
                  SizedBox(height: 24),
                  _buildNewestKeysSection(context),
                  SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () => context.push('/vault'),
                      child: Text(
                        'View All Vocabulary',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildTipCard(context),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(Icons.arrow_back_rounded, color: AppTheme.onSurface),
          ),
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
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.secondaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Parent Mode',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppTheme.secondary,
              ),
            ),
          ),
          SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, String name) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryDim,
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.auto_stories_rounded,
              size: 120,
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$name's Journey",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Your child has mastered 12 new words this week! Keep the momentum going with custom word sets.',
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.85),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTasksCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Tasks',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Master daily progress',
            style: GoogleFonts.lexend(
              fontSize: 13,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickTaskButton(
                  icon: Icons.download_rounded,
                  label: 'Export Progress',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildQuickTaskButton(
                  icon: Icons.palette_rounded,
                  label: 'Change Theme',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTaskButton({required IconData icon, required String label}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: Colors.white),
          SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, WidgetRef ref) {
    final totalWords = ref.watch(introducedCountProvider).when(
          data: (c) => '$c',
          loading: () => '...',
          error: (_, __) => '--',
        );
    final accuracy = ref.watch(overallAccuracyProvider).when(
          data: (a) => '${(a * 100).toInt()}%',
          loading: () => '...',
          error: (_, __) => '--',
        );

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatColumn(context, totalWords, 'TOTAL WORDS\nLEARNED'),
          Container(width: 1, height: 50, color: AppTheme.surfaceContainerHigh),
          _buildStatColumn(context, accuracy, 'ACCURACY\nRATE'),
          Container(width: 1, height: 50, color: AppTheme.surfaceContainerHigh),
          _buildStatColumn(context, '20 mins', 'TIME\nTODAY'),
        ],
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppTheme.onSurface.withOpacity(0.5),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVocabularyMasterySection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vocabulary Mastery',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 20),
          _buildMasteryBar('Nouns & Objects', 0.92, AppTheme.primary),
          SizedBox(height: 16),
          _buildMasteryBar('Action Verbs', 0.64, AppTheme.secondaryContainer),
          SizedBox(height: 16),
          _buildMasteryBar('Descriptive Adjectives', 0.41, const Color(0xFFFF9800)),
        ],
      ),
    );
  }

  Widget _buildMasteryBar(String label, double progress, Color color) {
    final percent = (progress * 100).toInt();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.lexend(
                fontSize: 14,
                color: AppTheme.onSurface,
              ),
            ),
            Text(
              '$percent%',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.onSurface,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: AppTheme.surfaceContainerHigh,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildGameSettingsSection(BuildContext context, AppSettings settings) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Game Settings',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Difficulty Level',
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  color: AppTheme.onSurface,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  settings.difficulty.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Divider(color: AppTheme.surfaceContainerHigh),
          SizedBox(height: 12),
          Row(
            children: [
              _buildToggleIcon(Icons.volume_up_rounded, 'Audio Cues', settings.audioCues),
              SizedBox(width: 24),
              _buildToggleIcon(Icons.visibility_rounded, 'Visual Cues', settings.visualCues),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleIcon(IconData icon, String label, bool enabled) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: enabled
                ? AppTheme.primaryContainer.withOpacity(0.3)
                : AppTheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: enabled ? AppTheme.primary : AppTheme.onSurface.withOpacity(0.4),
          ),
        ),
        SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.lexend(
            fontSize: 13,
            color: AppTheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildNewestKeysSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Newest Keys Found',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 16),
          _buildWordAchievement('Magnificent', '2 hours ago', Icons.vpn_key_rounded),
          Divider(color: AppTheme.surfaceContainerHigh, height: 24),
          _buildWordAchievement('Crystal', '5 hours ago', Icons.vpn_key_rounded),
          Divider(color: AppTheme.surfaceContainerHigh, height: 24),
          _buildWordAchievement('Lush', 'Yesterday', Icons.vpn_key_rounded),
        ],
      ),
    );
  }

  Widget _buildWordAchievement(String word, String timeAgo, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 22, color: AppTheme.primary),
        ),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                word,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 2),
              Text(
                timeAgo,
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  color: AppTheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.check_circle_rounded,
          color: AppTheme.primary,
          size: 22,
        ),
      ],
    );
  }

  Widget _buildTipCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.secondaryContainer.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.secondaryContainer.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.secondaryContainer.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lightbulb_rounded,
              size: 22,
              color: AppTheme.secondary,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need a tip?',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Try reviewing words together at bedtime for better retention!',
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    color: AppTheme.onSurface.withOpacity(0.6),
                    height: 1.4,
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
