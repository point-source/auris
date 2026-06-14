import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../painters/chamfer_border.dart';
import '../scheme.dart';
import '../tokens.dart';
import 'auris_container.dart';

/// A single-select radio with a **chamfered** indicator — Material's [Radio] is
/// circular with no shape hook, so this is the geometric replacement
/// (§spec:custom-widgets). The selected state shows a filled chamfered pip
/// inside a chamfered box; an empty box otherwise.
///
/// Selection is group-based like [Radio]: the control is selected when [value]
/// equals [groupValue], and tapping (or space/enter while focused) reports
/// [value] to [onChanged]. A null [onChanged] disables the control (opacity 0.5,
/// no interaction); an enabled control shows a gold keyboard-focus ring. All
/// colors / bevel / glow resolve from the [AurisScheme].
class AurisRadio<T> extends StatefulWidget {
  /// Creates a chamfered radio.
  const AurisRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.label,
    this.focusNode,
    this.autofocus = false,
  });

  /// The value this radio represents.
  final T value;

  /// The currently selected value of the group.
  final T? groupValue;

  /// Called with [value] when this radio is chosen. Null disables it.
  final ValueChanged<T>? onChanged;

  /// Optional label shown after the indicator.
  final String? label;

  /// An optional external focus node.
  final FocusNode? focusNode;

  /// Whether the control should autofocus.
  final bool autofocus;

  @override
  State<AurisRadio<T>> createState() => _AurisRadioState<T>();
}

class _AurisRadioState<T> extends State<AurisRadio<T>> {
  FocusNode? _ownNode;
  bool _focused = false;

  FocusNode get _node => widget.focusNode ?? (_ownNode ??= FocusNode());
  bool get _enabled => widget.onChanged != null;
  bool get _selected => widget.value == widget.groupValue;

  @override
  void dispose() {
    _ownNode?.dispose();
    super.dispose();
  }

  void _select() {
    if (_enabled && !_selected) {
      widget.onChanged!(widget.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AurisScheme scheme = Theme.of(context).extension<AurisScheme>()!;
    final Color border = !_enabled
        ? scheme.borderResting
        : (_selected ? scheme.primaryActive : scheme.borderBright);

    final Widget indicator = SizedBox(
      // 18px box + reserved focus-ring space.
      width: 24,
      height: 24,
      child: Center(
        child: DecoratedBox(
          decoration: ShapeDecoration(
            shape: AurisChamferBorder(
              cut: scheme.bevel.xs + 2,
              side: _focused && _enabled
                  ? BorderSide(color: scheme.primaryActive, width: 1.5)
                  : BorderSide.none,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: AurisContainer(
              cut: scheme.bevel.xs,
              width: 18,
              height: 18,
              fill: scheme.surfaceInset,
              borderColor: border,
              alignment: Alignment.center,
              child: _selected
                  ? DecoratedBox(
                      decoration: ShapeDecoration(
                        color: _enabled ? scheme.primaryActive : scheme.textDim,
                        shape: const AurisChamferBorder(cut: 2),
                        shadows:
                            _enabled ? scheme.depthSubtle.glow : null,
                      ),
                      child: const SizedBox(width: 8, height: 8),
                    )
                  : const SizedBox(width: 8, height: 8),
            ),
          ),
        ),
      ),
    );

    final List<Widget> children = <Widget>[indicator];
    if (widget.label != null) {
      children.add(const SizedBox(width: 8));
      children.add(
        Flexible(
          child: Text(
            widget.label!,
            style: TextStyle(
              fontFamily: AurisTokens.fontBody,
              fontSize: 13,
              letterSpacing: AurisTokens.trackingBody,
              color: _enabled ? scheme.textBright : scheme.textDim,
            ),
          ),
        ),
      );
    }

    Widget result = Focus(
      focusNode: _node,
      autofocus: widget.autofocus,
      canRequestFocus: _enabled,
      onFocusChange: (bool f) => setState(() => _focused = f),
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.space ||
                event.logicalKey == LogicalKeyboardKey.enter)) {
          _select();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: MouseRegion(
        cursor:
            _enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            _node.requestFocus();
            _select();
          },
          child: Row(mainAxisSize: MainAxisSize.min, children: children),
        ),
      ),
    );

    if (!_enabled) {
      result = Opacity(opacity: 0.5, child: result);
    }
    return result;
  }
}
