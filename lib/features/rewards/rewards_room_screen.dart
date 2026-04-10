import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/theme.dart';

class RewardsRoomScreen extends StatelessWidget {
  const RewardsRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  _buildHeroSection(context),
                  SizedBox(height: 20),
                  _buildProgressCard(context),
                  SizedBox(height: 24),
                  _buildFurryFriendsSection(context),
                  SizedBox(height: 24),
                  _buildStickerAlbumSection(context),
                  SizedBox(height: 24),
                  _buildCozyFurnitureSection(context),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
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
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: Icon(Icons.settings_rounded, color: AppTheme.onSurface),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
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
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/image_9841b629.jpg',
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 220,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Icon(Icons.person_rounded, size: 80, color: AppTheme.primary),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        offset: Offset(0, 2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome, size: 16, color: AppTheme.secondary),
                      SizedBox(width: 6),
                      Text(
                        'Rare Look',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Next Reward',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                '850/1000',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 850 / 1000,
              minHeight: 12,
              backgroundColor: AppTheme.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryContainer),
            ),
          ),
          SizedBox(height: 8),
          Text(
            '150 more points to unlock!',
            style: GoogleFonts.lexend(
              fontSize: 12,
              color: AppTheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFurryFriendsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Furry Friends',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '3/12 Found',
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildPetCard(context, 'Barnaby', Icons.pets_rounded, AppTheme.primaryContainer, isEquipped: true),
              _buildPetCard(context, 'Whiskers', Icons.catching_pokemon, AppTheme.secondaryContainer),
              _buildPetCard(context, 'Dotty', Icons.cruelty_free_rounded, const Color(0xFFFFB3D9)),
              _buildPetCard(context, '???', Icons.lock_rounded, AppTheme.surfaceContainerHigh, isLocked: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPetCard(
    BuildContext context,
    String name,
    IconData icon,
    Color bgColor, {
    bool isEquipped = false,
    bool isLocked = false,
  }) {
    return Container(
      width: 120,
      margin: EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: isLocked
            ? AppTheme.surfaceContainerLow
            : AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: isEquipped
            ? Border.all(color: AppTheme.primary, width: 2)
            : Border.all(color: AppTheme.surfaceContainerHigh, width: 1),
        boxShadow: isLocked
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  offset: Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isLocked ? AppTheme.surfaceContainerHigh : bgColor.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 36,
              color: isLocked
                  ? AppTheme.onSurface.withOpacity(0.3)
                  : AppTheme.onSurface.withOpacity(0.8),
            ),
          ),
          SizedBox(height: 10),
          Text(
            name,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isLocked
                  ? AppTheme.onSurface.withOpacity(0.3)
                  : AppTheme.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          if (isEquipped) ...[
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Equipped',
                style: GoogleFonts.lexend(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStickerAlbumSection(BuildContext context) {
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
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.secondaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.collections_bookmark_rounded,
              size: 32,
              color: AppTheme.secondary,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sticker Album',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '42 Stickers Collected',
                  style: GoogleFonts.lexend(
                    fontSize: 13,
                    color: AppTheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              minimumSize: Size.zero,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: Text(
              'Open Album',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCozyFurnitureSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Cozy Furniture',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildFurnitureCard(context, 'Log Bed', Icons.bed_rounded, isEquipped: true),
              _buildFurnitureCard(context, 'Firefly Lamp', Icons.lightbulb_rounded),
              _buildFurnitureCard(context, '???', Icons.lock_rounded, isLocked: true),
              _buildFurnitureCard(context, '???', Icons.lock_rounded, isLocked: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFurnitureCard(
    BuildContext context,
    String name,
    IconData icon, {
    bool isEquipped = false,
    bool isLocked = false,
  }) {
    return Container(
      width: 120,
      margin: EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: isLocked
            ? AppTheme.surfaceContainerLow
            : AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: isEquipped
            ? Border.all(color: AppTheme.primary, width: 2)
            : Border.all(color: AppTheme.surfaceContainerHigh, width: 1),
        boxShadow: isLocked
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  offset: Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isLocked
                  ? AppTheme.surfaceContainerHigh
                  : AppTheme.primaryContainer.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 36,
              color: isLocked
                  ? AppTheme.onSurface.withOpacity(0.3)
                  : AppTheme.primary,
            ),
          ),
          SizedBox(height: 10),
          Text(
            name,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isLocked
                  ? AppTheme.onSurface.withOpacity(0.3)
                  : AppTheme.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          if (isEquipped) ...[
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Equipped',
                style: GoogleFonts.lexend(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
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
              _buildNavItem(context, icon: Icons.home_rounded, label: 'Home', onTap: () => context.go('/home')),
              _buildNavItem(context, icon: Icons.map_rounded, label: 'Map', onTap: () => context.push('/map')),
              _buildNavItem(context, icon: Icons.inventory_2_rounded, label: 'Vault', onTap: () => context.push('/vault')),
              _buildNavItem(context, icon: Icons.card_giftcard_rounded, label: 'Rewards', isActive: true, onTap: () {}),
              _buildNavItem(context, icon: Icons.supervisor_account_rounded, label: 'Parent', onTap: () => context.push('/settings')),
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
                color: isActive ? Colors.white : AppTheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
