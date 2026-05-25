
import 'dart:async';
import 'package:dio/dio.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';

class SubscriptionService {
  final Dio _dio;
  
  static const String proMonthlyId = 'auraos_pro_monthly';
  static const String proYearlyId = 'auraos_pro_yearly';
  static const String ultraMonthlyId = 'auraos_ultra_monthly';
  static const String ultraYearlyId = 'auraos_ultra_yearly';
  
  static const Map<String, double> prices = {
    proMonthlyId: 9.99,
    proYearlyId: 79.99,
    ultraMonthlyId: 19.99,
    ultraYearlyId: 149.99,
  };
  
  static const Map<SubscriptionTier, List<String>> tierFeatures = {
    SubscriptionTier.free: [
      '3 generations per day',
      'Basic styles',
      'Standard quality (1080p)',
      'Watermark on exports',
      'Community wallpapers',
    ],
    SubscriptionTier.pro: [
      'Unlimited generations',
      'All styles + exclusive',
      '4K quality exports',
      'No watermark',
      'Advanced animations',
      'Priority generation speed',
      'Lockscreen support',
      'Early access features',
    ],
    SubscriptionTier.ultra: [
      'Everything in Pro',
      'AI Director unlimited',
      'Custom style training',
      'API access',
      'Creator revenue sharing',
      'Team collaboration',
      'White-label exports',
      'Priority support',
    ],
  };

  SubscriptionService({Dio? dio}) : _dio = dio ?? Dio(BaseOptions(baseUrl: AppConstants.baseUrl));

  /// Get current subscription status
  Future<Subscription?> getCurrentSubscription() async {
    try {
      final response = await _dio.get('${AppConstants.subscriptionEndpoint}/status');
      if (response.data['subscription'] != null) {
        return Subscription.fromJson(response.data['subscription']);
      }
      return null;
    } on DioException catch (_) {
      return null;
    }
  }

  /// Initiate purchase
  Future<bool> purchaseSubscription(String productId) async {
    // This would integrate with RevenueCat/PurchasesFlutter
    // For now, return placeholder
    return true;
  }

  /// Restore purchases
  Future<bool> restorePurchases() async {
    try {
      final response = await _dio.post('${AppConstants.subscriptionEndpoint}/restore');
      return response.data['restored'] == true;
    } on DioException catch (_) {
      return false;
    }
  }

  /// Check if user can generate
  bool canGenerate(AuraUser user) {
    if (user.tier == SubscriptionTier.free) {
      return user.generationsUsed < user.generationsLimit;
    }
    return true;
  }

  /// Get remaining generations for free users
  int getRemainingGenerations(AuraUser user) {
    if (user.tier != SubscriptionTier.free) return -1; // unlimited
    return (user.generationsLimit - user.generationsUsed).clamp(0, user.generationsLimit);
  }
}
