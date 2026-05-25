
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';

class AuraButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Gradient? gradient;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;
  final double height;
  final double borderRadius;
  final Color? glowColor;

  const AuraButton({
    super.key,
    required this.text,
    this.onPressed,
    this.gradient,
    this.icon,
    this.isLoading = false,
    this.isExpanded = true,
    this.height = 56,
    this.borderRadius = 16,
    this.glowColor,
  });

  @override
  State<AuraButton> createState() => _AuraButtonState();
}

class _AuraButtonState extends State<AuraButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glowColor = widget.glowColor ?? AppColors.neonCyan;
    
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: widget.isExpanded ? double.infinity : null,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                color: glowColor.withOpacity(_glowAnimation.value * 0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: glowColor.withOpacity(_glowAnimation.value * 0.2),
                blurRadius: 40,
                spreadRadius: 4,
              ),
            ],
          ),
          child: child,
        );
      },
      child: ElevatedButton(
        onPressed: widget.isLoading
            ? null
            : () {
                HapticFeedback.mediumImpact();
                widget.onPressed?.call();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: widget.gradient ?? AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          child: Container(
            alignment: Alignment.center,
            child: widget.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: AppColors.textOnNeon,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: AppColors.textOnNeon, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.text,
                        style: const TextStyle(
                          color: AppColors.textOnNeon,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
