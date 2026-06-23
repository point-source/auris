// Test bootstrap auto-discovered by `flutter_test` for every test under `test/`.
//
// It loads the bundled Auris fonts ONCE per test process so glyphs render as
// real type instead of Ahem blocks — the golden suite under `test/golden/`
// depends on this. The font list lives in `support/font_loader.dart` so it
// cannot drift from `pubspec.yaml` across the goldens, the render harness, and
// the README gallery renderer.
//
// We load the package fonts by their `packages/auris/...` family names (how the
// theme references them) via [loadAurisFonts] rather than `golden_matrix`'s
// `loadAppFonts`, which keys off the unprefixed manifest names the theme does
// not use.
import 'dart:async';

import 'support/font_loader.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await loadAurisFonts();
  return testMain();
}
