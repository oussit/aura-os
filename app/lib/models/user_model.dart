
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

enum SubscriptionTier { free, pro, ultra }

@freezed
class AuraUser with _$AuraUser {
  const factory AuraUser({
    required String id,
    required String email,
    @Default('') String displayName,
    @Default('') String avatarUrl,
    @Default(SubscriptionTier.free) SubscriptionTier tier,
    @Default(0) int generationsUsed,
    @Default(3) int generationsLimit,
    @Default(0) int totalCreations,
    @Default(0) int totalLikes,
    @Default(0) int followers,
    @Default(0) int following,
    @Default([]) List<String> savedWallpaperIds,
    @Default([]) List<String> purchasedPackIds,
    Subscription? subscription,
    DateTime? createdAt,
    DateTime? lastActiveAt,
  }) = _AuraUser;

  factory AuraUser.fromJson(Map<String, dynamic> json) => _$AuraUserFromJson(json);
}

@freezed
class Subscription with _$Subscription {
  const factory Subscription({
    required String id,
    required SubscriptionTier tier,
    required String status,
    required DateTime startDate,
    required DateTime endDate,
    @Default(false) bool autoRenew,
    String? stripeSubscriptionId,
  }) = _Subscription;

  factory Subscription.fromJson(Map<String, dynamic> json) => _$SubscriptionFromJson(json);
}
