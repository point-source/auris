import 'package:flutter/material.dart';

import 'tokens.dart';

/// A resolved depth cue — the concrete result of requesting depth *by intent*.
///
/// Consumers request depth by intent (e.g. "active elevation") and the scheme
/// resolves that intent to an [AurisDepth]. In the dark variant the cue is amber
/// [glow]; the model is intentionally richer than glow alone so a future
/// brightness variant (where amber glow on a pale surface is nearly invisible)
/// can substitute a non-glow cue — a [borderColor] emphasis or an [insetColor]
/// — without any widget changing (§spec:scheme "Depth as a role").
@immutable
class AurisDepth {
  const AurisDepth({
    required this.glow,
    this.borderColor,
    this.insetColor,
  });

  /// The resting depth cue — no glow, no emphasis.
  static const AurisDepth none = AurisDepth(glow: <BoxShadow>[]);

  /// The glow cast for this depth. Empty for a non-glow cue.
  final List<BoxShadow> glow;

  /// Optional border-emphasis cue for variants where glow does not read.
  final Color? borderColor;

  /// Optional inset / surface-emphasis cue for variants where glow does not
  /// read.
  final Color? insetColor;

  /// Scales the resolved glow blur/spread by [factor] (the glow intensity
  /// override). A [factor] of 1 returns this depth unchanged.
  AurisDepth scaled(double factor) {
    if (factor == 1 || glow.isEmpty) return this;
    return AurisDepth(
      glow: <BoxShadow>[
        for (final BoxShadow s in glow)
          BoxShadow(
            color: s.color,
            offset: s.offset,
            blurRadius: s.blurRadius * factor,
            spreadRadius: s.spreadRadius * factor,
            blurStyle: s.blurStyle,
          ),
      ],
      borderColor: borderColor,
      insetColor: insetColor,
    );
  }

  static AurisDepth? _lerp(AurisDepth? a, AurisDepth? b, double t) {
    if (a == null && b == null) return null;
    if (a == null) return b;
    if (b == null) return a;
    return AurisDepth(
      glow: BoxShadow.lerpList(a.glow, b.glow, t) ?? const <BoxShadow>[],
      borderColor: Color.lerp(a.borderColor, b.borderColor, t),
      insetColor: Color.lerp(a.insetColor, b.insetColor, t),
    );
  }
}

/// The bevel (chamfer) scale, expressed as semantic roles rather than the raw
/// primitive sizes, so a customization override can multiply the whole scale at
/// once.
@immutable
class AurisBevelScale {
  const AurisBevelScale({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
  });

  /// Extra-small bevel — tiny controls (checkbox).
  final double xs;

  /// Small bevel.
  final double sm;

  /// Medium bevel — the component default.
  final double md;

  /// Large bevel.
  final double lg;

  /// Extra-large bevel — panels / dialogs.
  final double xl;

  static AurisBevelScale? _lerp(AurisBevelScale? a, AurisBevelScale? b, double t) {
    if (a == null || b == null) return t < 0.5 ? a : b;
    return AurisBevelScale(
      xs: lerpDouble(a.xs, b.xs, t),
      sm: lerpDouble(a.sm, b.sm, t),
      md: lerpDouble(a.md, b.md, t),
      lg: lerpDouble(a.lg, b.lg, t),
      xl: lerpDouble(a.xl, b.xl, t),
    );
  }
}

/// The single resolved design scheme every Auris consumer reads.
///
/// `AurisScheme` carries every design value as a **semantic role** rather than
/// a literal constant: surfaces (page/panel/inset), text roles
/// (bright/mid/dim), the primary ramp (dim/active/highlight), the secondary
/// accent, borders (resting/bright), semantic danger/success, the bevel scale,
/// and **depth by intent** (resting/subtle/active/danger/secondary).
///
/// It is attached to `ThemeData` as a `ThemeExtension`, so the Material
/// component themes and every custom widget resolve from the same values, and
/// an adopter can wrap a subtree in a different scheme to re-skin it
/// independently (§spec:scheme).
///
/// Build one with [AurisScheme.resolve], which takes a target [Brightness] plus
/// optional accent/bevel/glow overrides. v0.1.0 populates only the dark branch.
@immutable
class AurisScheme extends ThemeExtension<AurisScheme> {
  const AurisScheme({
    required this.brightness,
    required this.surfacePage,
    required this.surfacePanel,
    required this.surfaceInset,
    required this.textBright,
    required this.textMid,
    required this.textDim,
    required this.primaryDim,
    required this.primaryActive,
    required this.primaryHighlight,
    required this.onPrimary,
    required this.secondary,
    required this.secondaryDim,
    required this.borderResting,
    required this.borderBright,
    required this.danger,
    required this.dangerBright,
    required this.success,
    required this.successBright,
    required this.bevel,
    required this.depthResting,
    required this.depthSubtle,
    required this.depthActive,
    required this.depthDanger,
    required this.depthSecondary,
  });

  /// The brightness this scheme was resolved for.
  final Brightness brightness;

  // --- Surfaces ---
  /// Page background.
  final Color surfacePage;

  /// Panel / card surface.
  final Color surfacePanel;

  /// Inset / input surface.
  final Color surfaceInset;

  // --- Text roles ---
  /// Primary readable text.
  final Color textBright;

  /// Secondary / supporting text.
  final Color textMid;

  /// Decorative-only dim text (never primary content — §spec:accessibility).
  final Color textDim;

  // --- Primary ramp ---
  /// Inactive / dim primary.
  final Color primaryDim;

  /// Active / primary.
  final Color primaryActive;

  /// Focus / highlight.
  final Color primaryHighlight;

  /// Foreground drawn on top of the primary ramp.
  final Color onPrimary;

  // --- Secondary accent ---
  /// Cool secondary accent.
  final Color secondary;

  /// Dim secondary accent.
  final Color secondaryDim;

  // --- Borders ---
  /// Resting outline.
  final Color borderResting;

  /// Hover / focus outline.
  final Color borderBright;

  // --- Semantic ---
  /// Danger / error.
  final Color danger;

  /// Bright danger.
  final Color dangerBright;

  /// Success / confirmation.
  final Color success;

  /// Bright success.
  final Color successBright;

  // --- Shape ---
  /// The resolved bevel scale.
  final AurisBevelScale bevel;

  // --- Depth by intent ---
  /// Resting depth (no emphasis).
  final AurisDepth depthResting;

  /// Subtle resting glow.
  final AurisDepth depthSubtle;

  /// Active / primary glow.
  final AurisDepth depthActive;

  /// Danger glow.
  final AurisDepth depthDanger;

  /// Secondary (slate) glow.
  final AurisDepth depthSecondary;

  /// Resolve a fully populated scheme for a target [brightness].
  ///
  /// [accent] recolors the primary ramp (the active rung; dim and highlight are
  /// derived around it). [bevelScale] multiplies the bevel role. [glowScale]
  /// multiplies the resolved depth intensity. All overrides are optional and
  /// their defaults reproduce the canonical look exactly (§spec:customization).
  ///
  /// v0.1.0 implements only [Brightness.dark]; any other brightness is
  /// unsupported and throws [UnsupportedError]. The brightness input is an
  /// explicit seam so the light variant becomes an added branch, not a consumer
  /// rewrite (§spec:scheme "The resolution seam").
  factory AurisScheme.resolve({
    Brightness brightness = Brightness.dark,
    Color? accent,
    double bevelScale = 1.0,
    double glowScale = 1.0,
  }) {
    if (brightness != Brightness.dark) {
      throw UnsupportedError(
        'AurisScheme only resolves Brightness.dark in v0.1.0; '
        'a light variant is an anticipated future branch (see §spec:scope).',
      );
    }
    return _resolveDark(
      accent: accent,
      bevelScale: bevelScale,
      glowScale: glowScale,
    );
  }

  static AurisScheme _resolveDark({
    required Color? accent,
    required double bevelScale,
    required double glowScale,
  }) {
    // The primary ramp. When an accent override is supplied it replaces the
    // active rung; dim and highlight are derived around it so the ramp stays
    // coherent. With no override the canonical amber/gold/bright ramp is used.
    final Color active = accent ?? AurisTokens.gold;
    final Color dim = accent == null
        ? AurisTokens.amber
        : Color.alphaBlend(active.withValues(alpha: 0.78), AurisTokens.void_);
    final Color highlight = accent == null
        ? AurisTokens.bright
        : Color.alphaBlend(
            AurisTokens.brightWhite.withValues(alpha: 0.45),
            active,
          );

    return AurisScheme(
      brightness: Brightness.dark,
      // Surfaces.
      surfacePage: AurisTokens.void_,
      surfacePanel: AurisTokens.panel,
      surfaceInset: AurisTokens.panelAlt,
      // Text roles.
      textBright: AurisTokens.brightWhite,
      textMid: AurisTokens.textMid,
      textDim: AurisTokens.textDim,
      // Primary ramp.
      primaryDim: dim,
      primaryActive: active,
      primaryHighlight: highlight,
      onPrimary: AurisTokens.void_,
      // Secondary.
      secondary: AurisTokens.slate,
      secondaryDim: AurisTokens.slateDim,
      // Borders.
      borderResting: AurisTokens.border,
      borderBright: AurisTokens.borderBright,
      // Semantic.
      danger: AurisTokens.danger,
      dangerBright: AurisTokens.dangerBright,
      success: AurisTokens.success,
      successBright: AurisTokens.successBright,
      // Shape.
      bevel: AurisBevelScale(
        xs: AurisTokens.bevelXs * bevelScale,
        sm: AurisTokens.bevelSm * bevelScale,
        md: AurisTokens.bevelMd * bevelScale,
        lg: AurisTokens.bevelLg * bevelScale,
        xl: AurisTokens.bevelXl * bevelScale,
      ),
      // Depth by intent — resolved to amber glow in the dark variant, scaled by
      // the glow override, and carrying a border-emphasis fallback so a light
      // variant can express the same intent without glow.
      depthResting: AurisDepth.none,
      depthSubtle: const AurisDepth(
        glow: AurisTokens.glowSubtle,
        borderColor: AurisTokens.borderBright,
      ).scaled(glowScale),
      depthActive: AurisDepth(
        glow: AurisTokens.glowActive,
        borderColor: active,
      ).scaled(glowScale),
      depthDanger: const AurisDepth(
        glow: AurisTokens.glowDanger,
        borderColor: AurisTokens.dangerBright,
      ).scaled(glowScale),
      depthSecondary: const AurisDepth(
        glow: AurisTokens.glowSlate,
        borderColor: AurisTokens.slate,
      ).scaled(glowScale),
    );
  }

  @override
  AurisScheme copyWith({
    Brightness? brightness,
    Color? surfacePage,
    Color? surfacePanel,
    Color? surfaceInset,
    Color? textBright,
    Color? textMid,
    Color? textDim,
    Color? primaryDim,
    Color? primaryActive,
    Color? primaryHighlight,
    Color? onPrimary,
    Color? secondary,
    Color? secondaryDim,
    Color? borderResting,
    Color? borderBright,
    Color? danger,
    Color? dangerBright,
    Color? success,
    Color? successBright,
    AurisBevelScale? bevel,
    AurisDepth? depthResting,
    AurisDepth? depthSubtle,
    AurisDepth? depthActive,
    AurisDepth? depthDanger,
    AurisDepth? depthSecondary,
  }) {
    return AurisScheme(
      brightness: brightness ?? this.brightness,
      surfacePage: surfacePage ?? this.surfacePage,
      surfacePanel: surfacePanel ?? this.surfacePanel,
      surfaceInset: surfaceInset ?? this.surfaceInset,
      textBright: textBright ?? this.textBright,
      textMid: textMid ?? this.textMid,
      textDim: textDim ?? this.textDim,
      primaryDim: primaryDim ?? this.primaryDim,
      primaryActive: primaryActive ?? this.primaryActive,
      primaryHighlight: primaryHighlight ?? this.primaryHighlight,
      onPrimary: onPrimary ?? this.onPrimary,
      secondary: secondary ?? this.secondary,
      secondaryDim: secondaryDim ?? this.secondaryDim,
      borderResting: borderResting ?? this.borderResting,
      borderBright: borderBright ?? this.borderBright,
      danger: danger ?? this.danger,
      dangerBright: dangerBright ?? this.dangerBright,
      success: success ?? this.success,
      successBright: successBright ?? this.successBright,
      bevel: bevel ?? this.bevel,
      depthResting: depthResting ?? this.depthResting,
      depthSubtle: depthSubtle ?? this.depthSubtle,
      depthActive: depthActive ?? this.depthActive,
      depthDanger: depthDanger ?? this.depthDanger,
      depthSecondary: depthSecondary ?? this.depthSecondary,
    );
  }

  @override
  AurisScheme lerp(covariant ThemeExtension<AurisScheme>? other, double t) {
    if (other is! AurisScheme) return this;
    return lerpFrom(other, t);
  }

  /// Interpolate from this scheme toward [other] by [t]. Exposed for the
  /// `ThemeExtension` contract and for explicit cross-scheme transitions.
  AurisScheme lerpFrom(AurisScheme other, double t) {
    return AurisScheme(
      brightness: t < 0.5 ? brightness : other.brightness,
      surfacePage: Color.lerp(surfacePage, other.surfacePage, t)!,
      surfacePanel: Color.lerp(surfacePanel, other.surfacePanel, t)!,
      surfaceInset: Color.lerp(surfaceInset, other.surfaceInset, t)!,
      textBright: Color.lerp(textBright, other.textBright, t)!,
      textMid: Color.lerp(textMid, other.textMid, t)!,
      textDim: Color.lerp(textDim, other.textDim, t)!,
      primaryDim: Color.lerp(primaryDim, other.primaryDim, t)!,
      primaryActive: Color.lerp(primaryActive, other.primaryActive, t)!,
      primaryHighlight:
          Color.lerp(primaryHighlight, other.primaryHighlight, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      secondaryDim: Color.lerp(secondaryDim, other.secondaryDim, t)!,
      borderResting: Color.lerp(borderResting, other.borderResting, t)!,
      borderBright: Color.lerp(borderBright, other.borderBright, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerBright: Color.lerp(dangerBright, other.dangerBright, t)!,
      success: Color.lerp(success, other.success, t)!,
      successBright: Color.lerp(successBright, other.successBright, t)!,
      bevel: AurisBevelScale._lerp(bevel, other.bevel, t)!,
      depthResting: AurisDepth._lerp(depthResting, other.depthResting, t)!,
      depthSubtle: AurisDepth._lerp(depthSubtle, other.depthSubtle, t)!,
      depthActive: AurisDepth._lerp(depthActive, other.depthActive, t)!,
      depthDanger: AurisDepth._lerp(depthDanger, other.depthDanger, t)!,
      depthSecondary:
          AurisDepth._lerp(depthSecondary, other.depthSecondary, t)!,
    );
  }
}

/// Non-nullable [lerpDouble] for the bevel scale, where all inputs are concrete.
@visibleForTesting
double lerpDouble(double a, double b, double t) => a + (b - a) * t;
