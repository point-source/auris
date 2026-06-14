# Auris — Roadmap

<!-- Sections in build-dependency order. Earlier sections validate -->
<!-- assumptions later sections depend on. Completed work leaves from -->
<!-- the head; new work enters at the tail. -->

## Packaging & pub-readiness

Make Auris adoptable from a clean install and ready to publish.

### §road:font-fallback

Ensure text renders in a sensible fallback when a bundled font is missing, and
document any setup needed. §spec:packaging.

### §road:analyze-clean-and-deps

Ensure `flutter analyze` passes with zero warnings (including using
`Color.withValues` over the deprecated `withOpacity`) and confirm zero runtime
pub dependencies in `pubspec.yaml`. §spec:packaging. Depends on all
implementation sections.

### §road:golden-tests

Add golden-image tests (`matchesGoldenFile`) under `test/goldens/` for the
geometry/glow-bearing custom widgets (`AurisContainer`, `AurisPanel`,
`AurisBadge`, `AurisSwitch`, `AurisProgressBar`, `AurisSelect`, `AurisRadio`,
`AurisStatCard`, `AurisStepIndicator`) so visual regressions fail CI.
§spec:showcase, §spec:custom-widgets. Depends on all implementation sections.

### §road:readme-and-gallery

Write `README.md` with an installation snippet, an `AurisTheme` usage example,
and a widget gallery (screenshot placeholder). §spec:packaging. Depends on
§road:analyze-clean-and-deps.

**Verify:** From a clean checkout, `flutter pub get` then `flutter run` the
example with no extra setup; fonts render. `flutter analyze` reports zero
warnings and `pubspec.yaml` lists no runtime dependencies beyond the Flutter
SDK. `flutter test` (including the golden-image tests) passes. The README usage
snippet matches the running example.
