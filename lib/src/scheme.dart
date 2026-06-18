import 'dart:math' as math;

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
  const AurisDepth({required this.glow, this.borderColor, this.insetColor});

  /// The resting depth cue — no glow, no emphasis.
  static const AurisDepth none = AurisDepth(glow: <BoxShadow>[]);

  /// The glow cast for this depth. Empty for a non-glow cue.
  final List<BoxShadow> glow;

  /// Optional border-emphasis cue for variants where glow does not read.
  final Color? borderColor;

  /// Optional inset / surface-emphasis cue for variants where glow does not
  /// read.
  final Color? insetColor;

  /// Scales the resolved glow by [factor] (the glow intensity override): only
  /// the alpha *strength* grows with the factor; the blur radius and spread are
  /// held constant so a stronger glow gets brighter/denser rather than wider.
  /// Scaling the blur instead made the halo balloon into a soft cloud that no
  /// longer hugged the element's shape — intensity, not reach, is the knob. A
  /// [factor] of 1 returns this depth unchanged; 0 yields no glow.
  AurisDepth scaled(double factor) {
    if (factor == 1 || glow.isEmpty) return this;
    return AurisDepth(
      glow: <BoxShadow>[
        for (final BoxShadow s in glow)
          BoxShadow(
            color: s.color.withValues(
              alpha: (s.color.a * factor).clamp(0.0, 1.0),
            ),
            offset: s.offset,
            blurRadius: s.blurRadius,
            spreadRadius: s.spreadRadius,
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

  static AurisBevelScale? _lerp(
    AurisBevelScale? a,
    AurisBevelScale? b,
    double t,
  ) {
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

/// The light-variant palette: a clean, technical light theme that keeps the
/// kit's amber identity (light neutral surfaces, dark warm text, an amber accent
/// darkened for AA). It mirrors the dark variant's structure — a deep [accent]
/// that clears AA for text/borders, plus a brighter [accentHi] for the focus
/// highlight; the glow is a brightened [accent] (so it matches what it glows).
@immutable
class _LightPalette {
  const _LightPalette({
    required this.page,
    required this.panel,
    required this.inset,
    required this.textHi,
    required this.textMid,
    required this.textDim,
    required this.accent,
    required this.accentDim,
    required this.accentHi,
    required this.onAccent,
    required this.border,
    required this.borderBright,
    required this.secondary,
    required this.secondaryDim,
  });

  final Color page;
  final Color panel;
  final Color inset;
  final Color textHi;
  final Color textMid;
  final Color textDim;

  /// Deep accent (AA on light) for text / icons / borders / fills.
  final Color accent;

  /// Dim / inactive accent rung.
  final Color accentDim;

  /// Vibrant accent used for the glow and focus highlight only.
  final Color accentHi;

  /// Foreground drawn on an accent-filled surface.
  final Color onAccent;
  final Color border;
  final Color borderBright;
  final Color secondary;
  final Color secondaryDim;
}

/// The light variant: the SAME Auris colors as dark, with lightness/contrast
/// inverted for a light surface — light neutral surfaces, dark warm text, the
/// amber/gold accent darkened to a bronze that clears AA on light, and the slate
/// secondary kept. The accent keeps its amber hue (it is not a different color);
/// the glow is a brightened amber derived from the active accent, strong enough
/// to read on a light surface.
const _LightPalette _lightPalette = _LightPalette(
  page: Color(0xFFECEDEF),
  panel: Color(0xFFFBFBFC),
  inset: Color(0xFFF3F3F5),
  textHi: Color(0xFF221F18),
  textMid: Color(0xFF595446),
  textDim: Color(0xFF9C968A),
  accent: Color(0xFF8A5E00),
  accentDim: Color(0xFFB0883C),
  accentHi: Color(0xFFE6A422),
  onAccent: Color(0xFFFBFBFC),
  border: Color(0xFFDAD7CE),
  borderBright: Color(0xFFBEB7A4),
  secondary: Color(0xFF3E6B78),
  secondaryDim: Color(0xFF7FA0AB),
);

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
    this.glowScale = 1.0,
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

  /// The glow-intensity multiplier this scheme was resolved with (the
  /// customization `glowScale`). The resolved `depth*` cues already bake this in;
  /// it is exposed so a widget building a *custom* glow outside the depth tokens
  /// (e.g. a thin accent bar's edge glow) can honor the same override.
  final double glowScale;

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

  /// The accent-gold outline an *active* overlay wears — an open menu, popup, or
  /// the open `AurisSelect` panel — so an open surface reads as the live element
  /// (§spec:theme-layer "Color roles"). Derived from [primaryActive] at a partial
  /// alpha so it stays a crisp edge, not a fill; sourced here so every overlay
  /// shares one value rather than re-deriving it.
  Color get borderActive => primaryActive.withValues(alpha: 0.7);

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
  /// Both [Brightness.dark] (amber-on-near-black) and [Brightness.light] (a
  /// light-background variant) are supported. The brightness input is an
  /// explicit seam so the two variants are branches of one resolution rather
  /// than two mechanisms (§spec:scheme "The resolution seam").
  factory AurisScheme.resolve({
    Brightness brightness = Brightness.dark,
    Color? accent,
    double bevelScale = 1.0,
    double glowScale = 1.0,
  }) {
    switch (brightness) {
      case Brightness.dark:
        return _resolveDark(
          accent: accent,
          bevelScale: bevelScale,
          glowScale: glowScale,
        );
      case Brightness.light:
        return _resolveLight(
          _lightPalette,
          accent: accent,
          bevelScale: bevelScale,
          glowScale: glowScale,
        );
    }
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

    // When an accent override recolors the primary ramp, the primary-ramp glow
    // must follow it — an amber glow around a teal element reads as a bug. The
    // active/subtle depth glow is retinted to the accent (each shadow keeps its
    // own alpha, blur, and spread). With no override the canonical amber
    // primitives are used unchanged, so the default look is reproduced exactly.
    // Danger/secondary glows are semantic and never recolor.
    final List<BoxShadow> activeGlow = accent == null
        ? AurisTokens.glowActive
        : _tintGlow(AurisTokens.glowActive, active);
    final List<BoxShadow> subtleGlow = accent == null
        ? AurisTokens.glowSubtle
        : _tintGlow(AurisTokens.glowSubtle, dim);

    // The canonical text and border tokens carry an amber warmth, so under a
    // non-default accent they keep an amber cast that fights the new hue. Rather
    // than blend the accent INTO the warm token — which yields a muddy
    // amber+accent mix — re-express each tinted role as the accent's own hue at a
    // low saturation and the role's target lightness, so it reads as a clean
    // desaturated accent ("dimmed cyan") that shares the kit's single hue. With
    // no override the warm canonical tokens are used verbatim.
    final Color textBright = accent == null
        ? AurisTokens.brightWhite
        : _accentRole(active, 0.22, 0.88);
    final Color textMid = accent == null
        ? AurisTokens.textMid
        : _accentRole(active, 0.32, 0.60);
    final Color textDim = accent == null
        ? AurisTokens.textDim
        : _accentRole(active, 0.30, 0.34);
    final Color borderResting = accent == null
        ? AurisTokens.border
        : _accentRole(active, 0.45, 0.13);
    final Color borderBright = accent == null
        ? AurisTokens.borderBright
        : _accentRole(active, 0.45, 0.22);

    return AurisScheme(
      brightness: Brightness.dark,
      glowScale: glowScale,
      // Surfaces.
      surfacePage: AurisTokens.void_,
      surfacePanel: AurisTokens.panel,
      surfaceInset: AurisTokens.panelAlt,
      // Text roles (accent-tinted under an override; canonical warm otherwise).
      textBright: textBright,
      textMid: textMid,
      textDim: textDim,
      // Primary ramp.
      primaryDim: dim,
      primaryActive: active,
      primaryHighlight: highlight,
      onPrimary: AurisTokens.void_,
      // Secondary.
      secondary: AurisTokens.slate,
      secondaryDim: AurisTokens.slateDim,
      // Borders (accent-tinted under an override; canonical warm otherwise).
      borderResting: borderResting,
      borderBright: borderBright,
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
      depthSubtle: AurisDepth(
        glow: subtleGlow,
        borderColor: AurisTokens.borderBright,
      ).scaled(glowScale),
      depthActive: AurisDepth(
        glow: activeGlow,
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

  /// Resolve the light variant from a candidate [p] palette — a clean technical
  /// light theme that keeps the amber identity. The look mirrors the dark
  /// variant's structure (a deep accent that clears AA, a brighter highlight),
  /// so depth stays the same *glow* channel rather than a flat drop shadow; the
  /// glow is a brightened amber pushed hard enough to read on a light surface
  /// (§spec:scheme "Depth as a role").
  static AurisScheme _resolveLight(
    _LightPalette p, {
    required Color? accent,
    required double bevelScale,
    required double glowScale,
  }) {
    // With no override the palette's tuned (AA-checked) rungs are used. An accent
    // override replaces the deep rung; the dim/highlight (glow) rungs are derived
    // around it so the ramp and its glow stay coherent.
    //
    // A raw accent (tuned for the dark variant — bright teal/magenta/green) is
    // far too light to clear AA on a light surface and reads as washed-out next
    // to the canonical amber's deep bronze rung. So an override is darkened (hue
    // and saturation held, only lightness drops) until it clears the same
    // contrast the canonical amber rung does — the override gets the SAME
    // contrast correction amber was hand-tuned to, not the raw color.
    final Color active = accent == null
        ? p.accent
        : _darkenForContrast(accent, p.panel, _kAccentContrastTarget);
    final Color dim = accent == null
        ? p.accentDim
        : Color.alphaBlend(active.withValues(alpha: 0.45), p.panel);
    final Color highlight = accent == null
        ? p.accentHi
        : Color.alphaBlend(
            const Color(0xFFFFFFFF).withValues(alpha: 0.35),
            active,
          );

    // The glow color is a brightened version of whatever it glows (same hue,
    // raised lightness), so a glowing value reads as the accent emitting light
    // and the glow always matches whatever accent is active.
    Color brighten(Color c, double byLightness) {
      final HSLColor h = HSLColor.fromColor(c);
      return h
          .withLightness((h.lightness + byLightness).clamp(0.0, 1.0))
          .toColor();
    }

    // The primary glow is the highlight rung, NOT a raw brightening of the deep
    // fill: brightening a fully-saturated deep rung (e.g. the bronze active) only
    // raises lightness while saturation stays pinned at max, so the halo turns a
    // vivid pumpkin orange that no longer reads as the muted button glowing. The
    // highlight is the accent lightened toward white (lower saturation, higher
    // lightness) — a believable "lit" form that stays in the fill's colour
    // family, so the glow matches whatever the (deep) accent is.
    final Color primaryGlow = highlight;
    final Color secondaryGlow = brighten(p.secondary, 0.24);

    List<BoxShadow> glow(Color c, double alpha, double blur, double spread) {
      return <BoxShadow>[
        BoxShadow(
          color: c.withValues(alpha: alpha),
          blurRadius: blur,
          spreadRadius: spread,
        ),
      ];
    }

    // The light glow slider is biased by a straight 0.4: sliding it to 0.4×
    // gave the light default we want, so slider 1.0× should now land there.
    // Applied once to the scale (not per-channel) so the stored factor and every
    // light glow — the depth tokens AND a widget's own glowScale-driven glow —
    // share the one bias. glowScale 1.0 → 0.4 effective; the slider's full 3.0 →
    // 1.2.
    final double biasedGlowScale = glowScale * 0.4;

    return AurisScheme(
      brightness: Brightness.light,
      glowScale: biasedGlowScale,
      surfacePage: p.page,
      surfacePanel: p.panel,
      surfaceInset: p.inset,
      textBright: p.textHi,
      textMid: p.textMid,
      textDim: p.textDim,
      primaryDim: dim,
      primaryActive: active,
      primaryHighlight: highlight,
      onPrimary: p.onAccent,
      secondary: p.secondary,
      secondaryDim: p.secondaryDim,
      borderResting: p.border,
      borderBright: p.borderBright,
      // Light-specific semantic colors: the dark tokens (bright red/green) are
      // too light to clear AA as text on a light surface, so the "bright" rung
      // (used for status TEXT) is a darker, AA-safe red/green and the base rung
      // is a slightly lighter fill color.
      danger: const Color(0xFFC4452F),
      dangerBright: const Color(0xFFA8301F),
      success: const Color(0xFF3A8E5C),
      successBright: const Color(0xFF287049),
      bevel: AurisBevelScale(
        xs: AurisTokens.bevelXs * bevelScale,
        sm: AurisTokens.bevelSm * bevelScale,
        md: AurisTokens.bevelMd * bevelScale,
        lg: AurisTokens.bevelLg * bevelScale,
        xl: AurisTokens.bevelXl * bevelScale,
      ),
      // Amber glow (the brightened/highlight accent) on a wider, softer blur
      // than dark so it reads as a bloom against a bright surface, scaled by the
      // biased glow factor (slider 1.0× ≈ the old 0.4× restraint).
      depthResting: AurisDepth.none,
      depthSubtle: AurisDepth(
        glow: glow(primaryGlow, 0.5, 7, 0),
        borderColor: p.borderBright,
      ).scaled(biasedGlowScale),
      depthActive: AurisDepth(
        glow: glow(primaryGlow, 0.72, 9, 1),
        borderColor: active,
      ).scaled(biasedGlowScale),
      depthDanger: AurisDepth(
        glow: glow(brighten(AurisTokens.dangerBright, 0.12), 0.6, 8, 1),
        borderColor: AurisTokens.dangerBright,
      ).scaled(biasedGlowScale),
      depthSecondary: AurisDepth(
        glow: glow(secondaryGlow, 0.55, 8, 1),
        borderColor: p.secondary,
      ).scaled(biasedGlowScale),
    );
  }

  /// The contrast ratio (vs the light panel) the canonical amber rung clears —
  /// an accent override is darkened until it matches this, so every accent is
  /// corrected to the same depth amber was hand-tuned to (≈ WCAG AA + margin).
  static const double _kAccentContrastTarget = 5.5;

  /// The WCAG relative luminance of [c] (ignoring alpha), from its linearized
  /// sRGB channels.
  static double _luminance(Color c) {
    double lin(double channel) => channel <= 0.03928
        ? channel / 12.92
        : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * lin(c.r) + 0.7152 * lin(c.g) + 0.0722 * lin(c.b);
  }

  /// The WCAG contrast ratio between [a] and [b].
  static double _contrast(Color a, Color b) {
    final double la = _luminance(a);
    final double lb = _luminance(b);
    return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
  }

  /// Darken [c] (hue and saturation held, lightness lowered) until it clears
  /// [target] contrast against [bg]. Used to contrast-correct a bright accent
  /// override for the light surface the same way the canonical amber rung is a
  /// deep bronze. A color already dark enough is returned unchanged.
  static Color _darkenForContrast(Color c, Color bg, double target) {
    HSLColor hsl = HSLColor.fromColor(c);
    while (_contrast(hsl.toColor(), bg) < target && hsl.lightness > 0.0) {
      hsl = hsl.withLightness((hsl.lightness - 0.01).clamp(0.0, 1.0));
    }
    return hsl.toColor();
  }

  /// Re-express a tinted role as [accent]'s hue at the given [saturation] and
  /// [lightness]. Producing the color from the accent's hue (rather than
  /// blending the accent into a warm token) keeps it a clean desaturated accent
  /// instead of a muddy amber+accent mix.
  static Color _accentRole(Color accent, double saturation, double lightness) {
    final HSLColor base = HSLColor.fromColor(accent);
    return HSLColor.fromAHSL(1.0, base.hue, saturation, lightness).toColor();
  }

  /// Retint a glow [BoxShadow] list to [base], preserving each shadow's own
  /// alpha, offset, blur, and spread — used so an accent override carries
  /// through to the primary-ramp glow as well as its border and fill.
  static List<BoxShadow> _tintGlow(List<BoxShadow> glow, Color base) {
    return <BoxShadow>[
      for (final BoxShadow s in glow)
        BoxShadow(
          color: base.withValues(alpha: s.color.a),
          offset: s.offset,
          blurRadius: s.blurRadius,
          spreadRadius: s.spreadRadius,
          blurStyle: s.blurStyle,
        ),
    ];
  }

  @override
  AurisScheme copyWith({
    Brightness? brightness,
    double? glowScale,
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
      glowScale: glowScale ?? this.glowScale,
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
      glowScale: lerpDouble(glowScale, other.glowScale, t),
      surfacePage: Color.lerp(surfacePage, other.surfacePage, t)!,
      surfacePanel: Color.lerp(surfacePanel, other.surfacePanel, t)!,
      surfaceInset: Color.lerp(surfaceInset, other.surfaceInset, t)!,
      textBright: Color.lerp(textBright, other.textBright, t)!,
      textMid: Color.lerp(textMid, other.textMid, t)!,
      textDim: Color.lerp(textDim, other.textDim, t)!,
      primaryDim: Color.lerp(primaryDim, other.primaryDim, t)!,
      primaryActive: Color.lerp(primaryActive, other.primaryActive, t)!,
      primaryHighlight: Color.lerp(
        primaryHighlight,
        other.primaryHighlight,
        t,
      )!,
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
      depthSecondary: AurisDepth._lerp(
        depthSecondary,
        other.depthSecondary,
        t,
      )!,
    );
  }
}

/// Non-nullable [lerpDouble] for the bevel scale, where all inputs are concrete.
@visibleForTesting
double lerpDouble(double a, double b, double t) => a + (b - a) * t;
