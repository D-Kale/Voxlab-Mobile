# AGENTS.md

## Project

Voxlab — gamified public-speaking trainer. Single Flutter package (no monorepo), dark-only Material 3 app backed by a REST API at `https://tvoxlab.tech/api/v1` (`lib/core/constants/app_constants.dart`). UI copy is Spanish.

## Commands

```sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # codegen
flutter analyze
flutter test            # single file: flutter test test/widget_test.dart
```

After touching `lib/domain/models/*` (freezed/json_serializable): codegen -> analyze -> test, in that order.

## Known state

- `flutter test` passes (smoke test wraps `VoxlabApp` in `ProviderScope`).
- `flutter analyze` reports ~70 info-level issues as baseline (strict lint set in `analysis_options.yaml`). Match the lints on new code; don't mass-reformat unrelated files.

## Codegen facts

- `*.freezed.dart` / `*.g.dart` are committed. Never hand-edit; never delete.
- Only freezed/json_serializable codegen exists (`build_runner`). Riverpod codegen deps were removed — providers are always written manually (`Provider`, `Notifier` style in `presentation/shared/providers/`).

## Architecture

Layers, dependencies point inward:

- `lib/core/` — theme, go_router setup, dio network client (+ auth interceptor), secure storage
- `lib/domain/` — freezed models, repository interfaces (`i_*`), usecases
- `lib/data/` — dio services per endpoint + repository impls
- `lib/presentation/features/<feature>/` — screens/widgets per feature; cross-feature Riverpod state lives in `presentation/shared/providers/`

Non-obvious wiring:

- All route paths in one place: `core/router/routes.dart`. Tabs: `/map` (Aprender), `/practice`, `/analyze`, `/profile` — all inside the `ShellRoute` with `app_shell.dart` bottom `NavigationBar`. There is no `/home` route anymore.
- Progression is **local-only**: points/completed exercises persist through `data/local/local_progress_store.dart` (JSON blob in secure storage). There is no progress endpoint anymore — do not reintroduce server-side progress calls.
- The router passes a hardcoded `0` as `completedCount` to `AuthGuard.check`, disabling the guest wall-at-2-completions gate without touching auth machinery. Revert that one line to re-enable it.
- Exercise types (reading/quiz/writing/oratory) are dispatched by `presentation/shared/widgets/exercise_widget_factory.dart` — add new exercise types there. Type labels/icons helpers live in `utils/exercise_name_utils.dart`.
- Session results screen consumes `domain/models/session_result.dart`. `SessionResultBuilder.fromScore` is the single integration point: swap its heuristic for the backend AI analysis when that endpoint exists — do not scatter fallback logic across UI.
- Reusable design components live in `presentation/shared/widgets/` (`ScoreRing`, `SkillBar` + `scoreColor()`, `InsightCard`, `PillBadge`, `FeedbackBanner`). Prefer them over hand-rolling rings/bars/badges.

## Theme / design system

Single source: `core/constants/app_theme.dart` (`AppTheme.light`, `useMaterial3: true`) + `core/constants/app_colors.dart`. Light cream palette (bg `#FAF7EF`, violet primary `#7C3AED`, green `#3ECF6E`, amber `#F59E0B`) matching approved Duolingo-style reference designs. Fonts: DM Sans via google_fonts. Always consume theme colors/components — no hardcoded hexes (the only sanctioned exceptions live inside map widgets: the 3D-edge greens).

## Direction (decided by product owner)

MVP: users pick and run exercises freely — map path is informative only (no locks, no gating). **Auth layer stays as-is** (backend `tvoxlab.tech` is unreachable from the current institutional network — don't rip it out, don't extend it). **All progression data (XP, completed exercises, weekly chart) is computed and persisted locally** via `data/local/local_progress_store.dart`. Leaderboard was removed entirely. Content, exercise scores and the (future) AI session analysis come from the backend; session results map through `SessionResultBuilder` (see above). Next focus: polish + wiring the real analysis endpoint.

## Conventions

- Conventional commits (`feat(ui):`, `fix(progress):`).
- Project skills for Flutter/Dart/testing live in `.agents/skills/` (indexed in `.atl/skill-registry.md`).
