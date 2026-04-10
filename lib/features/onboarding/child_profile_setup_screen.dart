import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/theme.dart';
import '../../application/player_provider.dart';

const _avatarUrls = [
  'assets/images/image_03dfaf78.jpg',
  'assets/images/image_1eb569ca.jpg',
  'assets/images/image_f3dbcfc7.jpg',
  'assets/images/image_d645884e.jpg',
  'assets/images/image_80771cbe.jpg',
  'assets/images/image_34035a3a.jpg',
  'assets/images/image_e3efc823.jpg',
  'assets/images/image_5be6f5c6.jpg',
];

class ChildProfileSetupScreen extends ConsumerStatefulWidget {
  const ChildProfileSetupScreen({super.key});

  @override
  ConsumerState<ChildProfileSetupScreen> createState() =>
      _ChildProfileSetupScreenState();
}

class _ChildProfileSetupScreenState
    extends ConsumerState<ChildProfileSetupScreen> {
  final _nameController = TextEditingController();
  int _selectedAvatar = 0;
  int _selectedAge = 8;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    Text(
                      'Create Your Profile',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Choose your hero and tell us your name!',
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        color: const Color(0xFF5F5B4D),
                      ),
                    ),
                    SizedBox(height: 24),
                    _buildAvatarSection(),
                    SizedBox(height: 32),
                    _buildNameField(),
                    SizedBox(height: 28),
                    _buildAgeSelector(),
                    SizedBox(height: 40),
                    _buildGoButton(context),
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
            'Vocoro',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          Icon(Icons.stars_rounded, color: AppTheme.primary, size: 28),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.face, size: 20, color: AppTheme.secondary),
            SizedBox(width: 8),
            Text(
              'Choose Your Avatar',
              style: GoogleFonts.lexend(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurface,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: _avatarUrls.length,
          itemBuilder: (context, index) {
            final isSelected = _selectedAvatar == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedAvatar = index),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: isSelected
                      ? Border.all(color: AppTheme.primaryContainer, width: 3)
                      : Border.all(
                          color: AppTheme.surfaceContainerHigh, width: 2),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryContainer
                                .withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Image.asset(
                    _avatarUrls[index],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppTheme.surfaceContainerLow,
                      child: Icon(Icons.person, color: AppTheme.primary),
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

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.edit, size: 18, color: AppTheme.secondary),
            SizedBox(width: 8),
            Text(
              "What's your name?",
              style: GoogleFonts.lexend(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurface,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        TextField(
          controller: _nameController,
          style: GoogleFonts.lexend(fontSize: 16, color: AppTheme.onSurface),
          decoration: InputDecoration(
            hintText: 'Type your name here...',
            hintStyle: GoogleFonts.lexend(
              fontSize: 16,
              color: const Color(0xFF5F5B4D).withValues(alpha: 0.5),
            ),
            suffixIcon: Icon(
                Icons.edit, size: 20, color: AppTheme.primaryContainer),
            filled: true,
            fillColor: AppTheme.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildAgeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.cake, size: 18, color: AppTheme.secondary),
            SizedBox(width: 8),
            Text(
              'How old are you?',
              style: GoogleFonts.lexend(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurface,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: List.generate(8, (index) {
            final age = index + 6;
            final isSelected = _selectedAge == age;
            return Padding(
              padding: EdgeInsets.zero,
              child: GestureDetector(
                onTap: () => setState(() => _selectedAge = age),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppTheme.primary : Colors.transparent,
                    border: isSelected
                        ? null
                        : Border.all(
                            color: AppTheme.surfaceContainerHigh, width: 2),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppTheme.primaryDim,
                              blurRadius: 0,
                              offset: Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$age',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF5F5B4D),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  bool _isSaving = false;

  Future<void> _saveAndContinue() async {
    if (_isSaving) return;

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name!')),
      );
      return;
    }

    setState(() => _isSaving = true);

    await ref.read(playerProvider.notifier).createProfile(
          name: name,
          ageBand: _selectedAge,
          avatarId: _selectedAvatar,
          selectedTheme: 'enchanted_kingdom', // default, changed in theme selection
        );

    if (mounted) {
      context.go('/theme_setup');
    }
  }

  Widget _buildGoButton(BuildContext context) {
    return GestureDetector(
      onTap: _saveAndContinue,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryDim,
              blurRadius: 0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Let's Go!",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward, color: Colors.white, size: 22),
          ],
        ),
      ),
    );
  }
}
