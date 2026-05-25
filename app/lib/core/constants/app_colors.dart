
import 'package:flutter/material.dart';

class AppColors {
  // Pure AMOLED Blacks
  static const Color black = Color(0xFF000000);
  static const Color blackLight = Color(0xFF0A0A0A);
  static const Color blackCard = Color(0xFF111111);
  static const Color blackElevated = Color(0xFF1A1A1A);
  static const Color blackSurface = Color(0xFF0D0D0D);
  
  // Neon Accent Colors
  static const Color neonCyan = Color(0xFF00F5FF);
  static const Color neonPurple = Color(0xFFB24BF3);
  static const Color neonPink = Color(0xFFFF2D95);
  static const Color neonGreen = Color(0xFF39FF14);
  static const Color neonOrange = Color(0xFFFF6B00);
  static const Color neonBlue = Color(0xFF0080FF);
  static const Color neonRed = Color(0xFFFF0040);
  static const Color neonYellow = Color(0xFFFFE500);
  
  // Primary Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [neonCyan, neonPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient fireGradient = LinearGradient(
    colors: [neonOrange, neonRed, neonPink],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );
  
  static const LinearGradient auroraGradient = LinearGradient(
    colors: [neonGreen, neonCyan, neonBlue, neonPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient cyberpunkGradient = LinearGradient(
    colors: [neonPink, neonPurple, neonBlue],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Glass Colors
  static const Color glassWhite = Color(0x0DFFFFFF);
  static const Color glassBorder = Color(0x1AFFFFFF);
  static const Color glassHighlight = Color(0x14FFFFFF);
  
  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF);
  static const Color textTertiary = Color(0x66FFFFFF);
  static const Color textOnNeon = Color(0xFF000000);
  
  // Semantic
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFAB00);
  static const Color error = Color(0xFFFF0040);
  static const Color info = Color(0xFF00B0FF);
  
  // Premium Gold
  static const Color premiumGold = Color(0xFFFFD700);
  static const Color premiumGoldDark = Color(0xFFB8860B);
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA000), Color(0xFFFF6F00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
