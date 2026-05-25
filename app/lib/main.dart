
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_colors.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/wallpaper/home_screen.dart';
import 'features/generator/generator_screen.dart';
import 'features/ai_director/ai_director_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Set system UI
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.black,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  
  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const AuraOSApp());
}

class AuraOSApp extends StatelessWidget {
  const AuraOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AURA OS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const OnboardingScreen(),
      routes: {
        '/home': (_) => const HomeScreen(),
        '/generator': (_) => const GeneratorScreen(),
        '/ai-director': (_) => const AIDirectorScreen(),
        '/wallpaper/detail': (_) => const _WallpaperDetailPlaceholder(),
      },
    );
  }
}

class _WallpaperDetailPlaceholder extends StatelessWidget {
  const _WallpaperDetailPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wallpaper, size: 64, color: AppColors.neonCyan),
            const SizedBox(height: 16),
            const Text('Wallpaper Detail', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
