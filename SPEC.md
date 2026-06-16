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

*Status: in progress*

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
roughly 60% of the desired geometry by setting a custom chamfered border
(`AurisChamferBorder`) on component shape themes, but cannot produce segmented
fills, custom-clipped tracks, or decorative painters. Rather than ship only custom widgets (forcing adopters
to rewrite their UI), the theme layer makes the common case zero-effort and
the widget library covers the rest.

**Rejected alternative.** A pure custom-widget kit (no `ThemeData`) was
rejected: it would not satisfy the "instant drop-in re-skin" success criterion
and would force adopters to replace every existing Material widget.

**Shared foundation.** Both layers read from one resolved design scheme rather
than from raw constants independently (§spec:scheme). The scheme is derived
once — from primitive tokens plus any customization overrides plus a target
brightness — and carried on `ThemeData` as a `ThemeExtension`. This single
resolution point is what lets customization (§spec:customization) and the
anticipated light variant (§spec:scope) re-skin the entire kit, Material
components and custom widgets alike, through one mechanism instead of two.

**Variants.** Both variants are implemented and honestly named:
`AurisTheme.dark()` is the canonical amber-on-near-black look, and
`AurisTheme.light()` is a clean, technical light-background variant that keeps
the same amber identity — light neutral surfaces, dark warm text, and the amber
accent **darkened for AA on light** (not a different hue) with a brightened-amber
glow pushed hard enough to read on a light surface (see §spec:scheme "Depth as a
role"). The two variants are the same colors with lightness/contrast inverted —
one resolution with a different `Brightness` input (§spec:scheme) — and accept
the same accent/bevel/glow overrides. The earlier `light()`-returns-dark misnomer
is resolved.

---

## Design tokens §spec:design-tokens

*Status: in progress*

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

**Shape.** An **asymmetric** chamfer is the signature geometry: the **top-left
and bottom-right corners are cut at 45°, while the top-right and bottom-left
stay square** — the notched-panel silhouette. Cut sizes: `bevelSm 6`,
`bevelMd 10` (component default), `bevelLg 14`, `bevelXl 20` (panels/dialogs).
Flutter's `BeveledRectangleBorder` cannot express this — it bevels all four
corners equally — so the corner geometry is owned by a single custom
`AurisChamferBorder` (an `OutlinedBorder`) applied to every shaped component,
with a matching `ChamferClipper` (`CustomClipper<Path>`) clipping child content
to the same two corners. The corner rule lives in exactly one place
deliberately: which corners are cut (and the cut size) is a single edit, not a
sweep across every theme. The two-corner cut also makes the resting and
hover/focus border feel directional, reinforcing the HUD aesthetic.

A second, related motif — a right-leaning **parallelogram slant** — is used for
the small "data" controls (progress-bar segments, the switch track/thumb),
where a corner notch reads as a lopsided wedge at that size. Like the chamfer,
the slant geometry lives in one place (`AurisSlantBorder` / `SlantClipper`), so
the two motifs stay distinct and internally consistent: chamfer for
panels/buttons/surfaces, slant for data cells.

**Component conventions.** Recurring rules that keep the aesthetic consistent
and avoid the failure modes that small elements invite:

- *Geometry scales with element size.* A fixed large corner cut reads as a
  diamond or lopsided wedge on a small control. Tiny controls (checkbox, radio
  pip, slider thumb) use the extra-small bevel; the switch slant is a constant
  ratio of each element's height so the track and thumb edges stay parallel.
- *Text glow is a tight glyph shadow, not a box halo.* A glowing value sets a
  subtle depth shadow on the text style's `shadows` (or the icon's `shadows`) so
  the glow hugs the glyphs. A `BoxShadow` behind the text reads as a rectangular
  halo and is wrong — and behind a *translucent* fill (e.g. a marker's faint
  active fill) the box glow bleeds through and pools as a round orb inside the
  rectangle, which is the failure the glyph shadow avoids. A small marker that
  carries a glyph (the step indicator) glows the glyph, not the box.
- *Glow hugs the element.* Depth is a tight blur with low alpha (and slight
  negative spread on boxes), never a wash that bleeds across the layout. A
  few-pixel accent bar uses its own small edge glow, since the box depth token's
  negative spread would vanish on it. *Intensity is carried by alpha, not blur* —
  a stronger glow is brighter/denser, not wider, so it keeps hugging the shape
  rather than ballooning into a cloud.
- *Glow intensity and accent come from the scheme, never hardcoded.* A widget
  requests depth by intent through the resolved `depth*` cues (already
  accent-tinted and glow-scaled). A widget that must synthesize a custom-shaped
  glow the depth token cannot express takes its hue from the accent role and
  scales its alpha by `scheme.glowScale`, so both the accent and glow knobs reach
  it; a literal blur/alpha/color silently ignores customization
  (§spec:customization "Propagation invariant").
- *Fill chamfer/slant shapes via `ShapeDecoration`* (anti-aliased), not a
  `ClipPath` over a `ColoredBox` — clipping leaves jagged diagonal edges. Use a
  clip only to contain children, with `Clip.antiAliasWithSaveLayer`.
- *Filled progressions dim the trail and brighten the leading/active cell.* In a
  segmented meter or slider, trailing filled cells are dimmed and the leading
  (active-position) cell is brightest, so position reads at a glance. A *stepped*
  slider matches its cell count to the slider's divisions so each cell is one
  step and the cell boundaries fall on the thumb's snap points; a continuous
  slider uses a fixed fine cell count.
- *Bundled fonts are referenced with the `packages/auris/` prefix* — a bare
  family name silently falls back to the platform font.

**Elevation and glow.** Material elevation shadows are replaced by amber glow,
because drop shadows read as flat/soft and conflict with the hard-edged,
luminous aesthetic. The primitive glow values are `BoxShadow` lists: `glowNone`,
`glowSubtle`, `glowActive` (two stacked amber blurs), plus `glowDanger` and
`glowSlate` variants. `ColorScheme.shadow` is `transparent` and component
`elevation` is `0` everywhere; depth is communicated by glow, not shadow. These
are primitives only — consumers never reference them directly but request depth
*by intent* through the resolved scheme (§spec:scheme), so a future brightness
variant can resolve the same intent to a non-glow cue.

**Motion.** `durationFast 120ms`, `durationNormal 200ms`, `durationSlow 350ms`;
curves `curveDefault` (easeInOut), `curveEnter` (easeOut), `curveExit`
(easeIn).

**Rationale.** These `const` primitives are the lowest tier of a two-tier
model: raw values live here (and only here — the "no raw literals" bar), while
the *semantic* layer that consumers actually read — surfaces, text roles, the
primary ramp, borders, depth-by-intent — is the resolved scheme built from
these primitives (§spec:scheme). Keeping primitives separate from resolved
roles is what lets customization overrides and brightness variants re-resolve
the roles without touching this primitive layer or any call site.

---

## Resolved scheme and theme assembly §spec:scheme

*Status: in progress*

Cites: §req:quality-attributes, §req:success-criteria, §req:constraints

**Problem.** Two distinct needs — letting an adopter recolor/reshape the kit
without forking (§spec:customization) and adding a light variant later without a
rewrite (§spec:scope) — are the same underlying operation: re-deriving the look
from semantic intent. If the theme layer and the custom widgets each read raw
constants independently, that operation has to be implemented twice and kept in
sync, and a variant means editing every call site.

**Observable behavior.** A single resolved value object, `AurisScheme`, carries
every design value consumers read, expressed as **semantic roles** rather than
literal constants — surfaces (page/panel/inset), text roles (bright/mid/dim),
the primary ramp (dim/active/highlight), secondary accent, borders
(resting/bright), semantic danger/success, the bevel scale, and **depth by
intent** (resting/subtle/active/danger/secondary). `AurisScheme` is attached to
`ThemeData` as a `ThemeExtension`. Every Auris custom widget reads its values
from `Theme.of(context).extension<AurisScheme>()`, and the Material component
themes (§spec:theme-layer) are derived from the same resolved scheme. Because it
is a `ThemeExtension`, an adopter can wrap a subtree in a `Theme` with a
different scheme and that subtree re-skins independently.

**The resolution seam.** The scheme is produced by one resolver that takes a
target `Brightness`, an optional accent override, and optional bevel/glow
scales, and returns a fully populated `AurisScheme` built from the primitive
tokens (§spec:design-tokens). Both the dark and light branches are implemented;
brightness as an explicit input to a role-producing resolver is what let the
light variant land as an added branch rather than a consumer rewrite.

**Depth as a role.** Consumers request depth by intent (e.g. "active
elevation"), and the scheme resolves that intent to a concrete cue. The dark
variant resolves it to amber glow (the `glow*` primitives); the light variant
resolves the *same intent* to a brightened-amber glow at a higher alpha, since a
glow has to be pushed harder to read against a light surface. The cue
color/strength is a property of the resolved scheme, so no widget changes
between variants — they request "active depth" and get whatever each variant
resolves it to.

**Rationale and tradeoffs.** A `ThemeExtension` was chosen over a bespoke
`InheritedWidget` wrapper because it rides on the `ThemeData` the adopter
already supplies to `MaterialApp`, preserving the "instant drop-in" criterion
(no second wrapper) and giving per-subtree scoping for free. Static
`AurisTokens` access was rejected as the consumer path because it cannot vary by
context, which would defeat both customization and brightness variants. The cost
accepted is one layer of indirection (widgets resolve from context rather than
referencing constants) and the discipline that no consumer reads a primitive
directly. `AurisTokens` remains available for adopters who genuinely want raw
values.

---

## Theme layer — complete Material re-skin §spec:theme-layer

*Status: complete*

Cites: §req:success-criteria, §req:user-stories, §req:priorities

**Observable behavior.** When an application sets `theme: AurisTheme.dark()` (or
`AurisTheme.light()`) on its `MaterialApp`, every standard Material 3 widget
renders in the Auris aesthetic with no further work. No standard widget renders
with default Material styling — this is the kit's top success criterion and its
primary defense against the leading abandonment risk ("widgets look
broken/unstyled").

`AurisTheme.dark()`/`light()` return a fully specified `ThemeData` whose `ColorScheme`
and every component theme are derived from the resolved `AurisScheme`
(§spec:scheme), which is also attached to the returned `ThemeData` as a
`ThemeExtension` so custom widgets share the exact same resolved values. Any
customization overrides or brightness target flow in through that one scheme,
so they reach the Material components and the custom widgets identically. Every
component theme that styles a visible Material widget is populated; none is left
at its Material 3 default. Coverage is defined by a **census of `ThemeData`'s
component-theme slots**, not by the subset the showcase happens to demonstrate —
a widget a real app reaches for is themed even when the demo never shows it. The
populated component themes are:

`ColorScheme`, `TextTheme`, `ElevatedButton`, `OutlinedButton`, `TextButton`,
`FilledButton`, `IconButton`, `FloatingActionButton`, `SegmentedButton`,
`ToggleButtons`, `InputDecoration`, text selection (cursor / handles /
highlight), `Checkbox`, `Radio`, `Switch`, `Slider`, `Chip`, `Card`, `Dialog`,
`DatePicker`, `TimePicker`, `SnackBar`, `MaterialBanner`, `BottomSheet`,
`Tooltip`, `PopupMenu`, `Menu` / `MenuBar` (the `MenuAnchor` surfaces),
`DropdownMenu`, `Scrollbar`, `AppBar`, `BottomAppBar`, `NavigationBar`,
`BottomNavigationBar`, `NavigationRail`, `Drawer`, `NavigationDrawer`, `TabBar`,
`ListTile`, `ExpansionTile`, `DataTable`, `ProgressIndicator`, `Divider`,
`Badge`, `SearchBar` / `SearchView`. `Stepper` has no component-theme slot of its
own and is covered through the resolved `ColorScheme` instead.

The only `ThemeData` slots deliberately left unset are those that do not style a
standard visible widget, and each exclusion is recorded so "unset" never means
"overlooked": the legacy pre-Material-3 button themes (`ButtonTheme` for
`MaterialButton`, the removed `ButtonBar`), whose widgets Auris does not support;
`actionIconTheme`, which selects *which* glyph a back / close / drawer button
shows rather than how it is styled; and the global `iconTheme` /
`primaryTextTheme` / `primaryIconTheme` defaults, which derive from the
already-populated `ColorScheme` and `TextTheme`.

**Signature treatments applied across all components:**

- **Shape:** the custom `AurisChamferBorder` (top-left + bottom-right cut, the
  other two corners square) at the appropriate cut size on every shaped surface
  (buttons, inputs, cards, menus, indicators, nav indicators). Text fields,
  whose border is an `InputBorder` rather than a `ShapeBorder`, use a matching
  chamfered `InputBorder` so they share the silhouette.
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

**Rationale and known limits.** `ThemeData` + a custom `OutlinedBorder`
(`AurisChamferBorder`) reaches most components but has gaps Flutter does not
expose: the `Switch` track cannot take the slanted data-control geometry, and
the linear `ProgressIndicator` cannot be segmented. Where a
gap degrades the aesthetic, the theme is configured as closely as possible and
a custom widget (§spec:custom-widgets) is provided as the preferred
replacement — `AurisSwitch` (its slanted track and thumb cannot be expressed
through `ThemeData`) and `AurisProgressBar` respectively. Some Material
themes (dialog, popup, snackbar) cannot attach a glow shadow directly through
`ThemeData`; glow on those surfaces is delivered by the widget that consumes
them where it matters, and the rationale is recorded rather than the workaround
re-specified.

**Verification path.** Coverage is checked two ways. A component-theme **census**
(`doc/component-theme-census.md`) enumerates every `ThemeData` slot and marks each
one populated or excluded-with-reason, so no slot is silently skipped — a widget
missing from the demo is exactly how a gap hides. The showcase (§spec:showcase)
then renders every populated component so a reviewer confirms none falls back to
default Material styling: the census guarantees completeness, the showcase is the
visual proof.

---

## Custom widget library §spec:custom-widgets

*Status: in progress*

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
| `AurisSwitch` | Toggle with a true slanted (parallelogram) track and thumb — the data-control motif (§spec:design-tokens), impossible via `ThemeData`; animates thumb position and track color over `durationNormal`; optional label and on/off status labels. |
| `AurisProgressBar` | Segmented meter — N slanted (parallelogram) segments, the data-control motif (§spec:design-tokens); filled segments use the variant color, the leading filled segment glows. `.animated` constructor tweens value changes. The preferred linear-progress replacement. |
| `AurisDataRow` | Fixed-height key/value row with a bottom divider; value in monospace, optional highlight (bright + glow) and trailing widget. |
| `AurisTerminal` | Scrolling monospace log that auto-scrolls to the newest line; line color by type (ok/error/augment/warning/normal); optional blinking block cursor. Wraps `AurisPanel`. |
| `AurisStepIndicator` | Chamfered step marker (inactive/active/complete/error) for use with `Stepper.stepIconBuilder` or standalone. |
| `AurisHexOrnament` | Non-interactive `CustomPaint` cluster of hexagons for ambient page-background detail; `IgnorePointer`. |
| `AurisScanBracket` | Targeting-reticle corner brackets around a child; optional opacity pulse on `durationSlow`. |
| `AurisStatCard` | KPI/metric tile: label, large glowing value, optional unit and signed delta (success/danger arrow + baseline suffix). |
| `AurisSelect` | Dropdown/select with a rotating caret, a chamfered glowing popup, and per-row dividers with hover/selected highlight — the visual the native `DropdownMenu` cannot reach (no menu glow, no per-row dividers, no caret rotation via `ThemeData`). The themed native `DropdownMenu` remains available for adopters who want the zero-extra-widget path. |
| `AurisRadio` | Group-based single-select with a chamfered indicator: a filled chamfered centre pip when selected, on a single outline that thickens and brightens (with a subtle glow) on selection and on keyboard focus — focus intensifies that one outline rather than drawing a second concentric ring. Material's `Radio` is circular with no shape hook, so this is the geometric replacement. |

**Rationale.** Each widget exists specifically because the corresponding effect
cannot be produced through `ThemeData` — segmented fills, custom-clipped
tracks, decorative painters, and auto-scrolling log behavior all require widget
code. Widget constructors are `const` wherever possible. Exact dimensions and
padding are owned by the implementation; the design-defining values (colors,
bevel scale, depth-by-intent) are read from the resolved `AurisScheme` via
`Theme.of(context).extension<AurisScheme>()` (§spec:scheme), not from primitive
constants — this is what makes the widgets honor customization overrides and
future brightness variants without per-widget changes.

---

## Customization without forking §spec:customization

*Status: complete*

Cites: §req:success-criteria, §req:quality-attributes, §req:priorities

**Problem.** "Too rigid to customize" is an identified abandonment driver. A
fixed `const` palette forces adopters with brand needs to fork the package.

**Observable behavior.** An adopter can change the **accent color**, **corner
bevel scale**, and **glow intensity** and see the change propagate through both
the theme layer and the custom widgets, without copying or editing package
source. `AurisTheme.light()` accepts these overrides; because both layers read
the single resolved `AurisScheme` (§spec:scheme), one override point re-skins
the whole kit.

**Design.** The overrides are inputs to the scheme resolver (§spec:scheme), the
same resolver whose other input is target brightness — customization and
brightness are orthogonal knobs on one resolution, not two mechanisms. The
accent override recolors the primary ramp **and re-tints the otherwise-warm
neutral roles** (the text and border roles), so the whole kit shares one hue
rather than leaving amber text/outlines fighting a cool accent; the tinted roles
are derived from the accent's own hue at low saturation (a clean desaturated
accent), not by blending the accent into the warm token (which yields a muddy
mix). On the **light variant** an accent override gets the same AA contrast
correction the canonical amber rung is hand-tuned to — a bright accent (tuned for
the dark variant) is darkened (hue/saturation held, lightness lowered) until it
clears the amber rung's contrast on the light surface, so no override reads as
washed-out; and the primary glow there is the *highlight* rung (a lighter,
slightly desaturated accent), not a raw brightening of the deep fill, so the halo
stays in the fill's color family instead of over-saturating into a different hue.
The bevel scale multiplies the bevel role. The glow scale scales the
resolved depth **intensity via alpha, holding blur/spread constant**, so a
stronger glow is brighter, not wider — it keeps hugging the element instead of
ballooning into a wash. The exact API surface (named parameters vs. a config
object) is an implementation choice, constrained to: overrides are optional,
defaults reproduce the canonical look exactly, and an adopter who supplies no
overrides pays no resolution cost beyond the default scheme.

**Propagation invariant.** Because both layers read the one resolved scheme,
every design-defining value a surface renders — ramp/accent color, the
amber→accent tint of the neutral text and border roles, the bevel, and **glow
intensity** — must be obtained from the resolved `AurisScheme`: a semantic role,
or, where a widget synthesizes a value the scheme does not pre-resolve, the
override factors the scheme carries for that purpose. The scheme therefore
exposes not only resolved roles and `depth*` cues but the raw `glowScale` factor,
so a widget building a *custom-shaped* glow (e.g. a few-pixel accent bar whose
geometry the tight depth token cannot express) scales its own alpha by
`glowScale` and takes its hue from the accent role, rather than baking a constant
blur/alpha/color. A surface that hardcodes any of these silently opts out of
customization — this is the recurring failure mode (an amber glow under a teal
accent; a fixed glow that ignores the intensity knob; warm text under a cool
accent). Every new or changed widget and component theme is reviewed against
this invariant: flip the accent and the glow, and confirm the surface re-skins
with no leftover default. This is the customization counterpart to the "no raw
literals" bar (§spec:design-tokens), extended from color to tint and glow
intensity.

**Rationale and boundary.** Scope is deliberately limited to accent, bevel, and
glow — the three knobs that cover the common brand-fit case — rather than full
per-role theming, which would reintroduce the complexity the kit exists to
hide. Adopters needing deeper changes can construct a custom `AurisScheme`
directly. The cool secondary (slate) accent is not yet a customization knob;
this is a conscious v0.1.0 boundary.

---

## Accessibility and contrast §spec:accessibility

*Status: complete*

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

*Status: complete*

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

*Status: in progress*

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

*Status: in progress*

Cites: §req:success-criteria, §req:user-stories

**Observable behavior.** `example/lib/main.dart` is a single scrollable app
that demonstrates every component — buttons (text / outlined / filled /
elevated / icon / FAB, plus segmented and toggle buttons), badges, inputs,
selects, menus (`MenuAnchor` / `MenuBar`), toggles, sliders, progress,
scrollbars, cards/panels, notifications and material banners, data rows + table,
navigation (app bar, navigation bar, bottom navigation bar, navigation rail,
drawer and navigation drawer, bottom app bar), chips, date and time pickers,
dialogs/sheets, terminal (with live-appending lines), stat cards, ornaments, and
stepper — each section introduced by a monospace uppercase amber header.

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

**Visual regression.** The rendered appearance of the geometry- and
glow-bearing custom widgets is locked with golden-image tests
(`matchesGoldenFile`). The analyzer and behavioral unit tests do not catch
visual changes — a zero-height progress segment, an off-screen popup, a
too-large chamfer, or a runaway glow all pass logic tests while looking wrong —
so goldens are the automated counterpart to the manual showcase review, failing
in CI when the look drifts (§req:success-criteria).

---

## Scope and non-goals §spec:scope

*Status: in progress*

Cites: §req:constraints, §req:priorities

**Light variant — now implemented.** Originally deferred, the light-background
variant landed early via the brightness seam (§spec:scheme): a clean technical
light theme that keeps the amber identity, adjusted for light (§spec:overview
"Variants"). It is an
additive resolver branch — the dark variant is unchanged. A *higher-contrast*
variant remains anticipated future work on the same seam.

Deferred beyond v0.1.0, by deliberate decision:

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
