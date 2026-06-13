# Auris — Roadmap

<!-- Sections in build-dependency order. Earlier sections validate -->
<!-- assumptions later sections depend on. Completed work leaves from -->
<!-- the head; new work enters at the tail. -->

## Customization

Surface the resolver's override inputs publicly and prove they propagate, now
that the scheme seam already accepts them and all widgets read the scheme.

### §road:customization-api

Expose optional accent/bevel/glow override parameters on `AurisTheme.light()`
(defaults reproduce the canonical look) that pass through to the scheme resolver
in `lib/src/theme.dart`, and confirm every Material component theme and custom
widget honors them. §spec:customization.

### §road:customization-showcase

Add a showcase control demonstrating a non-default accent applied consistently
across themed Material widgets and Auris custom widgets in
`example/lib/main.dart`. §spec:customization, §spec:showcase. Depends on
§road:customization-api.

**Verify:** In the example, switch the demo to a non-default accent. Both
Material components and Auris custom widgets recolor consistently with no source
edits; bevel and glow overrides visibly change corner cut and glow strength.

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
