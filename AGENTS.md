# AGENTS.md

## Project

Voxlab — gamified public-speaking trainer. Single Flutter package (no monorepo), light-theme Material 3 app backed by a REST API at `https://tvoxlab.tech/api/v1` (`lib/core/constants/app_constants.dart`). UI copy is Spanish.

## Commands

```sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # codegen
flutter analyze
flutter test            # single file: flutter test test/widget_test.dart
```

After touching `lib/domain/models/*` (freezed/json_serializable): codegen -> analyze -> test, in that order.

## Testing the tabs

- `test/tabs_smoke_test.dart` renders **every tab** (mapa, práctica, analizar, perfil) with fixture providers at 390x844 and 320x700, asserting no layout exception and checking real content/logic (filtering, empty states, no raw type strings). Run it after touching any screen: it is what catches responsive overflows.
- `test/golden/tab_screens_golden_test.dart` captures the full tab screens for design review; read the PNGs from `test/golden/goldens/` when changing shared styles.
- Provider overrides needed for those tests: `tracksProvider` (fixtures), `progressNotifierProvider` (fake notifier with `List<Progress> build()`), `authProvider` (a real `AuthNotifier` built with fake repo/storage/api — its constructor requires non-null dependencies).
- `test/fixtures/map_fixtures.dart` must build `ExerciseContent` matching the exercise `type`: screens derive filter chips and XP from the parsed content, not the raw string.

## Known state

- `flutter test` passes (smoke test + auth widget tests).
- `flutter analyze` reports ~70 info-level issues as baseline (strict lint set in `analysis_options.yaml`). Match the lints on new code; don't mass-reformat unrelated files.
- **Mapa unificado** (Fase 3): `/track`, `/module`, `/lesson` routes eliminados; `TrackDetail`/`ModuleDetail`/`LessonList` pantallas borradas; tap en nodo de lección va directo al primer ejercicio pendiente; píldora UNIDAD es header sin navegación; scroll automático al nodo actual al cargar.
- **Errores user-friendly** (Fase 1): ErrorView con mensajes totales en español, `main.dart` con fallback styled en release, `friendlyErrorMessage()` centralizado.
- **Registro defensivo** (Fase 2): `_parseAuthResponse` tolerante + error amigable, catch visible en banner, validador de email estricto, tests de registro con fake repo (4 casos).
- Para desarrollo local con Docker: `cd backend && docker compose up -d backend`, luego `flutter run --dart-define=API_BASE_URL=http://<ip-pc>:3000/api/v1` (o `adb reverse tcp:3000 tcp:3000` + `127.0.0.1`). `usesCleartextTraffic="true"` habilitado en AndroidManifest para http://.

## Codegen facts

- `*.freezed.dart` / `*.g.dart` are committed. Never hand-edit; never delete.
- Only freezed/json_serializable codegen exists (`build_runner`). Riverpod codegen deps were removed — providers are always written manually (`Provider`, `Notifier` style in `presentation/shared/providers/`).

## Architecture

Layers, dependencies point inward:

- `lib/core/` — theme, go_router setup, dio network client (+ auth interceptor), secure storage
- `lib/domain/` — freezed models, repository interfaces (`i_*`); no Riverpod here
- `lib/data/` — dio services per endpoint + repository impls
- `lib/presentation/features/<feature>/` — screens/widgets per feature; cross-feature Riverpod state lives in `presentation/shared/providers/`

Non-obvious wiring:

- All route paths in one place: `core/router/routes.dart`. Tabs: `/map` (Aprender), `/practice`, `/analyze`, `/profile` — all inside the `ShellRoute` with `app_shell.dart` bottom `NavigationBar`. There is no `/home` route anymore.
- **Authentication is mandatory**: `AuthGuard.check` redirects every unauthenticated navigation to `/auth-wall` (no guest mode). Splash sends unauthenticated users to the wall; logout lands there too.
- Progression is **local-only**: points/completed exercises persist through `data/local/local_progress_store.dart` (JSON blob in secure storage). There is no progress endpoint anymore — do not reintroduce server-side progress calls. `ProgressNotifier` watches the signed-in user id from `authProvider` and reloads that user's entries; auth code never touches progress directly.
- Exercise types (reading/quiz/writing/oratory) are dispatched by `presentation/shared/widgets/exercise_widget_factory.dart` — add new exercise types there. Type labels/icons helpers live in `utils/exercise_name_utils.dart`. Exercises complete with an `ExerciseOutcome` (score + optional `SessionResult`).
- Writing exercises call the backend AI (`POST /exercises/analyze-text`, see `data/remote/services/analyzer_service.dart`) and complete with the real AI score; on analyzer failure they degrade to the heuristic points. Quiz/reading/oratory have no AI endpoint yet (heuristic `SessionResultBuilder.fromScore`) — backend gaps are marked with `TODO(backend)` comments.
- Session results screen consumes `domain/models/session_result.dart`. `SessionResult.fromJson` maps the analyzer envelope (`{success, data: {score, score_breakdown, feedback,...}}`); `SessionResultBuilder.fromScore` is the offline fallback — do not scatter fallback logic across UI.
- Reusable design components live in `presentation/shared/widgets/` (`ScoreRing`, `SkillBar` + `scoreColor()`, `InsightCard`, `PillBadge`, `FeedbackBanner`). Prefer them over hand-rolling rings/bars/badges.

## Theme / design system

Single source: `core/constants/app_theme.dart` (`AppTheme.light`, `useMaterial3: true`) + `core/constants/app_colors.dart`. VoxLab warm palette: orange background `#F4A221`, intense red accent/borders `#D93B27`, dark brown text `#5C3A21`, success green `#3ECF6E`, white surfaces. Fonts: DM Sans via google_fonts, **bundled in `assets/fonts/`** (see Fonts below). Always consume theme colors/components — no hardcoded hexes (the only sanctioned exceptions live inside map widgets, e.g. the white connector dashes).

## Map path (FASE 3 + redesign)

- `features/map/widgets/map_geometry.dart` is the **single source of layout math** (`nodeDiameter`, `nodeSpacing`, `amplitude`, `labelZone`, `centers()`, `height()`). Layout (`Positioned` nodes) and painting (`PathConnectorPainter`) both consume it — never position nodes with `Transform`/`Column` stacking or hand-rolled math, that is what previously made connector lines drift away from nodes and overflow unit headers.
- Nodes are rendered inside a `Stack` sized by `MapGeometry.height()`; the painter receives the same centers plus `nodeRadius`.
- `PathNodeState` styling: completed = green border + check badge, current = red border + glow + voxi badge + name label (only the current node is labelled), pending = white node, muted brown border/icon. **No lock icons** (MVP: no gating).
- `UnitBanner` is a horizontal banner (number badge + full title); its border/shadow follow the unit state (green when completed, red otherwise). Tapping a banner scrolls to that unit's first node.

## Fonts and golden tests

- DM Sans variants are **bundled** (`assets/fonts/DMSans-*.ttf`, declared under family `DMSans` in `pubspec.yaml`) so `google_fonts` resolves them from the asset manifest — the app works offline and no runtime fetch happens.
- Golden tests live in `test/golden/` and use `golden_fonts.dart::loadGoldenFonts()` from `setUpAll`. `flutter test` runs the tester with `--disable-asset-fonts`/`--use-test-fonts`, so:
  - `MaterialIcons` must be registered with `FontLoader` or every `Icon` renders as a missing-glyph box;
  - `google_fonts` runtime fetching must stay disabled;
  - the first testWidgets run that uses a heavy weight lays text out before the font resolves and renders blocky fallback glyphs — keep the `warm up text pipeline` first test.
- Capture goldens on `find.byType(MaterialApp)` (full screen): capturing the widget alone composites its transparent background onto white and hides white-on-orange details.
- Call `settleImages(tester)` before every `expectLater`: `pumpAndSettle` drains frames but not the real async asset decode, so the first test of a run captures blank images. The Voxi mascot PNGs are also cropped to a tight 512x512 square, otherwise they render as an invisible smudge at 24-48px.
- Regenerate with `flutter test test/golden --update-goldens`. Map states covered: fresh / mid / all completed / narrow (320px).

## Direction (decided by product owner)

MVP: users pick and run exercises freely — map path is informative only (no locks, no gating). **Authentication is mandatory** (guest mode removed by product decision; the backend `tvoxlab.tech` is unreachable from the current institutional network, so auth flows can't be live-tested here). **All progression data (XP, completed exercises, weekly chart) is computed and persisted locally** via `data/local/local_progress_store.dart`. Content, exercise scores and the AI session analysis (writing only, via `POST /exercises/analyze-text`) come from the backend; results map through `SessionResult` (see above). Backend gaps carry `TODO(backend)` comments for whoever picks them up.

## Conventions

- Conventional commits (`feat(ui):`, `fix(progress):`).
- Project skills for Flutter/Dart/testing live in `.agents/skills/` (indexed in `.atl/skill-registry.md`).
