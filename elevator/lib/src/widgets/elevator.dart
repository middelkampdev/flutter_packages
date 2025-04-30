import 'package:flutter/material.dart';

/// A widget that creates an elevated overlay effect when hovered.
///
/// The [Elevator] widget creates a hover effect by rendering its child twice:
/// once in the normal widget tree and once in an overlay. When the user hovers
/// over the widget, it shows the overlay version while hiding the original,
/// creating an "elevation" effect.
///
/// The overlay version is automatically clipped to stay within any scrollable
/// parent's viewport, supporting both vertical and horizontal scrolling.
///
/// Example usage:
/// ```dart
/// Elevator(
///   builder: (elevated) => Container(
///     decoration: BoxDecoration(
///       boxShadow: elevated ? [BoxShadow(...)] : null,
///     ),
///     child: YourContent(),
///   ),
/// )
/// ```
///
/// The [builder] function is called with a boolean indicating whether the
/// widget is currently elevated, allowing you to modify the appearance based
/// on the elevation state.
class Elevator extends StatefulWidget {
  /// Creates a new [Elevator] widget.
  ///
  /// The [builder] function is called with a boolean indicating whether the
  /// widget is currently elevated, allowing you to modify the appearance based
  /// on the elevation state.
  const Elevator({required this.builder, super.key, this.dismissOnTap = true});

  /// Whether the elevated state should be dismissed when tapping on the
  /// overlay.
  ///
  /// When true, tapping on the elevated overlay will cause it to return
  /// to its non-elevated state. Defaults to true.
  final bool dismissOnTap;

  /// Builder function that creates the widget's content.
  ///
  /// This function is called with a boolean parameter elevated that indicates
  /// whether the widget is currently in an elevated state. This allows you to
  /// modify the widget's appearance based on its elevation state.
  ///
  /// The builder is called twice internally - once for the regular widget tree
  /// and once for the overlay, but only one version is visible at a time.
  // ignore: avoid_positional_boolean_parameters
  final Widget Function(bool elevated) builder;

  @override
  State<Elevator> createState() => _ElevatorState();
}

class _ElevatorState extends State<Elevator> {
  OverlayEntry? _overlayEntry;
  final _layerLink = LayerLink();
  bool _elevated = false;

  @override
  void initState() {
    super.initState();
    if (_elevated) {
      _onElevatedChanged();
    }
  }

  /// Handles state changes when the elevation status changes.
  ///
  /// This method ensures that elevation changes are processed after the current
  /// frame is complete, preventing potential layout issues.
  void _onElevatedChanged() {
    if (_elevated) {
      _elevate();
    } else {
      _lower();
    }
  }

  /// Finds the nearest scrollable ancestor in the widget tree.
  ///
  /// This is used to properly clip the overlay within scrollable areas.
  /// Returns null if no scrollable ancestor is found.
  ScrollableState? _findAncestorScrollable(BuildContext context) {
    ScrollableState? scrollable;
    context.visitAncestorElements((e) {
      if (e.widget is Scrollable) {
        scrollable = (e as StatefulElement).state as ScrollableState;
        return false;
      }
      return true;
    });
    return scrollable;
  }

  /// Creates and shows the elevated overlay.
  ///
  /// This method:
  /// 1. Creates an overlay entry positioned exactly over the original widget
  /// 2. Handles pointer events for dismissal
  /// 3. Clips the overlay within any scrollable parent's viewport
  void _elevate() {
    final overlay = Overlay.of(context, rootOverlay: true);
    if (_overlayEntry != null) {
      _lower();
    }

    final scrollable = _findAncestorScrollable(context);
    final targetBox = context.findRenderObject()! as RenderBox;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        final targetSize = targetBox.size;

        final child = SizedBox.expand(
          child: Stack(
            children: [
              CompositedTransformFollower(
                link: _layerLink,
                child: Material(
                  type: MaterialType.transparency,
                  child: SizedBox(
                    width: targetSize.width,
                    height: targetSize.height,
                    child: Listener(
                      behavior: HitTestBehavior.opaque,
                      onPointerUp: (event) {
                        if (!widget.dismissOnTap) {
                          return;
                        }
                        _elevated = false;
                        _onElevatedChanged();
                      },
                      child: MouseRegion(
                        onExit: (_) {
                          _elevated = false;
                          _onElevatedChanged();
                        },
                        child: widget.builder(_elevated),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

        // If we found a scrollable ancestor, use its viewport as the clip
        // boundary
        if (scrollable != null) {
          final renderBox = scrollable.context.findRenderObject() as RenderBox?;
          if (renderBox != null) {
            final position = renderBox.localToGlobal(Offset.zero);
            final axis = scrollable.widget.axis;
            switch (axis) {
              // For vertical scrolling, only clip top and bottom
              case Axis.vertical:
                return Positioned(
                  left: 0,
                  top: position.dy,
                  right: 0,
                  height: renderBox.size.height,
                  child: ClipRect(child: child),
                );
              // For horizontal scrolling, only clip left and right
              case Axis.horizontal:
                return Positioned(
                  left: position.dx,
                  top: 0,
                  width: renderBox.size.width,
                  bottom: 0,
                  child: ClipRect(child: child),
                );
            }
          }
        }

        return child;
      },
    );

    overlay.insert(_overlayEntry!);
    setState(() {});
  }

  /// Removes the elevated overlay if it exists.
  ///
  /// This method safely removes the overlay entry and triggers a rebuild
  /// of the widget to ensure proper visual state.
  void _lower() {
    if (_overlayEntry == null) {
      return;
    }
    _overlayEntry!.remove();
    _overlayEntry = null;
    setState(() {});
  }

  @override
  void dispose() {
    _lower();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        _elevated = true;
        _onElevatedChanged();
      },
      child: CompositedTransformTarget(
        link: _layerLink,
        child: Opacity(
          opacity: _elevated ? 0 : 1,
          child: widget.builder(_elevated),
        ),
      ),
    );
  }
}
