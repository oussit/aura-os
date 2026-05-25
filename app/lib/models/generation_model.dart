
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generation_model.freezed.dart';
part 'generation_model.g.dart';

@freezed
class GenerationRequest with _$GenerationRequest {
  const factory GenerationRequest({
    required String prompt,
    @Default('') String negativePrompt,
    @Default('cyberpunk') String style,
    @Default(1024) int width,
    @Default(1024) int height,
    @Default(7.5) double guidanceScale,
    @Default(30) int steps,
    @Default(42) int seed,
    @Default(false) bool enhancePrompt,
    @Default([]) List<String> animationEffects,
  }) = _GenerationRequest;

  factory GenerationRequest.fromJson(Map<String, dynamic> json) => _$GenerationRequestFromJson(json);
}

@freezed
class GenerationResult with _$GenerationResult {
  const factory GenerationResult({
    required String id,
    required String status, // pending, processing, completed, failed
    @Default(0.0) double progress,
    String? imageUrl,
    String? thumbnailUrl,
    String? videoUrl,
    String? errorMessage,
    @Default([]) List<String> generatedVariants,
    Map<String, dynamic>? metadata,
    DateTime? startedAt,
    DateTime? completedAt,
  }) = _GenerationResult;

  factory GenerationResult.fromJson(Map<String, dynamic> json) => _$GenerationResultFromJson(json);
}

@freezed
class PromptEnhancement with _$PromptEnhancement {
  const factory PromptEnhancement({
    required String original,
    required String enhanced,
    @Default([]) List<String> suggestedStyles,
    @Default([]) List<String> suggestedEffects,
    @Default([]) List<String> suggestedTags,
  }) = _PromptEnhancement;

  factory PromptEnhancement.fromJson(Map<String, dynamic> json) => _$PromptEnhancementFromJson(json);
}
