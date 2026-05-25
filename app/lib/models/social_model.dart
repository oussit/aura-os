
import 'package:freezed_annotation/freezed_annotation.dart';

part 'social_model.freezed.dart';
part 'social_model.g.dart';

@freezed
class SocialPost with _$SocialPost {
  const factory SocialPost({
    required String id,
    required String userId,
    required String wallpaperId,
    required String imageUrl,
    @Default('') String caption,
    @Default([]) List<String> tags,
    @Default(0) int likes,
    @Default(0) int comments,
    @Default(0) int shares,
    @Default(0) int remixes,
    @Default(false) bool isLiked,
    @Default(false) bool isSaved,
    @Default(false) bool isFeatured,
    String? originalPostId,
    DateTime? createdAt,
  }) = _SocialPost;

  factory SocialPost.fromJson(Map<String, dynamic> json) => _$SocialPostFromJson(json);
}

@freezed
class CreatorProfile with _$CreatorProfile {
  const factory CreatorProfile({
    required String userId,
    required String displayName,
    @Default('') String avatarUrl,
    @Default('') String bio,
    @Default(0) int creations,
    @Default(0) int totalLikes,
    @Default(0) int followers,
    @Default(0) int following,
    @Default(false) bool isVerified,
    @Default(false) bool isFollowing,
    @Default([]) List<String> badges,
    DateTime? joinedAt,
  }) = _CreatorProfile;

  factory CreatorProfile.fromJson(Map<String, dynamic> json) => _$CreatorProfileFromJson(json);
}
