# Word Key Quest - Flutter Product Spec

## 1. Product Summary

`Word Key Quest` is a mobile and tablet vocabulary game for children ages 6-13.

The product uses:

- a target campaign of `3,500` core words
- human-style `memoryKey` cues
- photorealistic word images generated from `nanoBananaPrompt`
- short `kidsMeaning` explanations
- light game progression, rewards, and collection mechanics

The app should feel like an adventure game with learning hidden inside the loop.

The cleaned source currently contains `3,523` words. Product structure:

- `3,500` words in the main campaign
- `23` bonus words in a `Bonus Vault` after campaign completion

## 2. Product Goals

### Primary Goals

- Help children steadily master a very large vocabulary without feeling like they are doing exam prep.
- Make each word easy to remember through cue-based memory keys, not long stories.
- Work well for short daily sessions on phones and tablets.
- Support long-term retention through hidden spaced repetition.

### Secondary Goals

- Make the experience collectible, replayable, and themeable.
- Support parent visibility without turning the app into a dashboard-first product.
- Reuse the existing word pipeline with minimal manual rework.

### Non-Goals

- Open chat or social networking
- Real-money gambling loops or random loot pressure
- Long reading-heavy lesson screens
- Free typing as the primary interaction for younger children

## 3. Audience

### Core Age Bands

- `6-8`: image-first, shorter sessions, heavier audio support
- `9-11`: standard campaign pace, more sentence-based play
- `12-13`: faster unlock pace, deeper synonym/antonym and challenge play

### Parent/User Context

- A parent usually sets up the app.
- The child uses it independently after setup.
- Sessions are typically `5-10` minutes.

## 4. Design Principles

- `Cue first`: the memory key is the main recall anchor.
- `Image supports cue`: the image reinforces the memory key and meaning together.
- `One clear action per screen`: reduce cognitive overload for younger children.
- `Short wins`: every session should end with visible progress.
- `Theme without stereotypes`: themes should be selectable by any child and not locked by gender.

## 5. Content Structure

### Campaign Structure

- `35 worlds`
- `10 levels per world`
- `10 words per level`
- `100 words per world`
- `3,500` campaign words total

### Bonus Structure

- `1 Bonus Vault`
- `23 bonus words`
- unlocked after campaign completion or by parent setting

### Per-Word Content Fields

- `sourceRank`
- `word`
- `partOfSpeech`
- `pronunciation`
- `barronsMeaning`
- `kidsMeaning`
- `cueType`
- `cue`
- `memoryKey`
- `nanoBananaPrompt`
- `synonyms`
- `antonyms`
- `usage1Simple`
- `usage2Standard`
- `confusableWith`

### Per-Level Structure

- `10 new words`
- `2-4` review words from prior levels
- `1` level boss challenge using mixed review

## 6. Core Product Loop

1. Child opens the app.
2. Home screen recommends one next level and one daily review set.
3. Child enters a level.
4. For each new word:
   - hear the word
   - see the image
   - hear/read the memory key
   - see the simple meaning
5. Child completes mini-games using those words.
6. Rewards unlock:
   - stars
   - keys
   - badges
   - theme cosmetics
7. Review words return later through hidden spaced repetition.

## 7. Theming and Graphics

### Recommendation

Do not ship a "boys theme" and "girls theme" as separate product lanes.

Ship a shared core style and let every child choose from adventure packs.

### Visual Strategy

Use two visual layers:

- `UI layer`: soft stylized storybook game art
- `word image layer`: realistic conceptual images generated from the prompt pipeline

This keeps the game world playful while preserving the effectiveness of the current realistic word-image workflow.

### Launch Theme Packs

#### 1. Sky Heroes

- mood: brave, bright, energetic
- visuals: capes, floating islands, city skylines, glowing badges
- palette: blue, red, gold, white
- reward motif: stars, shields, energy keys

#### 2. Enchanted Kingdom

- mood: magical, elegant, cozy
- visuals: castles, lanterns, gardens, friendly creatures, moonlit paths
- palette: violet, teal, pink, silver, warm cream
- reward motif: gems, crowns, moon keys, magical ribbons

#### 3. Explorer Quest

- mood: discovery, maps, treasure, travel
- visuals: forests, caves, balloons, maps, artifacts
- palette: green, amber, coral, sky blue
- reward motif: compass tokens, map pieces, treasure keys

### Theme Rule

Every child can select any theme pack. Nothing is gender-locked.

### Character/Avatar Style

- rounded silhouettes
- expressive faces
- non-scary proportions
- wide range of skin tones, hair styles, assistive devices, clothing styles
- no hypersexualized or overly mature styling

### UI Style

- portrait-first
- large tap targets
- chunky cards
- strong icon support
- low text density
- subtle motion, not constant motion

### Word Card Art Rule

Word cards should use:

- square `1:1` realistic conceptual images
- real humans where relevant
- one focal action
- slight abstraction
- no text overlays

## 8. Progression and Retention Systems

### Mastery Model

Each word has mastery from `0-5`.

- `0`: unseen
- `1`: introduced
- `2`: recognized
- `3`: recalled from cue
- `4`: used in context
- `5`: mastered

### Review Timing

- same day
- 1 day
- 3 days
- 7 days
- 14 days
- 30 days
- 60 days

The child should see this as "quests" and "revisits", not as a spaced repetition interface.

### Difficulty Control

The app adjusts per child:

- fewer new words if accuracy drops
- more review if cue recall is weak
- more sentence play if recognition is strong

## 9. Game Modes

### A. Story Campaign

Main progression across all `35` worlds.

### B. Daily Quest

- `5-15` quick review prompts
- extra rewards
- good for streak retention

### C. Word Vault

- browse unlocked words
- replay memory key
- replay audio
- see image and examples

### D. Boss Challenge

Appears every `5` levels.

- mixed recognition + recall
- unlocks cosmetic rewards

### E. Bonus Vault

Contains the remaining `23` words and optional challenge content.

## 10. Mini-Games

Launch with only four.

### 1. Image Match

- prompt: word or meaning
- action: pick the right image from 3
- best for ages 6-8

### 2. Meaning Tap

- prompt: word
- action: pick the correct `kidsMeaning`
- 3 choices

### 3. Cue Recall

- prompt: cue or memory key fragment
- action: pick the correct word
- most important for long-term retention

### 4. Sentence Fix

- prompt: short sentence with blank
- action: choose the right word
- teaches usage without heavy typing

## 11. Economy and Rewards

### Reward Types

- stars: level score
- keys: unlock next nodes
- badges: milestones
- stickers/outfits/pets/room props: cosmetic collection

### Reward Design Rules

- reward consistency more than volume
- no punishing loss states
- no paid power advantage
- no variable-ratio monetization loop for children

## 12. Onboarding Flow

- splash
- parent gate
- child profile setup
- age band selection
- avatar selection
- theme selection
- tutorial level with 3 words
- campaign unlock

## 13. Screen-by-Screen Wireframes

These are low-fidelity wireframes for implementation planning, not final visual design.

### 13.1 Splash Screen

Purpose: branding and preload

```text
+--------------------------------------------------+
|                  WORD KEY QUEST                  |
|            [animated key + star logo]           |
|                                                  |
|                  Loading...                      |
+--------------------------------------------------+
```

### 13.2 Parent Gate

Purpose: keep setup/settings behind adult access

```text
+--------------------------------------------------+
| Parents only                                     |
| Tap the number that is larger:                   |
|                                                  |
|            [ 12 ]      [ 19 ]                    |
|                                                  |
|                    [Continue]                    |
+--------------------------------------------------+
```

### 13.3 Child Profile Setup

Purpose: basic personalization

```text
+--------------------------------------------------+
| Create Player                                    |
| [Avatar preview]                                 |
| Name: [__________]                               |
| Age:  [ 6 v ]                                    |
|                                                  |
|            [Next]                                |
+--------------------------------------------------+
```

### 13.4 Theme Selection

Purpose: choose one of the adventure packs

```text
+--------------------------------------------------+
| Pick Your Adventure Style                        |
|                                                  |
| [Sky Heroes]   [Enchanted Kingdom]               |
| [Explorer Quest]                                 |
|                                                  |
|        [Preview]          [Choose]               |
+--------------------------------------------------+
```

### 13.5 Home Screen

Purpose: primary hub

```text
+--------------------------------------------------+
| Player  Lv 12   Streak 7   Stars 1430            |
|--------------------------------------------------|
| Continue Journey                                 |
| [World 4 - Level 7: Ready to play]               |
|                                                  |
| Daily Quest                                      |
| [8 review words waiting]                         |
|                                                  |
| Bottom Nav: Home | Map | Vault | Rewards | More  |
+--------------------------------------------------+
```

### 13.6 World Map

Purpose: macro progression

```text
+--------------------------------------------------+
| World 4: Cloud City                              |
|                                                  |
|   o--o--O--o--B                                  |
|   1  2  3  4  Boss                               |
|                                                  |
| [Story preview art]                              |
|                                                  |
| [Back]                              [Enter]      |
+--------------------------------------------------+
```

### 13.7 Level Intro

Purpose: show rewards and the word batch

```text
+--------------------------------------------------+
| Level 4-7                                        |
| New Words: 10                                    |
| Review Words: 3                                  |
| Reward: 3 stars + 1 silver key                   |
|                                                  |
| [Start Level]                                    |
+--------------------------------------------------+
```

### 13.8 Learn Card

Purpose: introduce one word

```text
+--------------------------------------------------+
| WORD: ABATE                     [speaker icon]   |
| /uh-BAYT/                                         |
|                                                  |
| [Square realistic image]                         |
|                                                  |
| Kids meaning: go down or become less             |
| Memory key: sounds like rebate                   |
|                                                  |
| [Hear Memory Key]      [Next]                    |
+--------------------------------------------------+
```

### 13.9 Memory Key Focus Screen

Purpose: isolate the cue before quiz play

```text
+--------------------------------------------------+
| Cue: rebate                                      |
|                                                  |
| "A price becomes less after a rebate."           |
| "So abate means become less."                    |
|                                                  |
| [Replay]                    [Got it]             |
+--------------------------------------------------+
```

### 13.10 Image Match

Purpose: recognition using image support

```text
+--------------------------------------------------+
| Which picture shows "abate"?                     |
|                                                  |
| [img 1]   [img 2]                                |
| [img 3]                                          |
|                                                  |
|                    [Submit]                      |
+--------------------------------------------------+
```

### 13.11 Meaning Tap

Purpose: meaning recognition

```text
+--------------------------------------------------+
| ABHOR                                            |
| Pick the best meaning                            |
|                                                  |
| [to hate]                                        |
| [to jump]                                        |
| [to hide]                                        |
+--------------------------------------------------+
```

### 13.12 Cue Recall

Purpose: test memory key retrieval

```text
+--------------------------------------------------+
| Cue: "a bore"                                    |
| Which word matches this cue?                     |
|                                                  |
| [abhor]                                          |
| [abate]                                          |
| [abide]                                          |
+--------------------------------------------------+
```

### 13.13 Sentence Fix

Purpose: test practical use

```text
+--------------------------------------------------+
| The loud noise began to ______ after sunset.     |
|                                                  |
| [abate]  [abhor]  [abduct]                       |
+--------------------------------------------------+
```

### 13.14 Level Complete

Purpose: reward loop

```text
+--------------------------------------------------+
| Level Complete                                   |
| Stars earned: ***                                |
| Words mastered: 4                                |
| Reward unlocked: Hero Cape / Moon Gem            |
|                                                  |
| [Continue]                [Replay]               |
+--------------------------------------------------+
```

### 13.15 Reward Room

Purpose: cosmetic collection and motivation

```text
+--------------------------------------------------+
| Rewards Room                                     |
| [Avatar]  [Pet]  [Room]  [Theme Items]           |
|                                                  |
| New Unlock: Silver Key Banner                    |
|                                                  |
| [Equip]                     [Back]               |
+--------------------------------------------------+
```

### 13.16 Word Vault

Purpose: browse learned words

```text
+--------------------------------------------------+
| Search [___________]                             |
| Filters: Learned | Review | Mastered             |
|--------------------------------------------------|
| ABATE        Lv 4 mastery                        |
| ABHOR        Lv 3 mastery                        |
| ABERRANT     Lv 2 mastery                        |
+--------------------------------------------------+
```

### 13.17 Word Detail

Purpose: complete view for one word

```text
+--------------------------------------------------+
| ABERRANT                                         |
| /uh-BER-uhnt/                                    |
| [image]                                          |
| kidsMeaning: not normal                          |
| memoryKey: a bear rant                           |
| synonyms: abnormal; unusual                      |
| antonyms: normal; usual                          |
| usage: One aberrant result stood out.            |
|                                                  |
| [Hear]   [Practice]   [Back]                     |
+--------------------------------------------------+
```

### 13.18 Daily Quest

Purpose: recurring short session

```text
+--------------------------------------------------+
| Daily Quest                                      |
| 8 words ready                                    |
| Reward: 1 gold key + streak flame                |
|                                                  |
| [Start Quest]                                    |
+--------------------------------------------------+
```

### 13.19 Parent Dashboard

Purpose: adult visibility and controls

```text
+--------------------------------------------------+
| Parent Dashboard                                 |
| Words learned: 286                               |
| Mastered: 91                                     |
| Accuracy: 82%                                    |
| Time today: 11 min                               |
|                                                  |
| [Adjust difficulty] [Theme] [Export progress]    |
+--------------------------------------------------+
```

### 13.20 Settings

Purpose: app and accessibility controls

```text
+--------------------------------------------------+
| Settings                                         |
| Music        [on/off]                            |
| Voice        [on/off]                            |
| Text size    [small/med/large]                   |
| Dyslexia font [on/off]                           |
| Theme        [change]                            |
+--------------------------------------------------+
```

## 14. Flutter Technical Spec

### Target Platforms

- iPhone
- iPad
- Android phones
- Android tablets

### Orientation

- primary: portrait
- optional later: limited tablet landscape for the Vault and Parent Dashboard

### App Architecture

Use a clean layered architecture:

- `presentation`
- `application`
- `domain`
- `data`

### Suggested Project Structure

```text
lib/
  app/
    app.dart
    router.dart
    theme/
  core/
    audio/
    storage/
    analytics/
    accessibility/
    widgets/
  features/
    onboarding/
    home/
    campaign/
    learn/
    minigames/
    vault/
    rewards/
    parent/
    settings/
  data/
    models/
    repositories/
    local_db/
    seed/
```

### State Strategy

Use unidirectional state flow. Keep feature state isolated by module:

- onboarding state
- campaign progression state
- current session state
- word mastery state
- theme/cosmetic state
- parent settings state

### Data Storage

Use offline-first local storage.

Store:

- child profile
- theme selection
- unlocked progression
- word mastery
- review schedule
- local asset references

### Recommended Runtime Data Objects

#### WordEntry

- id
- sourceRank
- word
- partOfSpeech
- pronunciation
- barronsMeaning
- kidsMeaning
- cueType
- cue
- memoryKey
- imageAssetOrUrl
- synonyms[]
- antonyms[]
- usage1Simple
- usage2Standard
- confusableWith
- worldIndex
- levelIndex

#### WordProgress

- wordId
- masteryLevel
- timesSeen
- timesCorrect
- lastSeenAt
- nextReviewAt
- isUnlocked

#### PlayerProfile

- id
- name
- ageBand
- avatarId
- selectedTheme
- currentWorld
- currentLevel
- streakCount
- stars
- keys

### Content Ingestion Pipeline

Seed the app from the workbook/CSV export.

Preprocess into:

- `words.json`
- `worlds.json`
- `levels.json`
- `reward_catalog.json`

### Audio

Each word should support:

- word pronunciation audio
- optional memory key narration audio
- short success/failure feedback sounds

### Image Strategy

- keep images local after pack download or bundle them by world
- lazy-load by level to keep initial app size manageable

### Performance Targets

- app launch under `3s` on modern mid-tier devices
- level start under `1s` after assets are local
- memory use stable during mini-games

## 15. Accessibility

- tap targets at least tablet-friendly and child-friendly
- optional larger text mode
- optional dyslexia-friendly font
- color contrast safe for children
- voice playback on all learning cards
- avoid requiring keyboard typing for core progression

## 16. Safety and Privacy

- no open messaging
- no public profiles
- no ads inside the learning loop
- no manipulative countdown pressure
- parent gate for settings and exports
- minimal personal data collection

## 17. Analytics to Track

- daily active players
- session length
- words introduced per day
- words mastered per week
- mini-game accuracy by type
- most-missed words
- cue recall success rate
- review completion rate
- theme selection rate

## 18. MVP Definition

### MVP Scope

- all `3,500` campaign words mapped into `35` worlds
- bonus vault structure for `23` extra words
- onboarding
- home
- map
- learn card
- 4 mini-games
- rewards
- vault
- parent dashboard
- theme selection with `3` theme packs

### Not in MVP

- multiplayer
- live events
- cloud sync
- user-generated content
- seasonal battle pass

## 19. Build Order

### Phase 1 - Foundations

- import word data
- define world/level mapping
- implement local storage
- implement app shell and navigation

### Phase 2 - Learning Core

- learn card
- audio playback
- mastery tracking
- review scheduling

### Phase 3 - Mini-Games

- image match
- meaning tap
- cue recall
- sentence fix

### Phase 4 - Progression

- world map
- reward system
- avatar/theme unlocks

### Phase 5 - Parent and Polish

- parent dashboard
- accessibility options
- analytics hooks
- content QA pass

## 20. Initialization Checklist

To initialize the Flutter app, build these first:

- router and app shell
- seed loader for the `3,500` words
- player profile model
- world/level model
- learn card screen
- one mini-game (`Meaning Tap`)
- mastery engine
- daily quest scheduler
- theme system with 3 packs

## 21. Final Recommendation

Build the product around one identity:

- `storybook adventure UI`
- `realistic cue-based word images`
- `theme packs any child can choose`

That is the cleanest match for the current content pipeline and the target age range.
