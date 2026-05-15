import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/theme.dart';
import '../../application/service_providers.dart';
import '../../data/seed/content_seeder.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final AnimationController _spinController;
  late final AnimationController _progressController;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Initialize database and seed content on first launch
    final db = ref.read(databaseServiceProvider);
    final seeder = ContentSeeder(db);
    await seeder.seedIfNeeded();

    // Check if player profile exists → returning user goes to home
    final profile = await db.getPlayerProfile();
    final hasProfile = profile != null;

    // Ensure minimum splash duration for branding
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      context.go(hasProfile ? '/home' : '/profile_setup');
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    _spinController.dispose();
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient (sky blue to cream)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF66B6FF), Color(0xFFFDF6E3)],
              ),
            ),
          ),

          // Landscape image at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: size.height * 0.5,
            child: Opacity(
              opacity: 0.6,
              child: Image.asset(
                'assets/images/image_2828739f.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ),
          ),

          // Floating clouds
          _buildCloud(
            top: size.height * 0.08,
            left: size.width * 0.05,
            iconSize: 100,
            opacity: 0.4,
            delay: 0,
          ),
          _buildCloud(
            top: size.height * 0.22,
            left: size.width * 0.55,
            iconSize: 140,
            opacity: 0.3,
            delay: 2,
          ),
          _buildCloud(
            top: size.height * 0.55,
            left: size.width * 0.1,
            iconSize: 80,
            opacity: 0.2,
            delay: 4,
          ),

          // Decorative corner: Vocoro monogram top-left
          Positioned(
            top: 40,
            left: 24,
            child: Opacity(
              opacity: 0.3,
              child: Image.asset(
                'assets/images/vocoro_monogram.png',
                width: 48,
                height: 48,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),

                // Golden key logo in circle
                _buildKeyLogo(),

                SizedBox(height: 32),

                // App title
                Text(
                  'Vocoro',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                    letterSpacing: -1,
                    height: 1.1,
                  ),
                ),

                SizedBox(height: 8),

                // Subtitle
                Text(
                  'Unlock the Magic of Language',
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.secondary.withValues(alpha: 0.8),
                    letterSpacing: 0.5,
                  ),
                ),

                SizedBox(height: 64),

                // Loading star spinner
                _buildLoadingSection(),
              ],
            ),
          ),

          // Floating particles
          ..._buildParticles(size),
        ],
      ),
    );
  }

  Widget _buildKeyLogo() {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        final floatOffset =
            sin(_floatController.value * pi * 2) * 10;
        return Transform.translate(
          offset: Offset(0, floatOffset),
          child: child,
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow effect
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.secondaryContainer
                          .withValues(alpha: 0.3 * _pulseController.value),
                      blurRadius: 60,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              );
            },
          ),
          // Vocoro mascot
          Image.asset(
            'assets/images/vocoro_mascot.png',
            width: 180,
            height: 180,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSection() {
    return Column(
      children: [
        // Spinning star
        SizedBox(
          width: 56,
          height: 56,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.surfaceContainerHigh,
                    width: 3,
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _spinController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _spinController.value * 2 * pi,
                    child: child,
                  );
                },
                child: Icon(
                  Icons.star_rate_rounded,
                  size: 40,
                  color: AppTheme.secondaryContainer,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 20),

        // "PREPARING YOUR ADVENTURE" text
        Text(
          'PREPARING YOUR ADVENTURE',
          style: GoogleFonts.lexend(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 3,
            color: const Color(0xFF5F5B4D),
          ),
        ),

        SizedBox(height: 16),

        // Progress bar
        AnimatedBuilder(
          animation: _progressController,
          builder: (context, child) {
            return Container(
              width: 192,
              height: 8,
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: _progressController.value,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: LinearGradient(
                        colors: [AppTheme.primary, AppTheme.primaryContainer],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCloud({
    required double top,
    required double left,
    required double iconSize,
    required double opacity,
    required int delay,
  }) {
    return Positioned(
      top: top,
      left: left,
      child: AnimatedBuilder(
        animation: _floatController,
        builder: (context, child) {
          // Offset the animation phase by delay
          final phase = (_floatController.value + delay / 6.0) % 1.0;
          final floatOffset = sin(phase * pi * 2) * 15;
          return Transform.translate(
            offset: Offset(0, floatOffset),
            child: child,
          );
        },
        child: Opacity(
          opacity: opacity,
          child: Icon(
            Icons.cloud,
            size: iconSize,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildParticles(Size size) {
    return [
      Positioned(
        top: size.height * 0.25,
        left: size.width * 0.25,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Opacity(
              opacity: _pulseController.value,
              child: child,
            );
          },
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.secondaryContainer,
            ),
          ),
        ),
      ),
      Positioned(
        top: size.height * 0.33,
        right: size.width * 0.25,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Opacity(
              opacity: 1.0 - _pulseController.value,
              child: child,
            );
          },
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF66B6FF),
            ),
          ),
        ),
      ),
      Positioned(
        bottom: size.height * 0.25,
        right: size.width * 0.33,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Opacity(
              opacity: _pulseController.value * 0.7,
              child: child,
            );
          },
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryContainer,
            ),
          ),
        ),
      ),
    ];
  }
}
