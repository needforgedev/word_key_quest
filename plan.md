# Word Key Quest — Execution Plan

## Current State (as of 2026-05-15)

App rebranded to **Vocoro**. Version bumped to `0.9.0+1` for beta. Privacy policy drafted in `privacy.md` (hosted on GitHub for store consoles).

### What's Done
- [x] Flutter project initialized (Dart SDK ^3.11.0), rebranded to Vocoro
- [x] GoRouter with 21 routes defined (no placeholders in use)
- [x] AppTheme with 3 full palettes (Sky Heroes, Enchanted Kingdom, Explorer Quest) + Google Fonts (Plus Jakarta Sans, Lexend)
- [x] Riverpod ProviderScope set up in main.dart
- [x] All 20 screens built with design-matched UI
- [x] Full navigation flow wired end-to-end
- [x] Raw word dataset processed (3,523 words)
- [x] **Phase 1 complete**: Content manifests, domain models (8 classes + wordOrderSeed), SQLite database (8 tables), repository layer (6 repos), content seeder
- [x] **Phase 2 complete**: Mastery engine (0-5 state machine), spaced repetition scheduler (7 intervals), question engine (4 mini-game generators with 4 choices for Image Match), adaptive difficulty controller, session manager
- [x] **Phase 3 complete**: 10 Riverpod providers, router with session-aware navigation
- [x] **Phase 4 complete**: All 20 screens wired to live data — onboarding saves profile, home shows real stats, learn flow teaches real words, mini-games validate real answers with mastery tracking, vault searches/filters real data, settings persist to SharedPreferences
- [x] **Per-player word randomization**: Each player gets a unique `wordOrderSeed` on profile creation → deterministic shuffle of all 3,500 words → different word order per player, all words covered
- [x] **UI images**: Temp network URLs replaced with local assets in `assets/images/` (28 UI images)
- [x] **Word images**: **All 3,523 per-word images mapped** in `WordImageHelper` — 100% coverage across all 35 worlds
- [x] **Audio (TTS)**: `flutter_tts` integrated for word/meaning/memory key speech (offline, uses device engine)
- [x] **Theme pack switching**: 3 palettes with live switching, themed world names per pack
- [x] **Privacy policy**: drafted in `privacy.md`, aligned with COPPA / Apple Kids / Google Play Families
- [x] **Beta version**: bumped to `0.9.0+1` in pubspec.yaml

### What's NOT Done
- [ ] UI feedback sounds (correct/incorrect dings) — TTS works, but no pre-recorded SFX
- [ ] Boss challenges (`bossEnabled` flag exists in data; no special UI or 5-level gate)
- [ ] Tutorial level (3-word warmup before Level 1 per spec §12)
- [ ] Tests (only 1 smoke test; no unit tests for mastery/SRS/question engine)
- [ ] Analytics hooks (no event tracking)
- [ ] Dyslexia font toggle — UI + SharedPreferences key exist, but NOT wired to actual font swap (deferred)
- [ ] Crash reporting (Sentry/Crashlytics) — deferred
- [ ] Externalize `word_image_helper.dart` (~3,900 lines of static map) to `assets/data/word_images.json` (maintainability only)

---

## Raw Data Analysis

**Source**: `barrons_3500_master copy - Sheet1.json`
- **Total words**: 3,523
- **Campaign words**: 3,500 (sorted by sourceRank, first 3,500)
- **Bonus vault**: 23 (remaining after campaign)
- **Fields per word**: sourceRank, word, partOfSpeech, pronunciation, barronsMeaning, kidsMeaning, cueType, cue, memoryKey, nanoBananaPrompt, synonyms, antonyms, usage1Simple, usage2Standard, sourceInWorkbook, workbookSheet, promptProfile, imageProfile
- **Missing data**: pronunciation (370 words), antonyms (1,908 words), workbookSheet (2,636 words)
- **Cue types**: sound (580), situation (2,683), root (183), chunk (76), split (1)
- **Spec mentions `confusableWith`** but field is NOT present in the dataset

---

## Phase 1: Content Pipeline & Data Foundation
**Goal**: Transform raw JSON into app-ready manifests and seed data

### Step 1.1 — Content Manifest Generator Script ✅
- [x] Created `tools/generate_manifests.dart`
- [x] Sorted 3,523 words by `sourceRank`
- [x] Assigned first 3,500 words to campaign: world = (rank-1) / 100, level = ((rank-1) % 100) / 10
- [x] Assigned remaining 23 words to bonus vault
- [x] Generated `assets/data/words.json` (2,599KB): 3,523 normalized word entries with id, worldIndex, levelIndex, parsed synonyms/antonyms arrays
- [x] Generated `assets/data/worlds.json` (6KB): 35 campaign worlds + 1 bonus vault with names and unlock requirements
- [x] Generated `assets/data/levels.json` (128KB): 350 levels with worldId, levelNumber, wordIds[], bossEnabled every 5th level
- [x] Generated `assets/data/reward_catalog.json` (20KB): 115 rewards (35 world completion + 70 boss + 10 milestone)
- [x] All validations passed: every level has exactly 10 words, no duplicates, bonus words excluded
- [x] Registered assets in pubspec.yaml
- **Data notes**: 370 words missing pronunciation, 0 missing kidsMeaning/memoryKey/cue

### Step 1.2 — Domain Models ✅
- [x] Created `lib/data/models/word_entry.dart` — WordEntry (18 fields, fromJson/toJson, sentenceWithBlank getter)
- [x] Created `lib/data/models/word_progress.dart` — WordProgress (masteryLevel 0-5, timesSeen, timesCorrect/Incorrect, lastSeenAt, nextReviewAt, accuracy getter, copyWith)
- [x] Created `lib/data/models/player_profile.dart` — PlayerProfile (name, ageBand, avatarId, selectedTheme, currentWorld/Level, streak, stars, keys, copyWith)
- [x] Created `lib/data/models/world.dart` — World (id, index, name, wordCount, levelCount, unlockRequirement)
- [x] Created `lib/data/models/level.dart` — Level (worldId, levelNumber, newWordIds, bossEnabled, starReward, keyReward)
- [x] Created `lib/data/models/session_result.dart` — QuestionType enum, QuestionItem, QuestionResult, LevelSession (with accuracy, starRating, progress tracking)
- [x] Created `lib/data/models/reward_item.dart` — RewardItem + RewardProgress (unlock/equip tracking)
- [x] Created `lib/data/models/daily_quest.dart` — DailyQuest (reviewWordIds, targetCount, accuracy, estimatedMinutes)
- [x] Created `lib/data/models/models.dart` — barrel export
- [x] All models pass flutter analyze with 0 issues

### Step 1.3 — Local Database Setup ✅
- [x] Added `sqflite` ^2.4.2 + `path` ^1.9.1 to pubspec.yaml
- [x] Created `lib/data/local_db/database_service.dart` — 8 tables (words, worlds, levels, rewards, player_profile, word_progress, reward_progress, daily_quests), 4 indexes, full CRUD with row mappers
- [x] Created `lib/data/seed/content_seeder.dart` — loads all 4 JSON manifests from assets, seeds into SQLite on first launch
- [x] Assets already registered in pubspec.yaml (Step 1.1)
- [x] Wired seed flow into splash_screen.dart: seeds DB on first launch, checks for existing profile → routes to `/home` (returning) or `/parent_gate` (new user)
- [x] All files pass flutter analyze with 0 issues

### Step 1.4 — Repository Layer ✅
- [x] Created `lib/data/repositories/content_repository.dart` — word queries (by level, by ID, search, distractors by POS), world/level lookups, in-memory caching
- [x] Created `lib/data/repositories/player_repository.dart` — create/save profile, addStars, addKeys, advanceLevel, updateStreak (consecutive-day logic), updateTheme/Avatar
- [x] Created `lib/data/repositories/progress_repository.dart` — markIntroduced, recordCorrect/Incorrect with mastery promotion (question-type-gated) and SRS scheduling
- [x] Created `lib/data/repositories/review_repository.dart` — getDueWords, getOrCreateTodayQuest (auto-generates from due + weak words), recordQuestAnswer
- [x] Created `lib/data/repositories/reward_repository.dart` — unlock/equip/unequip, checkAndUnlock by rule string
- [x] Created `lib/data/repositories/settings_repository.dart` — SharedPreferences toggles (music, voice, dyslexia, textSize, difficulty, audioCues, visualCues) + AppSettings snapshot
- [x] Created `lib/data/repositories/repositories.dart` — barrel export
- [x] All repositories pass flutter analyze with 0 issues

---

## Phase 2: Core Game Engine
**Goal**: Build the mastery, review, and question systems

### Step 2.1 — Mastery Engine ✅
- [x] Created `lib/core/mastery_engine.dart`
- [x] Mastery state machine (0→5): introduceWord (0→1), recordCorrect (type-gated promotion), recordIncorrect (demote by 1, floor at 1)
- [x] Question type ceilings: MeaningTap/ImageMatch→2, CueRecall→3, SentenceFix→5
- [x] `appropriateQuestionTypes(masteryLevel)` — maps mastery level to valid game types for adaptive difficulty
- [x] `processSessionResults()` — batch processes all answers from a level session
- [x] `MasteryResult` and `SessionMasterySummary` — result objects for UI feedback (promoted/demoted/newly mastered counts)
- [x] Passes flutter analyze with 0 issues

### Step 2.2 — Spaced Repetition Scheduler ✅
- [x] Created `lib/core/review_scheduler.dart`
- [x] SRS intervals: 4h (mastery 1) → 1d (2) → 3d (3) → 7d (4) → 14d/30d/60d (mastery 5, expanding)
- [x] `calculateNextReview()` — static interval calculator with mastered-word expansion stages
- [x] `calculateReviewAfterError()` — 2-hour fast retry after incorrect
- [x] Due word queries via ReviewRepository (nextReviewAt <= now, mastery 1-4)
- [x] `getTodayQuest()` — generates daily quest from due words + weak fallbacks, 5-15 items
- [x] `reviewPriority()` — scores urgency by overdue hours, mastery level, and error rate
- [x] `ReviewQueueStatus` — snapshot for home screen (due count, introduced/mastered totals, mastery breakdown)
- [x] Passes flutter analyze with 0 issues

### Step 2.3 — Question Engine ✅
- [x] Created `lib/core/question_engine.dart`
- [x] 4 generators: `generateMeaningTap` (kidsMeaning choices), `generateImageMatch` (word ID choices for UI image resolution), `generateCueRecall` (cue prompt → pick correct word), `generateSentenceFix` (blanked sentence → pick correct word)
- [x] `generate(word, type)` — single dispatch, `generateBatch()` — bulk with custom type selector, `generateForLevel()` — cycles MeaningTap→ImageMatch→CueRecall→SentenceFix
- [x] Distractor strategy: prefer same part of speech, filter out antonyms of target, auto-replace if filtering removes too many
- [x] All choices shuffled randomly so correct answer position varies
- [x] `_extractCueFragment()` — extracts first sentence or 60-char cap from memoryKey for cue prompts
- [x] Score calculation: `calculateStars` (accuracy → 1-3 stars), `calculateTimeBonus` (response time → 0-10 points), `calculateSessionStars`
- [x] Passes flutter analyze with 0 issues

### Step 2.4 — Adaptive Difficulty ✅
- [x] Created `lib/core/difficulty_controller.dart`
- [x] Rolling accuracy window (last 20 questions) with per-question-type tracking
- [x] Three profiles: `supportive` (<60%), `standard` (60-85%), `challenging` (>85%)
- [x] Level adjustments: struggling → 7 new / 6 review words; cruising → 10 new / 2 review
- [x] Game type biasing: struggling → 70% easiest valid type; cruising → bias toward weakest type; standard → balanced with 25% weak-area targeting
- [x] `selectQuestionType(mastery, index)` — picks best game type per word considering difficulty profile
- [x] `generateTypeDistribution()` — builds type list for entire level
- [x] `DifficultySnapshot` — diagnostic snapshot for parent dashboard (accuracies, profile, parameters)
- [x] Passes flutter analyze with 0 issues

### Step 2.5 — Session Manager ✅
- [x] Created `lib/core/session_manager.dart`
- [x] Two session types: `startLevelSession(world, level)` and `startDailyQuestSession()`
- [x] Learn card phase: `getCurrentLearnWord()`, `advanceLearnWord()` (marks introduced), `isLearnPhaseComplete`
- [x] Quiz phase: `getCurrentQuestion()`, `submitAnswer(index)` → `AnswerFeedback` with mastery change + time bonus
- [x] `completeSession()` → awards stars/keys, advances level, checks reward unlocks (level/world/milestone), updates streak → returns `SessionCompletionResult`
- [x] Integrates all Phase 2 engines: MasteryEngine, QuestionEngine, DifficultyController, ReviewScheduler
- [x] `SessionPhase` enum (idle/learning/quizzing/complete), progress tracking, `abandonSession()`
- [x] `AnswerFeedback` — per-answer result for UI; `SessionCompletionResult` — everything the level complete screen needs
- [x] Passes flutter analyze with 0 issues

---

## Phase 3: State Management (Riverpod Providers)
**Goal**: Wire data layer to UI through Riverpod

### Step 3.1 — Core Providers ✅
- [x] `lib/application/service_providers.dart` — foundation: DatabaseService, 6 repositories, 4 core engines, SessionManager (all as Riverpod `Provider`)
- [x] `lib/application/player_provider.dart` — `AsyncNotifier<PlayerProfile?>`: createProfile, refresh, updateTheme, updateAvatar + `currentProfileProvider` convenience
- [x] `lib/application/content_provider.dart` — `FutureProvider.family` for worlds, levels, words by ID/level/search, bonus words, reward catalog
- [x] `lib/application/campaign_provider.dart` — `Notifier<CampaignState>`: world/level unlock checks, progression tracking, loadWorldLevels
- [x] `lib/application/session_provider.dart` — `Notifier<SessionState>`: startLevel, startDailyQuest, advanceLearnCard, submitAnswer, completeSession, abandonSession
- [x] `lib/application/mastery_provider.dart` — FutureProviders for word progress, introduced/mastered counts, mastery breakdown, overall accuracy
- [x] `lib/application/review_provider.dart` — FutureProviders for due word count, today's quest, queue status
- [x] `lib/application/settings_provider.dart` — `Notifier<AppSettings>`: music, voice, dyslexia, textSize, difficulty, audioCues, visualCues
- [x] `lib/application/theme_provider.dart` — selected theme from profile, display name helpers
- [x] `lib/application/reward_provider.dart` — FutureProviders for reward progress/unlocks + `Notifier` for equip/unequip actions
- [x] `lib/application/providers.dart` — barrel export
- [x] All providers use Riverpod v3 API (Notifier/AsyncNotifier, not deprecated StateNotifier)
- [x] Passes flutter analyze with 0 issues

### Step 3.2 — Provider Dependencies ✅
- [x] Bootstrap flow: splash screen uses `databaseServiceProvider` instead of direct instantiation
- [x] Router updated with named routes, comments indicating which screens read from SessionProvider
- [x] `routeForQuestionType()` helper — maps QuestionType to mini-game route for dynamic navigation
- [x] Session flow ready: screens will read from `sessionProvider` to get current word/question (wired in Phase 4)
- [x] Review flow ready: daily quest screen will read from `reviewProvider` (wired in Phase 4)
- [x] Passes flutter analyze with 0 issues

---

## Phase 4: Wire Screens to Live Data
**Goal**: Replace hardcoded data in all 20 screens with provider-driven state

### Step 4.1 — Onboarding Flow ✅
- [x] Splash: uses `databaseServiceProvider`, seeds on first launch, routes to `/home` (returning) or `/parent_gate` (new user)
- [x] Parent Gate: randomized challenge, navigates to profile setup on correct answer (already done)
- [x] Profile Setup: "Let's Go!" button now calls `playerProvider.createProfile()` with name, age, avatar — validates name not empty, shows saving state
- [x] Theme Selection: converted to `ConsumerStatefulWidget`, "Choose Theme" button calls `playerProvider.updateTheme()` with selected theme key before navigating to `/home`
- [x] **Profile now persists to SQLite** — app remembers the user on relaunch
- [x] Passes flutter analyze with 0 errors (info-level only)

### Step 4.2 — Home & Campaign ✅
- [x] Home: real player name/level/streak/stars/keys from `playerProvider`, world name from `campaignProvider`, due review count from `dueWordCountProvider`, progress dots reflect current level
- [x] Daily Quest: real due word count from `dueWordCountProvider`, real streak from `currentProfileProvider`, "Start Quest" calls `sessionProvider.startDailyQuest()` then navigates
- [x] World Map: real world names from `campaignProvider`, level completion/lock state from `campaignProvider.notifier`, active level from player profile, real star count
- [x] Level Intro: real level number from `playerProvider.globalLevel`, real world name from `campaignProvider`, "START LEVEL" calls `sessionProvider.startLevel()` then navigates to `/learn_card`
- [x] Passes flutter analyze with 0 errors/warnings (info-level only)

### Step 4.3 — Learn Flow ✅
- [x] Learn Card: reads `sessionProvider.currentLearnWord` to display real word, kidsMeaning, memoryKey from DB
- [x] Memory Key Focus: shows real cue, memoryKey, and dynamic "Did you notice?" hint from the WordEntry
- [x] "Got It!" button advances through learn cards via `sessionProvider.advanceLearnCard()` — marks word as introduced (mastery 0→1)
- [x] When all learn cards viewed, auto-transitions to quiz phase: navigates to correct mini-game route via `routeForQuestionType()`
- [x] If more learn cards remain, loops back to `/learn_card`
- [x] Passes flutter analyze with 0 errors/warnings

### Step 4.4 — Mini-games ✅
- [x] All four games converted to `ConsumerStatefulWidget`, read `sessionProvider.currentQuestion`
- [x] **Meaning Tap**: prompt shows real word, choices from `question.choices`, icons cycle by index
- [x] **Image Match**: 2x2 grid with 4 square image choices (no text), real word images via `WordImageHelper`, random fallback from available images
- [x] **Cue Recall**: cue card shows real `question.prompt` (the cue text), word options from choices
- [x] **Sentence Fix**: sentence shows real `question.prompt` (blanked sentence), progress shows `questionNumber/totalQuestions`
- [x] All games call `sessionProvider.submitAnswer(index)` on selection → updates mastery via MasteryEngine
- [x] After each answer: navigates to next mini-game route via `routeForQuestionType()` or to `/level_complete` when quiz is done
- [x] Progress bars read `sessionState.quizProgress` for real progress tracking
- [x] Passes flutter analyze with 0 errors/warnings

### Step 4.5 — Level Complete & Rewards ✅
- [x] Converted to `ConsumerStatefulWidget`, calls `sessionProvider.completeSession()` in `initState`
- [x] Shows loading spinner while session completes, then displays real `SessionCompletionResult`
- [x] Stars: 1-3 filled based on `result.starsEarned`, unfilled stars shown in grey
- [x] Stats bento: real `wordsPromoted` count and `starsEarned * 10` points
- [x] Subtitle: real accuracy as "X/Y correct — Z% accuracy!"
- [x] Level badge: shows real level number or "Quest Complete" for daily quests
- [x] Reward card: shows real `keysEarned` count with plural handling
- [x] `completeSession()` handles: star/key awards, level advancement, reward unlocks, streak update, mastery summary — all via SessionManager
- [x] "CONTINUE ADVENTURE" → `/home`, "Replay Level" → `/level_intro`
- [x] Passes flutter analyze with 0 errors/warnings

### Step 4.6 — Vault & Word Detail ✅
- [x] Word Vault: loads `allWordProgressProvider` for introduced words, `introducedCountProvider`/`masteredCountProvider` for stats bento
- [x] Filters: "Learned" (mastery > 0), "Review" (needsReview), "Mastered" (mastery >= 5) — all from real DB queries
- [x] Search: wired `onChanged` → `wordSearchProvider(_searchQuery)` for real-time word search from SQLite
- [x] Each word card loads `WordEntry` via `wordByIdProvider` to show real word name, mastery X/5, filled stars
- [x] Vault sets `selectedWordIdProvider` before navigating to word detail
- [x] Word Detail: reads `selectedWordIdProvider` → loads `WordEntry` and `WordProgress` from providers
- [x] Shows real: word, pronunciation, kidsMeaning, memoryKey, synonyms, antonyms, usage1Simple, mastery level/5
- [x] Passes flutter analyze with 0 errors/warnings

### Step 4.7 — Parent Dashboard & Settings ✅
- [x] Parent Dashboard: converted to `ConsumerWidget`, shows real player name, `introducedCountProvider` for total words, `overallAccuracyProvider` for accuracy, `settingsProvider` for difficulty badge and audio/visual cue toggles
- [x] Settings: converted to `ConsumerStatefulWidget`, all toggles read/write via `settingsProvider.notifier` (music, voice, dyslexia font, text size), persisted to SharedPreferences automatically
- [x] Save button shows confirmation SnackBar
- [x] Re-exported `AppSettings` from `settings_provider.dart` for screen access
- [x] Passes flutter analyze with 0 errors/warnings

---

## Post-Phase 4 Improvements
**Bug fixes and enhancements applied during testing**

### Per-Player Word Randomization ✅
- [x] Added `wordOrderSeed` (int) to `PlayerProfile` model and `player_profile` DB table
- [x] `PlayerRepository.createProfile()` generates `Random().nextInt(1 << 31)` as unique seed
- [x] `ContentRepository.getShuffledWordIds(seed)` — deterministic shuffle via `Random(seed)`, all 3,500 words included once
- [x] `ContentRepository.getShuffledWordsForLevel(seed, levelNumber)` — slices 10 words per level from shuffled sequence
- [x] `SessionManager.startLevelSession()` reads player's seed and loads words via shuffled order instead of fixed manifest
- [x] Every player gets different words in different levels; same seed always reproduces same order

### Bug Fixes ✅
- [x] Fixed `completeSession()` double-processing mastery results — now tracks `MasteryResult` per-answer during `submitAnswer()` instead of re-processing at completion
- [x] Fixed `Image.asset()` `loadingBuilder` error (parameter only exists on `Image.network()`)
- [x] Fixed age selector overflow on profile setup — changed `Row` to `Wrap`
- [x] Fixed world map auto-scroll — added `ScrollController` that scrolls to active level on screen open
- [x] Fixed Image Match showing word IDs as text — now shows only images in 2x2 grid with 4 choices

### Beta Polish — 2026-05-15 ✅
- [x] **Parent gate bypassed for new users**: splash routes new users straight to `/profile_setup` (was: `/parent_gate`). Parent gate route/screen kept for future Settings gating.
- [x] **Word Detail back button fixed**: uses `canPop()` with `/vault` fallback so back works whether arrived from vault or directly
- [x] **Auto-scroll to top between learn cards**: added `ValueKey(word.id)` to `SingleChildScrollView` on `learn_card_screen.dart` and `memory_key_focus_screen.dart` — scroll resets when word changes
- [x] **All 4 mini-game back buttons fixed**: now call `abandonSession()` + navigate to `/home` instead of broken `context.pop()`
- [x] **Image Match available at higher levels**: `_validTypesForMastery` in `difficulty_controller.dart` now includes `imageMatch` for mastery 3-5 (was only 0-2)
- [x] **Type-mismatch safety guard**: each mini-game screen now checks `question.type` on build. If wrong type is loaded (e.g. ImageMatch question landed on `/meaning_tap`), redirects via `routeForQuestionType` — no more word IDs flashing as text before images load
- [x] **Level Intro shows real session counts**: converted to `ConsumerStatefulWidget`, starts session in `initState`, displays actual `newWordIds.length` / `reviewWordIds.length` from the loaded session (no longer hardcoded "10/3"). START LEVEL button shows "Loading…" disabled state until session is ready, then just navigates (no double-start).
- [x] **Level Intro back button fixed**: uses `canPop()` with `/home` fallback
- [x] **Hardcoded UI badges → live data**: `'Level 12'` in `meaning_tap_screen.dart` → `profile.globalLevel`; `'1,240'` star count in `cue_recall_screen.dart` and `sentence_fix_screen.dart` → `profile.stars`
- [x] **Dead code removed**: unused `_hintImageUrl` field, `_buildBottomNavBar()` + `_navItem()` methods from `meaning_tap_screen.dart`; unused `service_providers.dart` import from `image_match_screen.dart`
- [x] **Dyslexia font toggle hidden**: commented out in `settings_screen.dart` (UI no-op until OpenDyslexic font is wired into theme) — easy to restore

---

## Phase 5: Audio & Assets
**Goal**: Replace temp URLs with real assets, add audio

### Step 5.1 — Image Assets ✅
- [x] UI placeholder images downloaded and stored in `assets/images/` (28 images)
- [x] All `Image.network()` calls replaced with `Image.asset()` across 16 screens
- [x] pubspec.yaml updated with asset declarations
- [x] **All 3,523 per-word images** copied to `assets/images/words/` — 100% coverage across all 35 worlds
- [x] Created `lib/core/word_image_helper.dart` — static map of all 3,523 word IDs → asset paths, `hasImage()`, `getImagePath()`, `allAvailablePaths`, `buildWordImage()` with placeholder fallback
- [x] **Learn Card**: shows real word image
- [x] **Memory Key Focus**: shows real word image with overlay
- [x] **Image Match**: 2x2 grid with 4 square image choices (no text labels)
- [x] **Word Detail**: hero image uses real word image
- [x] **Word Vault**: thumbnails show real word images
- [x] Passes flutter analyze with 0 errors/warnings
- [ ] Future: externalize the 3,523-entry static map to `assets/data/word_images.json` for maintainability (no behavior change)

### Step 5.2 — Audio System (TTS) ✅
- [x] Added `flutter_tts` ^4.2.0 to pubspec.yaml (offline, uses device speech engine)
- [x] Created `lib/core/audio/tts_service.dart` — `speakWord()` (slow 0.35 rate), `speakMeaning()`, `speakMemoryKey()` (0.4 rate), `speakSentence()`, `speakWordCard()` (word then meaning), `stop()`
- [x] Added `ttsServiceProvider` to service_providers.dart
- [x] **Learn Card**: speaker icon speaks the word, "Hear Memory Key" button speaks the memory key
- [x] **Memory Key Focus**: "Replay Audio" button speaks the memory key
- [x] **Word Detail**: "Hear" button speaks the word
- [x] Passes flutter analyze with 0 errors/warnings
- [ ] Remaining: UI feedback sounds (correct/incorrect ding) — needs pre-recorded audio files

---

## Phase 6: Polish & Testing
**Goal**: Quality, performance, and robustness

### Step 6.1 — Theme Pack Switching ✅
- [x] Created `ThemePalette` class and three palettes: `skyHeroes` (blue/gold), `enchantedKingdom` (green/gold, original), `explorerQuest` (amber/teal)
- [x] `AppTheme.themeFromPalette()` builds full `ThemeData` from any palette (colors, typography, buttons)
- [x] `AppTheme.paletteFor(themeKey)` maps theme key string to palette
- [x] Created `lib/core/theme_world_names.dart` — 35 unique world names per theme (sky/flight themed, magic/forest themed, map/jungle themed)
- [x] `ThemeProvider`: `themeDataProvider` returns dynamic `ThemeData`, `themePaletteProvider` returns active palette, `themedWorldNameProvider(worldIndex)` returns themed world name
- [x] `main.dart` converted to `ConsumerWidget`, reads `themeDataProvider` so colors switch live when theme changes
- [x] Home screen, Level Intro, World Map all use `themedWorldNameProvider` for world names
- [x] Passes flutter analyze with 0 errors/warnings

### Step 6.2 — Boss Challenges
- [ ] Every 5th level: mixed review boss challenge
- [ ] Gate next 5 levels behind boss completion
- [ ] Special boss reward unlocks

### Step 6.3 — Testing
- [ ] Content validation tests (manifest integrity)
- [ ] Domain logic tests (mastery transitions, review scheduling, daily quest generation)
- [ ] Repository tests (persistence roundtrip)
- [ ] Widget tests (onboarding flow, mini-game answer validation)
- [ ] Navigation tests (first launch vs returning user)
- [ ] Performance tests (cold launch < 3s, level start < 1s)

### Step 6.4 — Analytics Hooks
- [ ] Create `lib/core/analytics/analytics_tracker.dart` (abstract interface)
- [ ] Instrument key events: session start/end, word introduced, mastery change, mini-game result, streak update
- [ ] MVP: local logging or no-op implementation

### Step 6.5 — Accessibility
- [ ] Larger text mode toggle (UI exists, not wired to TextTheme)
- [ ] Dyslexia-friendly font toggle (OpenDyslexic) — UI toggle exists but is currently a no-op; deferred to post-beta
- [x] Voice playback on all learning cards (TTS implemented)
- [ ] Verify contrast ratios and tap target sizes

---

## Beta Release Checklist (0.9.0+1)

### Done
- [x] Version bumped to 0.9.0+1
- [x] `privacy.md` drafted with COPPA / Apple Kids / Google Play Families compliance
- [x] Privacy contact email: needforge.dev@gmail.com
- [x] Backup raw JSON files removed from repo root
- [x] All word images shipped (3,523, 100% coverage)
- [x] No mock/fake/static data in lib/ (verified: 0 TODOs, 0 prints, 0 network images)

### Required before TestFlight / Play Console submission
- [ ] Host `privacy.md` at public GitHub URL (raw.githubusercontent or blob URL) and add link to store consoles
- [ ] Confirm app icons render correctly (`flutter_launcher_icons` configured for all platforms)
- [ ] Store metadata: screenshots, age rating questionnaire, content rating

### Deferred to post-beta
- [ ] Wire dyslexia font toggle to actual font (currently no-op)
- [ ] Crash reporting (Sentry/Crashlytics)
- [ ] Boss challenges (every 5th level)
- [ ] Tutorial level
- [ ] Test coverage
- [ ] Analytics hooks
- [ ] UI feedback sounds (correct/incorrect)

---

## Dependency Map

```
Phase 1.1 (Manifests) ──→ Phase 1.3 (DB Seed)
Phase 1.2 (Models) ──────→ Phase 1.4 (Repos) ──→ Phase 3 (Providers) ──→ Phase 4 (Wire Screens)
                          ↗
Phase 2.1 (Mastery) ─────→ Phase 2.3 (Questions) ──→ Phase 4.4 (Mini-games)
Phase 2.2 (SRS) ─────────→ Phase 2.5 (Session) ───→ Phase 4.3 (Learn Flow)
Phase 2.4 (Difficulty) ──→ Phase 4.7 (Settings)

Phase 5 (Assets/Audio) can run in parallel with Phases 3-4
Phase 6 (Polish/Tests) after Phase 4 is complete
```

## Recommended Execution Order

| Priority | Step | Description | Depends On |
|----------|------|-------------|------------|
| 1 | 1.1 | Generate content manifests from raw JSON | Raw JSON file |
| 2 | 1.2 | Create domain model classes | — |
| 3 | 1.3 | Set up local database + seed loader | 1.1, 1.2 |
| 4 | 1.4 | Build repository layer | 1.2, 1.3 |
| 5 | 2.1 | Build mastery engine | 1.2 |
| 6 | 2.2 | Build review scheduler | 1.2, 2.1 |
| 7 | 2.3 | Build question engine | 1.4, 2.1 |
| 8 | 2.4 | Build adaptive difficulty | 2.1, 2.3 |
| 9 | 2.5 | Build session manager | 2.1-2.4, 1.4 |
| 10 | 3.1 | Create Riverpod providers | 1.4, 2.1-2.5 |
| 11 | 4.1 | Wire onboarding flow | 3.1 |
| 12 | 4.2 | Wire home & campaign | 3.1 |
| 13 | 4.3 | Wire learn flow | 3.1, 2.5 |
| 14 | 4.4 | Wire mini-games | 3.1, 2.3 |
| 15 | 4.5 | Wire level complete & rewards | 3.1 |
| 16 | 4.6 | Wire vault & word detail | 3.1 |
| 17 | 4.7 | Wire parent dashboard & settings | 3.1 |
| 18 | 5.1-5.2 | Assets & audio (parallel track) | — |
| 19 | 6.1-6.5 | Polish, testing, accessibility | 4.x |
