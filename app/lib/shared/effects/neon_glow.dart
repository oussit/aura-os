
import 'package:flutter/material.dart';

class NeonGlow extends StatelessWidget {
  final Widget child;
  final Color color;
  final double blurRadius;
  final double spreadRadius;
  final Offset offset;

  const NeonGlow({
    super.key,
    required this.child,
    this.color = Colors.cyan,
    this.blurRadius = 15,
    this.spreadRadius = 0,
    this.offset = Offset.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: blurRadius,
            spreadRadius: spreadRadius,
            offset: offset,
          ),
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: blurRadius * 2,
            spreadRadius: spreadRadius * 1.5,
            offset: offset,
          ),
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: blurRadius * 3,
            spreadRadius: spreadRadius * 2,
            offset: offset,
          ),
        ],
      ),
      child: child,
    );
  }
}

class PulsingNeon extends StatefulWidget {
  final Widget child;
  final Color color;
  final Duration duration;

  const PulsingNeon({
    super.key,
    required this.child,
    this.color = Colors.cyan,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<PulsingNeon> createState() => _PulsingNeonState();
}

class _PulsingNeonState extends State<PulsingNeon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return NeonGlow(
          color: widget.color,
          blurRadius: 10 + _controller.value * 15,
          child: child!,
        );
      },
      child: widget.child,
    );
  }
}
