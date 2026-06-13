# Auris — Specification

Auris is a Flutter UI kit and theme system for Material 3 (Flutter ≥ 3.22,
Dart ≥ 3.4) that gives an application a warm amber-on-near-black, chamfered
"augmentation-era" sci-fi appearance. It ships as two layers: a drop-in
`ThemeData` that re-skins standard Material widgets, and a library of custom
widgets for HUD patterns Material cannot express. The kit is purely
presentational — no state management, routing, or data layer.

This document is the solution-space source of truth. It describes what the
system does and why. Exact spacing, padding, and other mechanical values that
are not design-defining are owned by the implementation and its tests.

---

## Overview and architecture §spec:overview

*Status: not started*

Cites: §req:problem-statement, §req:constraints

**Problem.** Achieving the target aesthetic in Flutter today is expensive and
incomplete: stock Material 3 carries none of it; hand-rolling a theme means
re-skinning dozens of components one by one (and some always slip through,
rendering as default Material and breaking the illusion); and the signature
HUD components — segmented meters, terminals, chamfered glowing panels,
targeting-reticle ornaments — do not exist in Material at all.

**Approach.** Auris is delivered as two cooperating layers:

1. **`AurisTheme`** — a fully specified `ThemeData` returned by
   `AurisTheme.light()`. Every Material 3 component theme is populated so that
   adding the theme alone re-skins a standard app with no per-widget work.
2. **`auris_widgets`** — standalone custom widgets for patterns that
   `ThemeData` cannot express (true chamfered switch track, segmented progress,
   terminal log, hex/bracket ornaments, stat tiles).

**Rationale.** The two-layer split exists because Material's theming reaches
roughly 60% of the desired geometry through `BeveledRectangleBorder` on
component shapes, but cannot produce segmented fills, custom-clipped tracks,
or decorative painters. Rather than ship only custom widgets (forcing adopters
to rewrite their UI), the theme layer makes the common case zero-effort and
the widget library covers the rest.

**Rejected alternative.** A pure custom-widget kit (no `ThemeData`) was
rejected: it would not satisfy the "instant drop-in re-skin" success criterion
and would force adopters to replace every existing Material widget.

**Naming note.** `AurisTheme.light()` is the default and only implemented
constructor; "light" is a historical misnomer — Auris is always dark in
v0.1.0. A genuine light-background variant is an anticipated future requirement
(see §spec:scope); when it lands it will force the `light()`/`dark()` naming to
be reconsidered, since today both names describe dark themes. This is flagged
now as known debt rather than resolved, because v0.1.0 ships a single variant
and renaming ahead of need would churn the public API.

---

## Design tokens §spec:design-tokens

*Status: not started*

Cites: §req:problem-statement, §req:quality-attributes, §req:constraints

The aesthetic is defined by a single set of `const` tokens exposed via
`AurisTokens`. These values are the design contract — they are the *what* of
the look, not swappable mechanism — and no raw color or font literal appears
elsewhere in the codebase (§req:constraints, "no raw literals").

**Color palette.** Warm amber/gold primary on near-black surfaces, with a cool
slate secondary accent. The warm-primary / cool-secondary pairing is
intentional and central to the aesthetic identity.

| Role | Token | Value |
| --- | --- | --- |
| Page background | `void_` | `0xFF0A0A0C` |
| Panel surface | `panel` | `0xFF111115` |
| Inset/input surface | `panelAlt` | `0xFF16161C` |
| Resting border | `border` | `0xFF2A2510` |
| Hover/focus border | `borderBright` | `0xFF4A4020` |
| Amber (inactive/dim) | `amber` | `0xFFC8860A` |
| Gold (active/primary) | `gold` | `0xFFF0A500` |
| Bright (focus/highlight) | `bright` | `0xFFFFD060` |
| Text on dark | `brightWhite` | `0xFFF0E8D0` |
| Slate (secondary) | `slate` | `0xFF8AABB0` |
| Slate dim | `slateDim` | `0xFF4A6870` |
| Danger | `danger` / `dangerBright` | `0xFFB03020` / `0xFFE04030` |
| Success | `success` / `successBright` | `0xFF4A8A60` / `0xFF6AB880` |
| Text dim (decorative only) | `textDim` | `0xFF5A5040` |
| Text mid | `textMid` | `0xFFA09060` |
| Text bright | `textBright` | `0xFFE0C070` |

**Typography.** Three families: Rajdhani (display/headline), Exo 2 (body/label),
Share Tech Mono (data/monospace). Display and label roles are uppercase and
letter-spaced; data readouts are monospace. Tracking constants:
`trackingLabel 1.5`, `trackingHeading 1.8`, `trackingButton 1.44`,
`trackingBody 0.5`. The full type scale (display through label) maps each
Material `TextTheme` role to a family/size/weight/spacing/color, with uppercase
transforms on display, headline-large, and all label roles. Font family names
are tokens (`fontDisplay`, `fontBody`, `fontMono`), never inline strings.

**Shape.** Chamfered (45°) corners are the signature geometry. Bevel sizes:
`bevelSm 6`, `bevelMd 10` (component default), `bevelLg 14`, `bevelXl 20`
(panels/dialogs). `BeveledRectangleBorder` covers most Material components; a
`ChamferClipper` (`CustomClipper<Path>` parameterized by corner cut) covers the
rest and clips child content at the corners.

**Elevation and glow.** Material elevation shadows are replaced by amber glow,
because drop shadows read as flat/soft and conflict with the hard-edged,
luminous aesthetic. Glow levels are `BoxShadow` lists: `glowNone`,
`glowSubtle`, `glowActive` (two stacked amber blurs), plus `glowDanger` and
`glowSlate` variants. `ColorScheme.shadow` is `transparent` and component
`elevation` is `0` everywhere; depth is communicated by glow, not shadow.

**Motion.** `durationFast 120ms`, `durationNormal 200ms`, `durationSlow 350ms`;
curves `curveDefault` (easeInOut), `curveEnter` (easeOut), `curveExit`
(easeIn).

**Rationale.** Centralizing every value as a `const` token is what makes the
"no raw literals" quality bar enforceable and makes the customization layer
(§spec:customization) tractable — there is exactly one place the look is
defined.

**Anticipated change — brightness variants.** A light-background variant (and a
higher-contrast variant) is an anticipated future requirement (§spec:scope).
The token layer is therefore expected to express the palette in semantic roles
(surface, on-surface, primary, border, …) that a variant can re-resolve, rather
than as a single hard-coded set that only reads correctly on near-black. v0.1.0
ships only the dark values, but the role structure is chosen so a future
variant is an additive resolution of the same roles, not a rewrite of every
consumer. The decorative-only status of dim tokens (§spec:accessibility) is part
of this: roles carry intent, so a light variant can re-pick values per role
without auditing every call site.

---

## Theme layer — complete Material re-skin §spec:theme-layer

*Status: not started*

Cites: §req:success-criteria, §req:user-stories, §req:priorities

**Observable behavior.** When an application sets `theme: AurisTheme.light()`
on its `MaterialApp`, every standard Material 3 widget renders in the Auris
aesthetic with no further work. No standard widget renders with default
Material styling — this is the kit's top success criterion and its primary
defense against the leading abandonment risk ("widgets look broken/unstyled").

`AurisTheme.light()` returns a fully specified `ThemeData` in which every
component theme is populated; none is left at its Material 3 default. The
populated component themes are:

`ColorScheme`, `TextTheme`, `ElevatedButton`, `OutlinedButton`, `TextButton`,
`FilledButton`, `IconButton`, `FloatingActionButton`, `InputDecoration`,
`Checkbox`, `Radio`, `Switch`, `Slider`, `Chip`, `Card`, `Dialog`, `SnackBar`,
`BottomSheet`, `NavigationBar`, `NavigationRail`, `Drawer`, `AppBar`, `TabBar`,
`Tooltip`, `PopupMenu`, `ListTile`, `ExpansionTile`, `DataTable`,
`ProgressIndicator`, `Divider`, `Badge`, `DropdownMenu`, `SegmentedButton`,
`Stepper`, `SearchBar`/`SearchView`.

**Signature treatments applied across all components:**

- **Shape:** `BeveledRectangleBorder` at the appropriate bevel size on every
  shaped surface (buttons, inputs, cards, menus, indicators, nav indicators).
- **Elevation:** `0` at all states; `surfaceTintColor` transparent; depth via
  glow `decoration`, not Material elevation/shadow.
- **Ripple:** suppressed (`splashRadius: 0`) on toggles and replaced with an
  amber `overlayColor` on hover/focus/press, because the ink ripple reads as
  Material-default and breaks the aesthetic.
- **Color roles:** `gold` for active/primary, `amber` for inactive/dim,
  `borderBright` for resting outlines, `bright` for focus/highlight, semantic
  `danger`/`success` for error/confirmation.
- **Typography:** uppercase, letter-spaced display/label type; monospace for
  data-bearing surfaces (labels, data tables, tooltips, value indicators).

**Rationale and known limits.** `ThemeData` + `BeveledRectangleBorder` reaches
most components but has gaps Flutter does not expose: the `Switch` track cannot
be chamfered, and the linear `ProgressIndicator` cannot be segmented. Where a
gap degrades the aesthetic, the theme is configured as closely as possible and
a custom widget (§spec:custom-widgets) is provided as the preferred
replacement — `AurisSwitch` and `AurisProgressBar` respectively. Some Material
themes (dialog, popup, snackbar) cannot attach a glow shadow directly through
`ThemeData`; glow on those surfaces is delivered by the widget that consumes
them where it matters, and the rationale is recorded rather than the workaround
re-specified.

**Verification path.** The showcase (§spec:showcase) renders every component
above; a reviewer confirms none falls back to default Material styling.

---

## Custom widget library §spec:custom-widgets

*Status: not started*

Cites: §req:user-stories, §req:success-criteria, §req:priorities

**Observable behavior.** `auris_widgets` exports HUD components that
`ThemeData` cannot express, enabling the data-dense dashboard/terminal user
story. Each is a standalone stateless/stateful widget. Where applicable, each
supports a disabled state (opacity 0.5, no hover/focus, forbidden cursor) and
visible keyboard focus (§spec:accessibility).

| Widget | Purpose / observable behavior |
| --- | --- |
| `AurisContainer` | Foundation primitive: chamfered border + fill + optional glow, clipping its child at the corners via `ChamferClipper`. Everything else composes from it. |
| `AurisBadge` | Small text-only status tag in monospace, colored by variant (amber/gold/slate/danger/success/inactive). |
| `AurisPanel` | Titled card with a header strip, corner-bracket ornaments flanking the title, optional status code, and an `accent` mode (gold border + subtle glow). |
| `AurisNotification` | Inline alert banner with a left accent bar + matching glow, variant icon, title, and optional message/code and dismiss. |
| `AurisSwitch` | Toggle with a true chamfered track and thumb (impossible via `ThemeData`); animates thumb position and track color over `durationNormal`; optional label and on/off status labels. |
| `AurisProgressBar` | Segmented meter — N chamfered segments; filled segments use the variant color, the leading filled segment glows. `.animated` constructor tweens value changes. The preferred linear-progress replacement. |
| `AurisDataRow` | Fixed-height key/value row with a bottom divider; value in monospace, optional highlight (bright + glow) and trailing widget. |
| `AurisTerminal` | Scrolling monospace log that auto-scrolls to the newest line; line color by type (ok/error/augment/warning/normal); optional blinking block cursor. Wraps `AurisPanel`. |
| `AurisStepIndicator` | Chamfered step marker (inactive/active/complete/error) for use with `Stepper.stepIconBuilder` or standalone. |
| `AurisHexOrnament` | Non-interactive `CustomPaint` cluster of hexagons for ambient page-background detail; `IgnorePointer`. |
| `AurisScanBracket` | Targeting-reticle corner brackets around a child; optional opacity pulse on `durationSlow`. |
| `AurisStatCard` | KPI/metric tile: label, large glowing value, optional unit and signed delta (success/danger arrow + baseline suffix). |

**Rationale.** Each widget exists specifically because the corresponding effect
cannot be produced through `ThemeData` — segmented fills, custom-clipped
tracks, decorative painters, and auto-scrolling log behavior all require widget
code. Widget constructors are `const` wherever possible. Exact dimensions and
padding are owned by the implementation; the design-defining values (bevel
sizes, variant colors, glow levels) come from `AurisTokens`.

---

## Customization without forking §spec:customization

*Status: not started*

Cites: §req:success-criteria, §req:quality-attributes, §req:priorities

**Problem.** "Too rigid to customize" is an identified abandonment driver. A
fixed `const` palette forces adopters with brand needs to fork the package.

**Observable behavior.** An adopter can change the **accent color**, **corner
bevel scale**, and **glow intensity** and see the change propagate through both
the theme layer and the custom widgets, without copying or editing package
source. `AurisTheme.light()` accepts these overrides, and the custom widgets
resolve the same values from the active theme/token set rather than from
hard-wired constants, so a single override point re-skins the whole kit.

**Design.** A resolved token set (derived from `AurisTokens` defaults with the
caller's overrides applied) drives both layers. The accent override recolors
the gold/amber/bright primary ramp; the bevel override scales the
`bevelSm…bevelXl` family; the glow override scales the `glowSubtle`/`glowActive`
opacity/blur. The exact API surface (named parameters vs. a config object) is
an implementation choice, constrained to: overrides are optional, defaults
reproduce the canonical look exactly, and `const` construction remains possible
when no override is supplied.

**Rationale and boundary.** Scope is deliberately limited to accent, bevel, and
glow — the three knobs that cover the common brand-fit case — rather than full
per-token theming, which would reintroduce the complexity the kit exists to
hide. Adopters needing deeper changes still have direct `AurisTokens` access.
The cool secondary (slate) accent is not yet a customization knob; this is a
conscious v0.1.0 boundary.

---

## Accessibility and contrast §spec:accessibility

*Status: not started*

Cites: §req:quality-attributes, §req:constraints

**Observable behavior.** All primary text and interactive controls meet WCAG AA
contrast against their background. Every interactive widget exposes visible
keyboard focus (a `gold` focus decoration driven by a `FocusNode`).

**Design decision and its consequence.** The reference aesthetic is
intentionally dim and, taken literally, several token pairings fall below AA —
most notably `textDim` (`0xFF5A5040`) on `void_`. The resolution: `textDim` and
other deliberately-dim tokens are **decorative-only** and are not used for
primary or critical content; primary text uses `textBright`/`brightWhite` and
controls use the gold ramp, all of which clear AA. Where a token used for a
primary role would fail AA, that token is tuned brighter rather than the AA
requirement relaxed.

**Rationale.** This is a deliberate fidelity-vs-usability tradeoff: a
pixel-faithful copy of the source would fail accessibility, so Auris pulls
primary readable surfaces brighter than the source while preserving the dim
look for non-essential, decorative detailing. The decorative-only status of dim
tokens is documented so adopters do not misuse them for body content.

---

## Motion and performance §spec:motion-performance

*Status: not started*

Cites: §req:quality-attributes, §req:priorities

**Observable behavior.** The showcase scrolls and animates without visible jank
on a normal screen (target 60fps), including glow shadows, chamfer clipping, and
segmented bars — "performance/jank" is an identified abandonment driver. All
animations respect the platform reduced-motion setting
(`MediaQuery.disableAnimations`): when reduced motion is requested, animated
widgets render their end state without running the animation.

**Rationale.** Glow (stacked `BoxShadow` blurs), `ClipPath` chamfering, and
many-segment progress bars are the three features most likely to cost frames;
they are called out so the implementation keeps glow blur counts and segment
counts bounded and avoids per-frame path recomputation. Respecting reduced
motion is both an accessibility and a performance affordance.

---

## Fonts and packaging §spec:packaging

*Status: not started*

Cites: §req:success-criteria, §req:constraints, §req:priorities

**Observable behavior.** After a normal install the required fonts render
correctly with no manual font setup, and the package has zero runtime pub
dependencies (Flutter SDK only). The package meets pub.dev structural
expectations — README with installation and a usage example, license, and a
runnable example — so that publishing is a non-event.

**Design.** The three required fonts (Rajdhani, Exo 2, Share Tech Mono) are
distributed under the SIL Open Font License, which permits redistribution, so
they are bundled in the package and declared in `pubspec.yaml`. Bundling is the
chosen path specifically because it satisfies the out-of-box success criterion;
the size cost is accepted. The kit still degrades gracefully if a font is
absent (text renders in a fallback rather than failing).

**Rationale and boundary.** Bundling trades package size for zero-setup
adoption — the right trade for a kit whose whole value is "drop-in." Actual
pub.dev publication is a deferred milestone (§spec:scope); the package is built
to be publication-ready, but v0.1.0 does not publish.

---

## Example showcase §spec:showcase

*Status: not started*

Cites: §req:success-criteria, §req:user-stories

**Observable behavior.** `example/lib/main.dart` is a single scrollable app
that demonstrates every component — buttons, badges, inputs, selects, toggles,
sliders, progress, cards/panels, notifications, data rows + table, navigation,
chips, dialogs/sheets, terminal (with live-appending lines), stat cards,
ornaments, and stepper — each section introduced by a monospace uppercase
amber header.

**Verification path.** The showcase is how the success criteria are checked end
to end: a reviewer runs it and confirms (a) no standard component renders as
default Material (§spec:theme-layer), and (b) the aesthetic's signature
hallmarks are present — angular/chamfered geometry rather than rounded corners;
warm amber-gold on near-black with a cool secondary accent; amber glow in place
of drop shadows; uppercase letter-spaced display type with monospace data
readouts; and hex / corner-bracket ornamentation (§req:success-criteria #3).

**Rationale.** A single comprehensive showcase doubles as the evaluation
surface for prospective adopters and the manual acceptance harness for the
team, which is why it must cover every component group rather than a curated
subset.

---

## Scope and non-goals §spec:scope

*Status: not started*

Cites: §req:constraints, §req:priorities

Deferred beyond v0.1.0, by deliberate decision:

- A light-background theme variant (and a higher-contrast variant). Deferred,
  but **anticipated** rather than speculative: the token role structure
  (§spec:design-tokens) is chosen now so the variant can be added as an
  additive re-resolution of semantic roles without restructuring consumers.
  `AurisTheme.dark()` is reserved and unimplemented; the `light()`/`dark()`
  naming is revisited when this variant lands (§spec:overview).
- Actual pub.dev publication (the package is publication-*ready*, not
  published).
- Localization / RTL support.
- Web- or desktop-specific adaptations (mobile-first; the kit is not adapted for
  those surfaces in v0.1.0).
- Storybook / Widgetbook integration.
- Any networking, state management, routing, or data layer — Auris is purely
  presentational, permanently, not just in v0.1.0.

**Rationale.** v0.1.0 is scoped to prove the core value — a complete,
performant, accessible-enough, customizable drop-in re-skin plus the HUD widget
set — before investing in distribution and variant breadth.
