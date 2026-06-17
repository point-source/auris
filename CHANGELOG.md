# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.1]

- Fix the `repository` / `homepage` URLs to the correct `point-source` org
  (was `PointSource`, a different GitHub handle). pub.dev rewrites the README's
  relative image paths against `repository`, so the wrong owner 404'd every
  gallery image on the package page.

## [0.1.0]

Initial release.

- `AurisTheme.dark()` / `AurisTheme.light()` — a fully specified Material 3
  `ThemeData` that re-skins every standard widget in the warm amber-on-near-black,
  chamfered sci-fi aesthetic, with complete component-theme coverage verified by a
  census.
- `auris_widgets.dart` — a library of standalone HUD widgets (panels, badges,
  stat cards, segmented meters, chamfered toggles, terminals, ornaments).
- Customization via `accent`, `bevelScale`, and `glowScale` overrides that
  propagate through both the themed Material widgets and the custom widgets from
  one resolved `AurisScheme`.
- Bundled fonts with graceful platform fallback, AA-contrast accessibility, and
  reduced-motion support.
