import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../scheme.dart';
import '../tokens.dart';
import 'auris_container.dart';

/// A single option in an [AurisSelect].
@immutable
class AurisSelectOption<T> {
  /// Creates an option carrying [value], shown as [label].
  const AurisSelectOption({required this.value, required this.label});

  /// The value reported to `onChanged` when this option is chosen.
  final T value;

  /// The monospace label shown in the trigger and popup row.
  final String label;
}

/// A custom dropdown matching the intended HUD look the native `DropdownMenu`
/// cannot reach (§spec:custom-widgets): a chamfered trigger box showing the
/// value in monospace with a **gold caret that rotates 180° when open**, and a
/// chamfered popup panel (gold-tinted border, amber depth glow) of monospace
/// rows. Each row is `textMid` at rest / `textBright` on hover; the selected
/// row is `bright` on a faint gold tint; rows are separated by a 1px divider in
/// the border color.
///
/// The popup is an [OverlayPortal] dismissed on outside tap; it is
/// keyboard-navigable (up/down to move, enter to select, escape to close). A
/// disabled select (null [onChanged]) renders at opacity 0.5 with no
/// interaction; the trigger shows a gold keyboard-focus outline when focused
/// (§spec:accessibility). All colors / bevel / glow resolve from the
/// [AurisScheme].
class AurisSelect<T> extends StatefulWidget {
  /// Creates a custom select.
  const AurisSelect({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.placeholder = 'SELECT',
    this.width,
    this.focusNode,
  });

  /// The selectable options.
  final List<AurisSelectOption<T>> options;

  /// The currently selected value, or null for the placeholder.
  final T? value;

  /// Called with the chosen value. Null disables the control.
  final ValueChanged<T>? onChanged;

  /// Trigger text shown when no value is selected.
  final String placeholder;

  /// Optional fixed trigger width.
  final double? width;

  /// An optional external focus node for the trigger.
  final FocusNode? focusNode;

  @override
  State<AurisSelect<T>> createState() => _AurisSelectState<T>();
}

class _AurisSelectState<T> extends State<AurisSelect<T>>
    with SingleTickerProviderStateMixin {
  final OverlayPortalController _portal = OverlayPortalController();
  final LayerLink _link = LayerLink();
  late final AnimationController _caret;
  FocusNode? _ownFocusNode;
  int _highlighted = -1;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    // Created eagerly so the ticker is never first built during dispose (which
    // would do an unsafe TickerMode lookup on a deactivated element if the
    // select was never opened).
    _caret = AnimationController(
      vsync: this,
      duration: AurisTokens.durationFast,
    );
  }

  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownFocusNode ??= FocusNode());

  bool get _enabled => widget.onChanged != null;

  bool get _reduceMotion =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  @override
  void dispose() {
    _caret.dispose();
    _ownFocusNode?.dispose();
    super.dispose();
  }

  void _open() {
    if (!_enabled || _portal.isShowing) return;
    setState(() {
      _highlighted = widget.options.indexWhere(
        (AurisSelectOption<T> o) => o.value == widget.value,
      );
    });
    _portal.show();
    if (_reduceMotion) {
      _caret.value = 1.0;
    } else {
      _caret.forward();
    }
  }

  void _close() {
    if (!_portal.isShowing) return;
    _portal.hide();
    if (_reduceMotion) {
      _caret.value = 0.0;
    } else {
      _caret.reverse();
    }
  }

  void _toggle() => _portal.isShowing ? _close() : _open();

  void _select(AurisSelectOption<T> option) {
    widget.onChanged?.call(option.value);
    _close();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final LogicalKeyboardKey key = event.logicalKey;
    if (!_portal.isShowing) {
      if (key == LogicalKeyboardKey.enter ||
          key == LogicalKeyboardKey.space ||
          key == LogicalKeyboardKey.arrowDown) {
        _open();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }
    if (key == LogicalKeyboardKey.escape) {
      _close();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown) {
      setState(
        () => _highlighted =
            (_highlighted + 1).clamp(0, widget.options.length - 1),
      );
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      setState(
        () => _highlighted =
            (_highlighted - 1).clamp(0, widget.options.length - 1),
      );
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.space) {
      if (_highlighted >= 0 && _highlighted < widget.options.length) {
        _select(widget.options[_highlighted]);
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  String get _triggerLabel {
    final int index = widget.options.indexWhere(
      (AurisSelectOption<T> o) => o.value == widget.value,
    );
    return index >= 0 ? widget.options[index].label : widget.placeholder;
  }

  @override
  Widget build(BuildContext context) {
    final AurisScheme scheme = Theme.of(context).extension<AurisScheme>()!;
    final bool hasValue = widget.options.any(
      (AurisSelectOption<T> o) => o.value == widget.value,
    );

    Widget trigger = Focus(
      focusNode: _focusNode,
      canRequestFocus: _enabled,
      onFocusChange: (bool f) => setState(() => _focused = f),
      onKeyEvent: _onKey,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _focusNode.requestFocus();
          _toggle();
        },
        child: AurisContainer(
          cut: scheme.bevel.md,
          fill: scheme.surfaceInset,
          borderColor: _focused && _enabled
              ? scheme.primaryActive
              : scheme.borderBright,
          padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  _triggerLabel.toUpperCase(),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AurisTokens.fontMono,
                    fontFamilyFallback: AurisTokens.fontMonoFallback,
                    fontSize: 13,
                    letterSpacing: AurisTokens.trackingLabel,
                    color: hasValue ? scheme.textBright : scheme.textMid,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              RotationTransition(
                turns: Tween<double>(begin: 0, end: 0.5).animate(_caret),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: scheme.primaryActive,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!_enabled) {
      trigger = Opacity(opacity: 0.5, child: trigger);
    }

    final Widget portal = OverlayPortal(
      controller: _portal,
      overlayChildBuilder: (BuildContext context) {
        return _SelectPopup<T>(
          link: _link,
          scheme: scheme,
          options: widget.options,
          selected: widget.value,
          highlighted: _highlighted,
          onSelect: _select,
          onDismiss: _close,
          onHover: (int i) => setState(() => _highlighted = i),
        );
      },
      child: CompositedTransformTarget(link: _link, child: trigger),
    );

    if (widget.width != null) {
      return SizedBox(width: widget.width, child: portal);
    }
    return portal;
  }
}

/// The chamfered, glowing popup panel of monospace rows.
class _SelectPopup<T> extends StatelessWidget {
  const _SelectPopup({
    required this.link,
    required this.scheme,
    required this.options,
    required this.selected,
    required this.highlighted,
    required this.onSelect,
    required this.onDismiss,
    required this.onHover,
  });

  final LayerLink link;
  final AurisScheme scheme;
  final List<AurisSelectOption<T>> options;
  final T? selected;
  final int highlighted;
  final ValueChanged<AurisSelectOption<T>> onSelect;
  final VoidCallback onDismiss;
  final ValueChanged<int> onHover;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // Full-screen dismiss layer for outside-tap.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onDismiss,
          ),
        ),
        CompositedTransformFollower(
          link: link,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: const Offset(0, 6),
          // Match the trigger's width so the panel doesn't expand to fill the
          // overlay and run off the right edge of the screen.
          child: SizedBox(
            width: link.leaderSize?.width,
            child: AurisContainer(
              cut: scheme.bevel.md,
              fill: scheme.surfacePanel,
              borderColor: scheme.primaryActive.withValues(alpha: 0.7),
              depth: scheme.depthActive,
              padding: EdgeInsets.zero,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 260),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      for (int i = 0; i < options.length; i++)
                        _SelectRow<T>(
                          scheme: scheme,
                          option: options[i],
                          isSelected: options[i].value == selected,
                          isHighlighted: i == highlighted,
                          showDivider: i < options.length - 1,
                          onTap: () => onSelect(options[i]),
                          onHover: () => onHover(i),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// One popup row with hover/selected highlight and a bottom divider.
class _SelectRow<T> extends StatelessWidget {
  const _SelectRow({
    required this.scheme,
    required this.option,
    required this.isSelected,
    required this.isHighlighted,
    required this.showDivider,
    required this.onTap,
    required this.onHover,
  });

  final AurisScheme scheme;
  final AurisSelectOption<T> option;
  final bool isSelected;
  final bool isHighlighted;
  final bool showDivider;
  final VoidCallback onTap;
  final VoidCallback onHover;

  @override
  Widget build(BuildContext context) {
    final Color textColor = isSelected
        ? scheme.primaryHighlight
        : (isHighlighted ? scheme.textBright : scheme.textMid);
    final Color? fill = isSelected
        ? scheme.primaryActive.withValues(alpha: 0.12)
        : (isHighlighted
            ? scheme.primaryActive.withValues(alpha: 0.05)
            : null);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => onHover(),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: fill,
            border: showDivider
                ? Border(
                    bottom: BorderSide(color: scheme.borderResting),
                  )
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    option.label.toUpperCase(),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AurisTokens.fontMono,
                      fontFamilyFallback: AurisTokens.fontMonoFallback,
                      fontSize: 13,
                      letterSpacing: AurisTokens.trackingLabel,
                      color: textColor,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check, size: 16, color: scheme.primaryActive),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
