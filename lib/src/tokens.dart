import 'package:flutter/widgets.dart';

/// Primitive design tokens — the lowest tier of the two-tier design model.
///
/// These `const` values are the design contract: the raw colors, font families,
/// bevel sizes, glow shadows, and motion values that define the Auris look.
/// They live here and ONLY here — no raw color or font literal appears anywhere
/// else in the codebase (§spec:design-tokens, §req:constraints "no raw
/// literals").
///
/// Consumers do not read these directly. The *semantic* layer they read —
/// surfaces, text roles, the primary ramp, borders, depth-by-intent — is the
/// resolved [AurisScheme] built from these primitives (§spec:scheme). Keeping
/// primitives separate from resolved roles is what lets customization overrides
/// and brightness variants re-resolve the roles without touching this layer.
abstract final class AurisTokens {
  const AurisTokens._();

  // ---------------------------------------------------------------------------
  // Color palette — warm amber/gold primary on near-black surfaces, with a cool
  // slate secondary accent.
  // ---------------------------------------------------------------------------

  /// Page background.
  static const Color void_ = Color(0xFF0A0A0C);

  /// Panel surface.
  static const Color panel = Color(0xFF111115);

  /// Inset / input surface.
  static const Color panelAlt = Color(0xFF16161C);

  /// Resting border — DECORATIVE / SUPPLEMENTARY ONLY. A dim outline that, by
  /// design, falls below the WCAG 1.4.11 3:1 boundary contrast on [void_]; it is
  /// never the sole affordance for an interactive control. Controls are
  /// identified by their distinct inset fill, depth glow, and the gold focus
  /// ring (§spec:accessibility).
  static const Color border = Color(0xFF2A2510);

  /// Hover / focus border — DECORATIVE / SUPPLEMENTARY ONLY (see [border]). The
  /// gold [gold] focus decoration, not this outline, is the AA-meeting
  /// keyboard-focus indicator (§spec:accessibility).
  static const Color borderBright = Color(0xFF4A4020);

  /// Amber — inactive / dim primary.
  static const Color amber = Color(0xFFC8860A);

  /// Gold — active / primary.
  static const Color gold = Color(0xFFF0A500);

  /// Bright — focus / highlight.
  static const Color bright = Color(0xFFFFD060);

  /// Text on dark.
  static const Color brightWhite = Color(0xFFF0E8D0);

  /// Slate — cool secondary accent.
  static const Color slate = Color(0xFF8AABB0);

  /// Slate dim.
  static const Color slateDim = Color(0xFF4A6870);

  /// Danger.
  static const Color danger = Color(0xFFB03020);

  /// Danger — bright. Used as readable error TEXT (terminal error lines, input
  /// error/helper text, badge/stat-card deltas, notifications), so it is tuned
  /// to clear WCAG AA (>=4.5:1) on the darkest text surface, [panelAlt]
  /// (§spec:accessibility). Brightened from `0xFFE04030` (which read 4.24:1 on
  /// inset) to meet AA while preserving the red danger hue.
  static const Color dangerBright = Color(0xFFE84838);

  /// Success.
  static const Color success = Color(0xFF4A8A60);

  /// Success — bright.
  static const Color successBright = Color(0xFF6AB880);

  /// Text dim — DECORATIVE ONLY. Falls below WCAG AA on [void_]; never use for
  /// primary or critical content (§spec:accessibility).
  static const Color textDim = Color(0xFF5A5040);

  /// Text mid.
  static const Color textMid = Color(0xFFA09060);

  /// Text bright.
  static const Color textBright = Color(0xFFE0C070);

  // ---------------------------------------------------------------------------
  // Typography.
  // ---------------------------------------------------------------------------

  /// Display / headline family (Rajdhani). Uppercase, letter-spaced.
  static const String fontDisplay = 'Rajdhani';

  /// Body / label family (Exo 2).
  static const String fontBody = 'ExoTwo';

  /// Data / monospace family (Share Tech Mono).
  static const String fontMono = 'ShareTechMono';

  /// Letter spacing for label roles.
  static const double trackingLabel = 1.5;

  /// Letter spacing for heading / display roles.
  static const double trackingHeading = 1.8;

  /// Letter spacing for button labels.
  static const double trackingButton = 1.44;

  /// Letter spacing for body text.
  static const double trackingBody = 0.5;

  // ---------------------------------------------------------------------------
  // Shape — chamfered (45°) corners are the signature geometry.
  // ---------------------------------------------------------------------------

  /// Extra-small bevel — tiny controls (checkbox) where a larger cut reads as
  /// a diamond rather than a chamfer.
  static const double bevelXs = 3;

  /// Small bevel.
  static const double bevelSm = 6;

  /// Medium bevel — the component default.
  static const double bevelMd = 10;

  /// Large bevel.
  static const double bevelLg = 14;

  /// Extra-large bevel — panels / dialogs.
  static const double bevelXl = 20;

  // ---------------------------------------------------------------------------
  // Elevation and glow — amber glow replaces Material drop shadows. Primitives
  // only; consumers request depth by intent through the resolved scheme.
  // ---------------------------------------------------------------------------

  /// No glow.
  static const List<BoxShadow> glowNone = <BoxShadow>[];

  /// Subtle resting glow.
  static const List<BoxShadow> glowSubtle = <BoxShadow>[
    BoxShadow(
      color: Color(0x33C8860A),
      blurRadius: 8,
      spreadRadius: -2,
    ),
  ];

  /// Active glow — two stacked amber blurs.
  static const List<BoxShadow> glowActive = <BoxShadow>[
    BoxShadow(
      color: Color(0x66F0A500),
      blurRadius: 12,
      spreadRadius: -1,
    ),
    BoxShadow(
      color: Color(0x33F0A500),
      blurRadius: 24,
      spreadRadius: 0,
    ),
  ];

  /// Danger glow.
  static const List<BoxShadow> glowDanger = <BoxShadow>[
    BoxShadow(
      color: Color(0x66E04030),
      blurRadius: 12,
      spreadRadius: -1,
    ),
    BoxShadow(
      color: Color(0x33E04030),
      blurRadius: 24,
      spreadRadius: 0,
    ),
  ];

  /// Slate (secondary) glow.
  static const List<BoxShadow> glowSlate = <BoxShadow>[
    BoxShadow(
      color: Color(0x668AABB0),
      blurRadius: 12,
      spreadRadius: -1,
    ),
    BoxShadow(
      color: Color(0x338AABB0),
      blurRadius: 24,
      spreadRadius: 0,
    ),
  ];

  // ---------------------------------------------------------------------------
  // Motion.
  // ---------------------------------------------------------------------------

  /// Fast transitions.
  static const Duration durationFast = Duration(milliseconds: 120);

  /// Normal transitions.
  static const Duration durationNormal = Duration(milliseconds: 200);

  /// Slow transitions.
  static const Duration durationSlow = Duration(milliseconds: 350);

  /// Default curve.
  static const Curve curveDefault = Curves.easeInOut;

  /// Enter curve.
  static const Curve curveEnter = Curves.easeOut;

  /// Exit curve.
  static const Curve curveExit = Curves.easeIn;
}
