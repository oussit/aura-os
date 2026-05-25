
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../core/constants/ad_config.dart';
import '../models/user_model.dart';

/// Centralized AdMob service for AURA OS.
/// 
/// Free users see ads; Pro/Ultra users get ad-free experience.
/// 
/// Placements:
/// 1. App Open Ad — on app foreground (with cooldown)
/// 2. Interstitial — after every Nth wallpaper generation
/// 3. Rewarded — "Watch ad for +1 free generation"
/// 4. Banner — bottom of explore feed
/// 5. Native — inline in wallpaper feed
class AdService {
  static final AdService _instance = AdService._();
  factory AdService() => _instance;
  AdService._();

  // State
  AppOpenAd? _appOpenAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _isAppOpenAdShowing = false;
  DateTime? _lastAppOpenAdTime;
  int _generationCount = 0;
  int _rewardedToday = 0;
  bool _initialized = false;

  // Callbacks
  VoidCallback? onRewardedEarned;

  /// Initialize Mobile Ads SDK
  Future<void> initialize() async {
    if (_initialized) return;
    await MobileAds.instance.initialize();
    _initialized = true;
    debugPrint('🎯 AdMob initialized');
    
    // Pre-load ads
    _loadAppOpenAd();
    _loadInterstitialAd();
    _loadRewardedAd();
  }

  // =========================================================================
  // APP OPEN AD — Shows when user returns to app
  // =========================================================================

  void _loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: AdConfig.appOpenAdUnit,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          debugPrint('✅ App Open Ad loaded');
        },
        onAdFailedToLoad: (error) {
          debugPrint('❌ App Open Ad failed: $error');
          // Retry after delay
          Future.delayed(const Duration(minutes: 1), _loadAppOpenAd);
        },
      ),
    );
  }

  /// Call when app comes to foreground. Only shows for free users.
  Future<void> showAppOpenAdIfReady(SubscriptionTier tier) async {
    if (tier != SubscriptionTier.free) return;
    if (_appOpenAd == null) return;
    if (_isAppOpenAdShowing) return;
    
    // Cooldown check
    if (_lastAppOpenAdTime != null) {
      final elapsed = DateTime.now().difference(_lastAppOpenAdTime!);
      if (elapsed < AdConfig.appOpenCooldown) return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isAppOpenAdShowing = true;
        _lastAppOpenAdTime = DateTime.now();
      },
      onAdDismissedFullScreenContent: (ad) {
        _isAppOpenAdShowing = false;
        ad.dispose();
        _appOpenAd = null;
        _loadAppOpenAd(); // Pre-load next
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isAppOpenAdShowing = false;
        ad.dispose();
        _appOpenAd = null;
        _loadAppOpenAd();
      },
    );

    await _appOpenAd!.show();
  }

  // =========================================================================
  // INTERSTITIAL — Shows after wallpaper generation
  // =========================================================================

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdConfig.interstitialAdUnit,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          debugPrint('✅ Interstitial loaded');
        },
        onAdFailedToLoad: (error) {
          debugPrint('❌ Interstitial failed: $error');
          Future.delayed(const Duration(seconds: 30), _loadInterstitialAd);
        },
      ),
    );
  }

  /// Call after each generation completes. Shows every Nth generation for free users.
  Future<bool> showInterstitialAfterGeneration(SubscriptionTier tier) async {
    if (tier != SubscriptionTier.free) return false;
    
    _generationCount++;
    if (_generationCount % AdConfig.interstitialFrequency != 0) return false;
    if (_interstitialAd == null) return false;

    final completer = Completer<bool>();

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitialAd();
        completer.complete(true);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitialAd();
        completer.complete(false);
      },
    );

    await _interstitialAd!.show();
    return completer.future;
  }

  // =========================================================================
  // REWARDED — "Watch ad for +1 generation"
  // =========================================================================

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AdConfig.rewardedAdUnit,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          debugPrint('✅ Rewarded Ad loaded');
        },
        onAdFailedToLoad: (error) {
          debugPrint('❌ Rewarded Ad failed: $error');
          Future.delayed(const Duration(seconds: 30), _loadRewardedAd);
        },
      ),
    );
  }

  /// Returns true if reward was earned.
  Future<bool> showRewardedForExtraGeneration() async {
    if (_rewardedToday >= AdConfig.maxRewardedPerDay) return false;
    if (_rewardedAd == null) return false;

    final completer = Completer<bool>();

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _loadRewardedAd();
        if (!completer.isCompleted) completer.complete(false);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        _loadRewardedAd();
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        _rewardedToday++;
        debugPrint('🎁 Reward earned: ${reward.amount} ${reward.type}');
        onRewardedEarned?.call();
        if (!completer.isCompleted) completer.complete(true);
      },
    );

    return completer.future;
  }

  /// Check if rewarded ads are still available today
  bool get canWatchRewarded => _rewardedToday < AdConfig.maxRewardedPerDay;
  int get rewardedRemaining => AdConfig.maxRewardedPerDay - _rewardedToday;

  // =========================================================================
  // BANNER — For explore feed bottom
  // =========================================================================

  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: AdConfig.bannerAdUnit,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => debugPrint('✅ Banner loaded'),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('❌ Banner failed: $error');
        },
      ),
    )..load();
  }

  // =========================================================================
  // Native Ad — For inline feed
  // =========================================================================

  NativeAd createNativeAd() {
    return NativeAd(
      adUnitId: AdConfig.nativeAdUnit,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) => debugPrint('✅ Native loaded'),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('❌ Native failed: $error');
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: const Color(0xFF111111),
        cornerRadius: 16,
        callToActionStyle: NativeTemplateTextStyle(
          size: 14,
          style: NativeTemplateFontStyle.bold,
          backgroundcolor: const Color(0xFF00F5FF),
        ),
      ),
    )..load();
  }

  // =========================================================================
  // Cleanup
  // =========================================================================

  void dispose() {
    _appOpenAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }

  /// Reset daily rewarded count (call at midnight)
  void resetDailyRewarded() => _rewardedToday = 0;
}
