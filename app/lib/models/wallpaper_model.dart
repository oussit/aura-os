
import 'package:freezed_annotation/freezed_annotation.dart';

part 'wallpaper_model.freezed.dart';
part 'wallpaper_model.g.dart';

@freezed
class Wallpaper with _$Wallpaper {
  const factory Wallpaper({
    required String id,
    required String userId,
    required String prompt,
    String? enhancedPrompt,
    required String imageUrl,
    String? thumbnailUrl,
    String? videoUrl,
    @Default([]) List<String> tags,
    @Default('cyberpunk') String style,
    @Default('') String negativePrompt,
    @Default(1024) int width,
    @Default(1024) int height,
    @Default(false) bool isPublic,
    @Default(false) bool isPremium,
    @Default(false) bool isAnimated,
    @Default(0) int likes,
    @Default(0) int downloads,
    @Default(0) int views,
    @Default([]) List<AnimationEffect> effects,
    WallpaperSettings? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Wallpaper;

  factory Wallpaper.fromJson(Map<String, dynamic> json) => _$WallpaperFromJson(json);
}

@freezed
class AnimationEffect with _$AnimationEffect {
  const factory AnimationEffect({
    required String type, // parallax, particles, rain, glow, etc.
    @Default(1.0) double intensity,
    @Default(0.5) double speed,
    Map<String, dynamic>? params,
  }) = _AnimationEffect;

  factory AnimationEffect.fromJson(Map<String, dynamic> json) => _$AnimationEffectFromJson(json);
}

@freezed
class WallpaperSettings with _$WallpaperSettings {
  const factory WallpaperSettings({
    @Default(true) bool interactive,
    @Default(true) bool reactToTilt,
    @Default(true) bool reactToTouch,
    @Default(false) bool reactToMusic,
    @Default(true) bool reactToCharging,
    @Default(true) bool reactToBattery,
    @Default(true) bool reactToTime,
    @Default(30) int targetFps,
    @Default(true) bool batteryOptimized,
    @Default(false) bool lockscreenEnabled,
    @Default(false) bool homescreenEnabled,
  }) = _WallpaperSettings;

  factory WallpaperSettings.fromJson(Map<String, dynamic> json) => _$WallpaperSettingsFromJson(json);
}
