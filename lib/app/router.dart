
import 'package:go_router/go_router.dart';
import '../features/onboarding/splash_screen.dart';
import '../features/onboarding/parent_gate_screen.dart';
import '../features/onboarding/child_profile_setup_screen.dart';
import '../features/onboarding/theme_selection_screen.dart';
import '../features/home/home_screen.dart';
import '../features/campaign/world_map_screen.dart';
import '../features/learn/level_intro_screen.dart';
import '../features/learn/learn_card_screen.dart';
import '../features/learn/memory_key_focus_screen.dart';
import '../features/minigames/image_match_screen.dart';
import '../features/minigames/meaning_tap_screen.dart';
import '../features/minigames/cue_recall_screen.dart';
import '../features/minigames/sentence_fix_screen.dart';
import '../features/learn/level_complete_screen.dart';
import '../features/home/daily_quest_screen.dart';
import '../features/vault/word_vault_screen.dart';
import '../features/vault/word_detail_screen.dart';
import '../features/rewards/rewards_room_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/parent/parent_dashboard_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // ── Onboarding ──
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/parent_gate',
      name: 'parent_gate',
      builder: (context, state) => const ParentGateScreen(),
    ),
    GoRoute(
      path: '/profile_setup',
      name: 'profile_setup',
      builder: (context, state) => const ChildProfileSetupScreen(),
    ),
    GoRoute(
      path: '/theme_setup',
      name: 'theme_setup',
      builder: (context, state) => const ThemeSelectionScreen(),
    ),

    // ── Home & Campaign ──
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/map',
      name: 'map',
      builder: (context, state) => const WorldMapScreen(),
    ),

    // ── Level Session Flow ──
    // Level intro accepts optional world/level params for dynamic loading
    GoRoute(
      path: '/level_intro',
      name: 'level_intro',
      builder: (context, state) => const LevelIntroScreen(),
    ),
    // Learn card — reads current word from SessionProvider
    GoRoute(
      path: '/learn_card',
      name: 'learn_card',
      builder: (context, state) => const LearnCardScreen(),
    ),
    // Memory key focus — reads current word from SessionProvider
    GoRoute(
      path: '/memory_key_focus',
      name: 'memory_key_focus',
      builder: (context, state) => const MemoryKeyFocusScreen(),
    ),

    // ── Mini-games — read current question from SessionProvider ──
    GoRoute(
      path: '/image_match',
      name: 'image_match',
      builder: (context, state) => const ImageMatchScreen(),
    ),
    GoRoute(
      path: '/meaning_tap',
      name: 'meaning_tap',
      builder: (context, state) => const MeaningTapScreen(),
    ),
    GoRoute(
      path: '/cue_recall',
      name: 'cue_recall',
      builder: (context, state) => const CueRecallScreen(),
    ),
    GoRoute(
      path: '/sentence_fix',
      name: 'sentence_fix',
      builder: (context, state) => const SentenceFixScreen(),
    ),

    // ── Level Complete ──
    GoRoute(
      path: '/level_complete',
      name: 'level_complete',
      builder: (context, state) => const LevelCompleteScreen(),
    ),

    // ── Daily Quest ──
    GoRoute(
      path: '/daily_quest',
      name: 'daily_quest',
      builder: (context, state) => const DailyQuestScreen(),
    ),

    // ── Vault ──
    GoRoute(
      path: '/vault',
      name: 'vault',
      builder: (context, state) => const WordVaultScreen(),
    ),
    GoRoute(
      path: '/word_detail',
      name: 'word_detail',
      builder: (context, state) => const WordDetailScreen(),
    ),

    // ── Rewards ──
    GoRoute(
      path: '/rewards',
      name: 'rewards',
      builder: (context, state) => const RewardsRoomScreen(),
    ),

    // ── Settings & Parent ──
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/parent_dashboard',
      name: 'parent_dashboard',
      builder: (context, state) => const ParentDashboardScreen(),
    ),
  ],
);

// ═══════════════════════════════════════════════════════
// Session-aware navigation helpers
// ═══════════════════════════════════════════════════════

/// Maps a QuestionType to its route path.
/// Used by the session flow to navigate to the correct mini-game screen.
String routeForQuestionType(String questionTypeName) {
  switch (questionTypeName) {
    case 'meaningTap':
      return '/meaning_tap';
    case 'imageMatch':
      return '/image_match';
    case 'cueRecall':
      return '/cue_recall';
    case 'sentenceFix':
      return '/sentence_fix';
    default:
      return '/meaning_tap';
  }
}
