# Requirements

> Auris is a Flutter UI kit and theme system that gives apps an amber-on-black,
> chamfered "augmentation-era" sci-fi look. This document captures the problem
> space — who it is for, why it should exist, and what success means. The
> solution-space design (tokens, component themes, widget APIs) is being drafted
> in `auris-spec.md` and will be formalized into SPEC.md via `/compose:plan`.

## Problem statement §req:problem-statement

**Target users.** Flutter developers in two overlapping groups:

1. Developers who want a distinctive amber-on-near-black, chamfered sci-fi
   aesthetic (the augmentation-era HUD look popularized by early-2010s
   sci-fi games) for their app, but who do not want to design a full theme
   system themselves.
2. Developers building **data-dense dashboard, HUD, and terminal-style
   interfaces** — people who need panels, stat tiles, segmented progress
   meters, scrolling log terminals, and structured data rows, not just a
   recolored button.

**The problem.** Achieving this look today is expensive in developer time and
incomplete in result:

- Stock Material 3 is generic and carries none of this aesthetic.
- Rolling a bespoke theme means hand-re-skinning dozens of Material
  components one by one, and inevitably some slip through and render with
  default styling, breaking the illusion.
- The signature HUD components (segmented bars, terminals, chamfered glowing
  panels, targeting-reticle ornaments) do not exist in Material at all and
  must be built from scratch with custom painters and clippers.
- Existing third-party Flutter UI kits target mainstream or playful
  aesthetics; none serve this specific niche.

**Why it matters.** For the indie, hobbyist, game-tooling, and
dashboard-building Flutter audience this want recurs frequently, and building
it from scratch is a large, repetitive time sink (re-skin every widget + build
custom HUD primitives). The problem is not mandatory — it is a high-delight,
aesthetic-driven want — but it is genuinely underserved. Auris is distributed
as an **open-source package on pub.dev** so that this work is done once and
reused by everyone who wants the look.

## Success criteria §req:success-criteria

Each criterion is observable from the product's visible surface.

1. **Instant drop-in re-skin.** Adding the Auris theme to a `MaterialApp`
   re-skins every standard Material 3 widget with no further work — no
   standard widget renders with default Material styling. *Testable:* the
   showcase displays every Material widget; a reviewer confirms none look
   unstyled.
2. **Complete coverage.** A developer can build a typical app using only
   standard Material widgets and never encounter a "broken"/unstyled
   component. *Testable:* walk the showcase end to end; every component group
   is themed.
3. **Convincing, recognizable aesthetic.** A single example app visibly
   demonstrates the target look across all component groups, such that an
   evaluator can judge it before adopting. The look is verifiable against its
   signature hallmarks: angular/chamfered geometry rather than rounded
   corners; a warm amber-gold primary on near-black, paired with a cool
   secondary accent; an amber *glow* in place of Material drop shadows;
   uppercase, letter-spaced display type with monospace data readouts; and
   ornamental hex / corner-bracket detailing. *Testable:* run the example app
   and confirm each hallmark is present on the relevant sections.
4. **Customizable without forking.** A developer can change the accent color,
   corner bevel size, and glow intensity through provided knobs without
   copying or editing package source. *Testable:* construct the theme with a
   different accent and observe it propagate.
5. **Readable.** All primary text and interactive controls meet WCAG AA
   contrast against their background; intentionally dim/decorative tokens are
   exempt and documented as decorative-only. *Testable:* check key text/control
   pairings with a contrast checker.
6. **Smooth.** The showcase scrolls and animates without visible jank on a
   normal screen (target 60fps), including glow, clipping, and segmented
   widgets. *Testable:* scroll and trigger animations; observe no dropped
   frames.
7. **Clean engineering.** `flutter analyze` passes with zero warnings; the
   package has zero runtime pub dependencies; constructors are `const` where
   possible. *Testable:* run `flutter analyze`; inspect `pubspec.yaml`.
8. **Works out of the box.** The required fonts render correctly immediately
   after install with no manual font setup; if any font cannot be legally
   bundled, the kit falls back gracefully and documents the setup step.
   *Testable:* fresh install, run example, confirm fonts render.
9. **Publication-ready.** The package meets pub.dev structural expectations
   (README with installation and usage example, license, runnable example)
   such that publishing it is a non-event. *Testable:* inspect package layout
   against pub.dev requirements.

## User stories §req:user-stories

- As a Flutter developer who wants the look, I want to add **one theme** to my
  app and have all my existing Material widgets adopt the aesthetic, so I get
  the sci-fi feel without redesigning anything. *(→ criteria 1, 2)*
- As a dashboard/HUD builder, I want **ready-made HUD components** — panels,
  stat tiles, segmented progress, a scrolling terminal log, structured data
  rows — so I can assemble data-dense interfaces that match the theme. *(→ 2, 3)*
- As an adopter with product/brand needs, I want to **tweak the accent color,
  corner bevel, and glow** so the kit fits my product without forking it.
  *(→ 4)*
- As a developer evaluating the kit, I want a **single showcase app** showing
  every component so I can judge the look and coverage before committing. *(→ 3)*
- As an accessibility-conscious developer, I want **primary text and controls
  to be legible** so my app is usable, while still getting the stylized dim
  accents elsewhere. *(→ 5)*
- As a new adopter, I want **fonts to just work** after install so setup is
  genuinely drop-in. *(→ 8)*
- As a maintainer preparing to share Auris, I want the package **ready to
  publish** on pub.dev so distribution is a non-event. *(→ 9)*

## Quality attributes §req:quality-attributes

- **Performance.** 60fps scroll and animation in the showcase; glow shadows,
  clippers, and segmented bars must not cause visible frame drops on a normal
  screen. Animations respect the platform reduced-motion setting.
- **Accessibility.** Primary text and interactive controls meet WCAG AA
  contrast; intentionally dim tokens are decorative-only. All interactive
  widgets expose visible keyboard focus.
- **Customizability.** Accent color, corner bevel, and glow intensity are
  adjustable without forking the package.
- **Correctness / reliability.** Zero analyzer warnings; consistent rendering
  across the supported Flutter range.
- **Compatibility.** Flutter ≥ 3.22 / Dart ≥ 3.4, Material 3, dark theme only
  for v0.1.0; mobile-first (no web/desktop-specific adaptation in v0.1.0).
- **Footprint.** Zero runtime pub dependencies; package size kept reasonable
  given bundled fonts.

## Constraints §req:constraints

- **Purely presentational** — Auris ships no state management, routing, or
  data layer.
- **Zero runtime dependencies** — Flutter SDK only.
- **Material 3** on Flutter ≥ 3.22 / Dart ≥ 3.4.
- **Dark theme only** for v0.1.0; a light / higher-contrast variant is
  deferred.
- **Font licensing** — fonts may be bundled only if legally redistributable.
  Rajdhani, Exo 2, and Share Tech Mono are SIL Open Font License, which
  permits bundling; the kit must still degrade gracefully if a font is
  missing.
- **Scope exclusions for v0.1.0** — no localization / RTL, no web/desktop
  adaptations, no Storybook/Widgetbook integration.
- **Open-source** — distributed under the repository's existing license, aimed
  at pub.dev.

## Priorities §req:priorities

Ordered by user impact.

**Must-have (v0.1.0):**

1. Complete Material 3 widget re-skin via the theme — no widget renders
   unstyled (directly addresses the top abandonment risk).
2. Core custom HUD widgets needed for the dashboard/terminal story (panels,
   stat tiles, segmented progress, terminal, data rows, and the supporting
   primitives).
3. Customization knobs for accent color, bevel, and glow — elevated to
   must-have because "too rigid to customize" is an identified abandonment
   driver.
4. Showcase example app covering every component group.
5. WCAG AA for primary text and interactive controls.
6. 60fps performance and reduced-motion respect — "performance/jank" is an
   identified abandonment driver.
7. Zero analyzer warnings, zero runtime dependencies.
8. Fonts working out of the box (bundled where legal, graceful fallback
   otherwise).

**Should-have:**

- Publication-ready packaging (README with usage + example, pub metadata,
  license) so publishing is a non-event.

**Nice-to-have / deferred (post-v0.1.0):**

- Actual pub.dev publication.
- Light / higher-contrast theme variant.
- Localization / RTL and web/desktop-specific adaptations.
- Storybook / Widgetbook integration.
