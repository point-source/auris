/// Auris custom HUD widget library — standalone widgets for patterns that
/// `ThemeData` cannot express (chamfered toggles, segmented meters, terminals,
/// ornaments, stat tiles).
///
/// All widgets read their design-defining values from the resolved
/// `AurisScheme` via `Theme.of(context).extension<AurisScheme>()`, so they
/// honor customization overrides and future brightness variants.
///
/// The widgets themselves are added in later batches; this barrel exists now so
/// the public surface is stable. The shared scheme/tokens are re-exported here
/// for convenience.
library;

export 'src/painters/chamfer_clipper.dart';
export 'src/scheme.dart';
export 'src/tokens.dart';
export 'src/widgets/auris_badge.dart';
export 'src/widgets/auris_container.dart';
export 'src/widgets/auris_data_row.dart';
export 'src/widgets/auris_hex_ornament.dart';
export 'src/widgets/auris_notification.dart';
export 'src/widgets/auris_panel.dart';
export 'src/widgets/auris_scan_bracket.dart';
export 'src/widgets/auris_stat_card.dart';
