
class AppConstants {
  static const String appName = 'AURA OS';
  static const String appTagline = 'Your Phone, Alive.';
  static const String appVersion = '1.0.0';
  
  // API
  static const String baseUrl = 'https://api.auraos.app';
  static const String wsUrl = 'wss://ws.auraos.app';
  static const String aiGenerateEndpoint = '/v1/ai/generate';
  static const String aiEnhanceEndpoint = '/v1/ai/enhance-prompt';
  static const String wallpapersEndpoint = '/v1/wallpapers';
  static const String socialEndpoint = '/v1/social';
  static const String userEndpoint = '/v1/user';
  static const String subscriptionEndpoint = '/v1/subscription';
  
  // Limits
  static const int freeGenerationsPerDay = 3;
  static const int premiumGenerationsPerDay = 999;
  static const int maxPromptLength = 500;
  static const int wallpaperCacheLimit = 50;
  static const double maxImageResolution = 4096;
  
  // Animation
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration slowAnimationDuration = Duration(milliseconds: 600);
  static const Duration cinematicAnimationDuration = Duration(milliseconds: 1200);
  static const Duration springAnimationDuration = Duration(milliseconds: 400);
  
  // Wallpaper Engine
  static const int targetFps = 60;
  static const int lowPowerFps = 30;
  static const int particleCount = 200;
  static const int maxParallaxLayers = 5;
  
  // Hive Boxes
  static const String settingsBox = 'settings';
  static const String wallpapersBox = 'wallpapers';
  static const String cacheBox = 'cache';
  static const String userProfileBox = 'user_profile';
  
  // Style Presets
  static const List<String> stylePresets = [
    'Cyberpunk',
    'Anime',
    'AMOLED Dark',
    'Fantasy',
    'Sci-Fi',
    'Realistic',
    'Abstract',
    'Gaming',
    'Nature',
    'Futuristic',
    'Liquid Chrome',
    'Neon Noir',
  ];
  
  // Negative Prompt Defaults
  static const String defaultNegativePrompt = 
    'blurry, low quality, distorted, ugly, watermark, text, signature, '
    'deformed, disfigured, bad anatomy, bad proportions, extra limbs, '
    'duplicate, morbid, mutilated, poorly drawn, bad hands, missing fingers';
}
