
import 'dart:async';
import 'package:dio/dio.dart';
import '../core/constants/app_constants.dart';
import '../models/generation_model.dart';
import '../models/wallpaper_model.dart';

class AIService {
  final Dio _dio;
  final String _baseUrl;
  
  AIService({Dio? dio, String? baseUrl})
      : _dio = dio ?? Dio(BaseOptions(
            baseUrl: AppConstants.baseUrl,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(minutes: 5),
            headers: {'Content-Type': 'application/json'},
          )),
        _baseUrl = baseUrl ?? AppConstants.baseUrl;

  /// Enhance a user prompt using AI creative director
  Future<PromptEnhancement> enhancePrompt(String prompt, {String? style}) async {
    try {
      final response = await _dio.post(
        AppConstants.aiEnhanceEndpoint,
        data: {
          'prompt': prompt,
          'style': style,
          'enhance_level': 'creative',
        },
      );
      return PromptEnhancement.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Generate wallpaper from prompt
  Future<GenerationResult> generateWallpaper(GenerationRequest request) async {
    try {
      final response = await _dio.post(
        AppConstants.aiGenerateEndpoint,
        data: request.toJson(),
      );
      return GenerationResult.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Stream generation progress via SSE
  Stream<GenerationResult> streamGeneration(String generationId) async* {
    try {
      final response = await _dio.get(
        '$_baseUrl/v1/ai/generate/$generationId/stream',
        options: Options(responseType: ResponseType.stream),
      );
      
      String buffer = '';
      await for (final chunk in response.data.stream) {
        buffer += String.fromCharCodes(chunk);
        final lines = buffer.split('\n');
        buffer = lines.removeLast();
        
        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final json = line.substring(6);
            if (json.trim() == '[DONE]') return;
            try {
              yield GenerationResult.fromJson(
                Map<String, dynamic>.from(
                  Dio().transformer.transformResponse(
                    Response(requestOptions: RequestOptions(), data: json),
                  ) as Map,
                ),
              );
            } catch (_) {}
          }
        }
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get generation history
  Future<List<GenerationResult>> getHistory({int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get(
        '/v1/ai/history',
        queryParameters: {'page': page, 'limit': limit},
      );
      return (response.data['items'] as List)
          .map((e) => GenerationResult.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Apply animation effects to a wallpaper
  Future<Wallpaper> applyAnimations(
    String wallpaperId,
    List<AnimationEffect> effects,
  ) async {
    try {
      final response = await _dio.post(
        '/v1/wallpapers/$wallpaperId/animations',
        data: {'effects': effects.map((e) => e.toJson()).toList()},
      );
      return Wallpaper.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// AI Director: conversational wallpaper creation
  Future<Map<String, dynamic>> aiDirectorChat(
    String message,
    List<Map<String, String>> history,
  ) async {
    try {
      final response = await _dio.post(
        '/v1/ai/director',
        data: {
          'message': message,
          'history': history,
          'context': 'wallpaper_creation',
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Generation is taking longer than usual. Please try again.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 429) return 'Daily generation limit reached. Upgrade to Pro for unlimited.';
        if (statusCode == 402) return 'Premium feature. Upgrade to access this style.';
        return e.response?.data?['message'] ?? 'Something went wrong. Please try again.';
      default:
        return 'Network error. Check your connection and try again.';
    }
  }
}
