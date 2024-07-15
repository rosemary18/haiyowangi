import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class PopUpContent extends StatefulWidget {

  final Widget child;
  final Widget Function(BuildContext context, VoidCallback close)? contentBuilder;
  final VoidCallback? onOpened;
  final VoidCallback? onClosed;

  const PopUpContent({
    super.key,
    required this.child,
    this.contentBuilder,
    this.onOpened,
    this.onClosed
  });

  @override
  State<PopUpContent> createState() => _PopUpContentState();
}

class _PopUpContentState extends State<PopUpContent> {

  OverlayEntry? _overlayEntry;
  late TapGestureRecognizer _tapOutsideRecognizer;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _tapOutsideRecognizer = TapGestureRecognizer()..onTap = _handleTapOutside;
  }

  @override
  void dispose() {
    _tapOutsideRecognizer.dispose();
    super.dispose();
  }

  void _showPopupMenu(BuildContext context, Offset offset) {
    if (_overlayEntry == null) {
      final overlay = Overlay.of(context);
      final RenderBox button = context.findRenderObject() as RenderBox;
      final Offset buttonPosition = button.localToGlobal(Offset.zero);
      final size = MediaQuery.of(context).size;

      _overlayEntry = OverlayEntry(
        builder: (context) => AnimatedOpacity(
          duration: const Duration(milliseconds: 2800),
          opacity: _isVisible ? 1.0 : 0.0,
          child: Stack(
            children: [
              GestureDetector(
                onTap: _handleTapOutside,
                child: Container(
                  color: Colors.transparent,
                ),
              ),
              Positioned(
                left: (buttonPosition.dx < (size.width / 2))
                    ? buttonPosition.dx
                    : null,
                right: (buttonPosition.dx < (size.width / 2))
                    ? null
                    : (size.width - (buttonPosition.dx + button.size.width)),
                top: buttonPosition.dy + button.size.height + 8,
                child: widget.contentBuilder?.call(context, _removeOverlay) ?? Container(),
              ),
            ],
          ),
        ),
      );

      overlay.insert(_overlayEntry!);
      setState(() {
        _isVisible = true;
      });
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _isVisible = false;
    });
  }

  void _handleTapOutside() {
    _removeOverlay();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        _showPopupMenu(context, details.globalPosition);
      },
      child: widget.child,
    );
  }
}
