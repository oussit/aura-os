
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/effects/particle_engine.dart';
import '../../shared/widgets/aura_button.dart';
import '../../shared/widgets/glass_container.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _logoController;
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = [
    _OnboardingPage(
      title: 'Welcome to\nAURA OS',
      subtitle: 'Your phone is about to come alive',
      gradient: AppColors.auroraGradient,
      particleType: ParticleType.star,
      particleColors: [AppColors.neonCyan, AppColors.neonPurple, AppColors.neonGreen],
    ),
    _OnboardingPage(
      title: 'AI-Powered\nWallpapers',
      subtitle: 'Describe your dream wallpaper and watch it materialize',
      gradient: AppColors.cyberpunkGradient,
      particleType: ParticleType.glow,
      particleColors: [AppColors.neonPink, AppColors.neonPurple],
    ),
    _OnboardingPage(
      title: 'Cinematic\nMotion',
      subtitle: 'Static images transform into living, breathing art',
      gradient: AppColors.fireGradient,
      particleType: ParticleType.fire,
      particleColors: [AppColors.neonOrange, AppColors.neonRed, AppColors.neonYellow],
    ),
    _OnboardingPage(
      title: 'Interactive\nExperience',
      subtitle: 'Your wallpaper reacts to your world — touch, tilt, time, weather',
      gradient: const LinearGradient(
        colors: [Color(0xFF0080FF), Color(0xFF00F5FF)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      particleType: ParticleType.rain,
      particleColors: [AppColors.neonBlue, AppColors.neonCyan],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    
    return Scaffold(
      body: Stack(
        children: [
          // Animated background particles
          ...List.generate(_pages.length, (i) {
            return AnimatedOpacity(
              opacity: _currentPage == i ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 800),
              child: ParticleEngine(
                particleCount: 60,
                type: _pages[i].particleType,
                colors: _pages[i].particleColors,
                speed: 0.8,
                size: 4,
              ),
            );
          }),

          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.9),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Page content
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              final page = _pages[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo animation (first page only)
                    if (index == 0)
                      AnimatedBuilder(
                        animation: _logoController,
                        builder: (context, child) {
                          return Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.neonCyan.withOpacity(
                                    0.3 + _logoController.value * 0.4,
                                  ),
                                  blurRadius: 30 + _logoController.value * 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: child,
                          );
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.primaryGradient,
                          ),
                          child: const Center(
                            child: Text(
                              'A',
                              style: TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textOnNeon,
                              ),
                            ),
                          ),
                        ),
                      )
                        .animate()
                        .fadeIn(duration: 800.ms)
                        .scale(begin: const Offset(0.5, 0.5)),

                    const SizedBox(height: 48),

                    // Title
                    Text(
                      page.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        height: 1.1,
                        letterSpacing: -0.5,
                      ),
                    )
                        .animate(delay: 200.ms)
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: 0.3),

                    const SizedBox(height: 20),

                    // Subtitle
                    Text(
                      page.subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    )
                        .animate(delay: 400.ms)
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: 0.2),
                  ],
                ),
              );
            },
          ),

          // Bottom controls
          Positioned(
            bottom: 60,
            left: 32,
            right: 32,
            child: Column(
              children: [
                // Page indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _currentPage == index ? 32 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: _currentPage == index
                            ? AppColors.neonCyan
                            : AppColors.textTertiary,
                        boxShadow: _currentPage == index
                            ? [
                                BoxShadow(
                                  color: AppColors.neonCyan.withOpacity(0.5),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 32),

                // CTA Button
                AuraButton(
                  text: _currentPage == _pages.length - 1
                      ? 'Start Creating'
                      : 'Next',
                  icon: _currentPage == _pages.length - 1
                      ? Icons.auto_awesome
                      : Icons.arrow_forward,
                  gradient: _pages[_currentPage].gradient,
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                      );
                    } else {
                      _completeOnboarding();
                    }
                  },
                ),

                if (_currentPage < _pages.length - 1) ...[
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _completeOnboarding,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _completeOnboarding() {
    HapticFeedback.heavyImpact();
    // Navigate to main app
    Navigator.of(context).pushReplacementNamed('/home');
  }
}

class _OnboardingPage {
  final String title;
  final String subtitle;
  final Gradient gradient;
  final ParticleType particleType;
  final List<Color> particleColors;

  const _OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.particleType,
    required this.particleColors,
  });
}
