import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/theme.dart';
import '../../application/player_provider.dart';
import '../../application/mastery_provider.dart';
import '../../application/review_provider.dart';
import '../../application/theme_provider.dart';
import '../../data/models/models.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  late final List<AnimationController> _cloudControllers;
  late final List<Animation<double>> _cloudAnimations;

  static const int _cloudCount = 5;

  @override
  void initState() {
    super.initState();
    _cloudControllers = List.generate(_cloudCount, (i) {
      return AnimationController(
        vsync: this,
        duration: Duration(seconds: 20 + i * 8),
      )..repeat();
    });
    _cloudAnimations = _cloudControllers.map((c) {
      return Tween<double>(begin: -0.2, end: 1.2).animate(c);
    }).toList();
  }

  @override
  void dispose() {
    for (final c in _cloudControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Storybook gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF66B6FF), Color(0xFFFDF6E3)],
              ),
            ),
          ),
          // Floating animated clouds
          ..._buildClouds(),
          // Main content
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    children: [
                      SizedBox(height: 16),
                      _buildGreeting(context),
                      SizedBox(height: 24),
                      _buildHeroCard(context),
                      SizedBox(height: 16),
                      _buildSecondaryCards(context),
                      SizedBox(height: 24),
                      _buildProgressSection(context),
                      SizedBox(height: 24),
                    ],
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

  List<Widget> _buildClouds() {
    const cloudSizes = [48.0, 64.0, 36.0, 56.0, 40.0];
    const cloudTops = [0.08, 0.18, 0.05, 0.25, 0.12];
    const cloudOpacities = [0.3, 0.5, 0.4, 0.6, 0.35];

    return List.generate(_cloudCount, (i) {
      return AnimatedBuilder(
        animation: _cloudAnimations[i],
        builder: (context, child) {
          return Positioned(
            top: MediaQuery.of(context).size.height * cloudTops[i],
            left: MediaQuery.of(context).size.width * _cloudAnimations[i].value -
                cloudSizes[i],
            child: Opacity(
              opacity: cloudOpacities[i],
              child: Icon(
                Icons.cloud,
                size: cloudSizes[i],
                color: Colors.white,
              ),
            ),
          );
        },
      );
    });
  }

  // Helper to get profile data with fallback
  PlayerProfile get _profile =>
      ref.watch(currentProfileProvider) ??
      PlayerProfile(id: 'temp', name: 'Explorer', ageBand: 8);

  Widget _buildTopBar(BuildContext context) {
    final profile = _profile;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
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
          // Avatar with level badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/image_3e7b11de.jpg',
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(Icons.person, color: AppTheme.primary),
                  ),
                ),
              ),
              Positioned(
                bottom: -4,
                right: -8,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'LV. ${profile.globalLevel}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 16),
          // App name
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
          // Stars counter pill
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.secondaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star_rounded,
                  size: 18,
                  color: AppTheme.secondaryContainer,
                ),
                SizedBox(width: 4),
                Text(
                  '${profile.stars}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          // Keys counter pill
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.vpn_key_rounded,
                  size: 18,
                  color: AppTheme.primary,
                ),
                SizedBox(width: 4),
                Text(
                  '${profile.keys}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, ${_profile.name.isNotEmpty ? _profile.name : 'Explorer'}!',
            style: GoogleFonts.lexend(
              fontSize: 16,
              color: AppTheme.onSurface.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Ready to play?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.secondaryContainer.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_fire_department_rounded,
                  size: 18,
                  color: Colors.orange,
                ),
                SizedBox(width: 6),
                Text(
                  '${_profile.streakCount} days',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/map'),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryDim,
              offset: Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: Image.asset(
                'assets/images/image_c286fd40.jpg',
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 160,
                  color: AppTheme.primaryDim,
                  child: Center(
                    child: Icon(
                      Icons.landscape_rounded,
                      size: 64,
                      color: AppTheme.primaryContainer,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Builder(builder: (context) {
                    final worldName = ref.watch(themedWorldNameProvider(_profile.currentWorld));
                    return Text(
                      'WORLD ${_profile.currentWorld + 1}: ${worldName.toUpperCase()}',
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryContainer,
                        letterSpacing: 1.0,
                      ),
                    );
                  }),
                  SizedBox(height: 6),
                  Text(
                    'Continue Journey',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 12),
                  // Progress dots
                  Row(
                    children: [
                      ...List.generate(
                        10,
                        (i) => _buildProgressDot(i < _profile.currentLevel),
                      ).take(5),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Play',
                              style: GoogleFonts.lexend(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressDot(bool filled) {
    return Container(
      width: 10,
      height: 10,
      margin: EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        color: filled ? AppTheme.primaryContainer : Colors.white24,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildSecondaryCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => context.push('/daily_quest'),
            child: Container(
              padding: EdgeInsets.all(16),
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
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.local_fire_department_rounded,
                          color: Colors.orange,
                          size: 24,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'NEW!',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Daily Quest',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Builder(builder: (context) {
                    final dueCount = ref.watch(dueWordCountProvider);
                    return Text(
                      dueCount.when(
                        data: (count) => '$count words to review',
                        loading: () => 'Loading...',
                        error: (_, __) => 'Ready to play',
                      ),
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        color: AppTheme.onSurface.withOpacity(0.6),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16),
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
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.bolt_rounded,
                    color: Color(0xFF42A5F5),
                    size: 24,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Speed Run',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Starts in 02:45:11',
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    color: AppTheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(BuildContext context) {
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
        children: [
          Text(
            'Your Progress',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 16),
          Builder(builder: (context) {
            final introduced = ref.watch(introducedCountProvider);
            final profile = _profile;
            return Row(
              children: [
                _buildStatColumn(
                  context,
                  introduced.when(
                    data: (c) => '$c',
                    loading: () => '—',
                    error: (_, __) => '0',
                  ),
                  'Words',
                  Icons.menu_book_rounded,
                ),
                _buildStatDivider(),
                _buildStatColumn(
                  context,
                  '${profile.globalLevel - 1}',
                  'Quests',
                  Icons.explore_rounded,
                ),
                _buildStatDivider(),
                _buildStatColumn(
                  context,
                  '${profile.streakCount}',
                  'Streak',
                  Icons.local_fire_department_rounded,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatColumn(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primary, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 12,
              color: AppTheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 48,
      color: AppTheme.surfaceContainerHigh,
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
                isActive: true,
                onTap: () {},
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
              color: isActive ? Colors.white : AppTheme.onSurface.withOpacity(0.5),
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
