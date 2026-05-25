
/// AURA OS AdMob Configuration
/// 
/// Test IDs are used in debug mode. Production IDs come from .env or remote config.
class AdConfig {
  // ===== TEST IDs (Google-provided, safe for development) =====
  static const String testAppId = 'ca-app-pub-3940256099942544~3347511713';
  
  static const String testBannerAdUnit = 'ca-app-pub-3940256099942544/6300978111';
  static const String testInterstitialAdUnit = 'ca-app-pub-3940256099942544/1033173712';
  static const String testRewardedAdUnit = 'ca-app-pub-3940256099942544/5224354917';
  static const String testAppOpenAdUnit = 'ca-app-pub-3940256099942544/9257395921';
  static const String testNativeAdUnit = 'ca-app-pub-3940256099942544/2247696110';

  // ===== PRODUCTION IDs (replace with real AdMob unit IDs) =====
  static const String prodBannerAdUnit = 'ca-app-pub-XXXXX/XXXXX';
  static const String prodInterstitialAdUnit = 'ca-app-pub-XXXXX/XXXXX';
  static const String prodRewardedAdUnit = 'ca-app-pub-XXXXX/XXXXX';
  static const String prodAppOpenAdUnit = 'ca-app-pub-XXXXX/XXXXX';
  static const String prodNativeAdUnit = 'ca-app-pub-XXXXX/XXXXX';

  // ===== Frequency Caps =====
  static const int interstitialFrequency = 3; // show every N generations
  static const Duration appOpenCooldown = Duration(minutes: 5);
  static const int maxRewardedPerDay = 5;

  // ===== Getters (auto-switch based on debug mode) =====
  // In production: use prod IDs. During dev: use test IDs.
  static String get bannerAdUnit => testBannerAdUnit;
  static String get interstitialAdUnit => testInterstitialAdUnit;
  static String get rewardedAdUnit => testRewardedAdUnit;
  static String get appOpenAdUnit => testAppOpenAdUnit;
  static String get nativeAdUnit => testNativeAdUnit;
}
