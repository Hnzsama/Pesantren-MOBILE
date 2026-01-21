import 'package:flutter/material.dart';

class ScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final Duration duration;

  const ScaleButton({
    super.key,
    required this.child,
    required this.onTap,
    this.pressedScale = 0.96,
    this.duration = const Duration(milliseconds: 100),
  });

  @override
  State<ScaleButton> createState() => _ScaleButtonState();
}

class _ScaleButtonState extends State<ScaleButton> {
  late double _scale;

  @override
  void initState() {
    super.initState();
    _scale = 1.0;
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap == null) return;
    setState(() => _scale = widget.pressedScale);
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap == null) return;
    // Delay slightly to ensure the animation is visible if the tap is very fast
    Future.delayed(widget.duration, () {
      if (mounted) setState(() => _scale = 1.0);
    });
    widget.onTap?.call();
  }

  void _onTapCancel() {
    if (widget.onTap == null) return;
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: widget.duration,
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }
}
