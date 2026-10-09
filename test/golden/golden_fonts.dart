import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// Registers the fonts golden tests need. Call once from `setUpAll`.
///
/// `flutter test` runs the tester with `--disable-asset-fonts` and
/// `--use-test-fonts`, so nothing is picked up from `FontManifest.json`:
/// * `MaterialIcons` must be registered manually through [FontLoader],
///   otherwise every `Icon` renders as a missing-glyph box.
/// * `google_fonts` fonts must be bundled in `assets/fonts` (DM Sans is) with
///   runtime fetching disabled, otherwise every `GoogleFonts.*` call throws.
///
/// Fonts are loaded here rather than lazily by `google_fonts`: a font that
/// finishes loading after the first layout leaves the already laid out text
/// shaped with the blocky test font, so the first golden of a run would be
/// captured with unreadable text.
Future<void> loadGoldenFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  GoogleFonts.config.allowRuntimeFetching = false;

  Future<void> load(String family, String asset) async {
    final loader = FontLoader(family)..addFont(rootBundle.load(asset));
    await loader.load();
  }

  await load('MaterialIcons', 'fonts/MaterialIcons-Regular.otf');
  await load('DMSans-Regular', 'assets/fonts/DMSans-Regular.ttf');
  await load('DMSans-Medium', 'assets/fonts/DMSans-Medium.ttf');
  await load('DMSans-SemiBold', 'assets/fonts/DMSans-SemiBold.ttf');
  await load('DMSans-Bold', 'assets/fonts/DMSans-Bold.ttf');
  await load('DMSans-ExtraBold', 'assets/fonts/DMSans-ExtraBold.ttf');
  await load('DMSans-Black', 'assets/fonts/DMSans-Black.ttf');
}

/// Lets `Image.asset` widgets finish decoding before a golden is captured.
///
/// `pumpAndSettle` only drains frames, not the real async asset/decode work,
/// so the first test of a run captures blank images (the Voxi mascot was
/// missing from the practice golden while later tests showed it).
Future<void> settleImages(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 100)),
  );
  await tester.pumpAndSettle();
}