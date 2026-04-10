import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/theme.dart';

class ParentGateScreen extends ConsumerStatefulWidget {
  const ParentGateScreen({super.key});

  @override
  ConsumerState<ParentGateScreen> createState() => _ParentGateScreenState();
}

class _ParentGateScreenState extends ConsumerState<ParentGateScreen> {
  int? _selectedOption;
  late final int _numberA;
  late final int _numberB;
  late final int _correctIndex; // 0 = A, 1 = B

  @override
  void initState() {
    super.initState();
    _generateChallenge();
  }

  void _generateChallenge() {
    final rng = Random();
    _numberA = rng.nextInt(15) + 5; // 5-19
    int b;
    do {
      b = rng.nextInt(15) + 5;
    } while (b == _numberA);
    _numberB = b;
    _correctIndex = _numberA > _numberB ? 0 : 1;
  }

  void _onOptionSelected(int index) {
    setState(() {
      _selectedOption = index;
    });

    if (index == _correctIndex) {
      // Correct — navigate after brief delay for feedback
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) context.go('/profile_setup');
      });
    } else {
      // Incorrect
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not quite! Try again.'),
          duration: Duration(seconds: 1),
        ),
      );
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() {
            _selectedOption = null;
            _generateChallenge();
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top app bar
            _buildTopBar(context),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    SizedBox(height: 16),

                    // Lock icon
                    _buildLockIcon(),

                    SizedBox(height: 24),

                    // Header text
                    Text(
                      'Parents, please solve this to enter the settings.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),

                    SizedBox(height: 8),

                    Text(
                      'Solving this puzzle ensures only big explorers can change the quest rules.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lexend(
                        fontSize: 15,
                        color: const Color(0xFF5F5B4D),
                      ),
                    ),

                    SizedBox(height: 32),

                    // Challenge card
                    _buildChallengeCard(),

                    SizedBox(height: 32),

                    // Answer buttons
                    _buildAnswerButtons(),

                    SizedBox(height: 32),

                    // Return to quest
                    _buildReturnButton(context),

                    SizedBox(height: 24),
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF322F22).withValues(alpha: 0.08),
            blurRadius: 32,
            offset: Offset(0, 12),
          ),
        ],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(Icons.arrow_back, color: AppTheme.primary),
            iconSize: 28,
          ),
          SizedBox(width: 8),
          Text(
            'Word Key Quest',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          Icon(
            Icons.stars_rounded,
            color: AppTheme.primary,
            size: 28,
          ),
        ],
      ),
    );
  }

  Widget _buildLockIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerHigh,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFDCD4BB),
            blurRadius: 0,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Icon(
        Icons.lock_rounded,
        size: 40,
        color: AppTheme.secondary,
      ),
    );
  }

  Widget _buildChallengeCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Decorative blurs
          Positioned(
            top: -16,
            right: -16,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryContainer.withValues(alpha: 0.2),
              ),
            ),
          ),
          Positioned(
            bottom: -32,
            left: -32,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.secondaryContainer.withValues(alpha: 0.2),
              ),
            ),
          ),
          // Content
          Column(
            children: [
              Text(
                'THE CHALLENGE',
                style: GoogleFonts.lexend(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                  color: AppTheme.secondary,
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '$_numberA',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 56,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF5F5B4D),
                    ),
                  ),
                  SizedBox(width: 16),
                  // "or" badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryDim,
                          blurRadius: 0,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      'or',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryContainer,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Text(
                    '$_numberB',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 56,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF5F5B4D),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Which number is larger?',
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _buildOptionButton(0, '$_numberA')),
          SizedBox(width: 24),
          Expanded(child: _buildOptionButton(1, '$_numberB')),
        ],
      ),
    );
  }

  Widget _buildOptionButton(int index, String value) {
    final isSelected = _selectedOption == index;
    final isCorrect = index == _correctIndex;

    Color borderColor = Colors.transparent;
    if (isSelected) {
      borderColor = isCorrect ? AppTheme.primaryContainer : AppTheme.errorContainer;
    }

    return GestureDetector(
      onTap: () => _onOptionSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppTheme.surfaceContainerHigh,
              blurRadius: 0,
              offset: Offset(0, isSelected ? 4 : 8),
            ),
          ],
        ),
        transform: isSelected
            ? Matrix4.translationValues(0, 4, 0)
            : Matrix4.identity(),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 48,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'SELECT',
              style: GoogleFonts.lexend(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF5F5B4D),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReturnButton(BuildContext context) {
    return TextButton.icon(
      onPressed: () => context.pop(),
      icon: Icon(Icons.arrow_back, size: 18, color: AppTheme.secondary),
      label: Text(
        'Return to Quest',
        style: GoogleFonts.lexend(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppTheme.secondary,
        ),
      ),
    );
  }
}
