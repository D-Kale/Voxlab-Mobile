import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/auth_interceptor.dart';

class AnalyzerService {
  AnalyzerService(
    this._dio, {
    this.busyRetryDelay = const Duration(seconds: 4),
  });

  final Dio _dio;

  /// Wait before retrying when the speech analyzer answers 503 (queue full).
  final Duration busyRetryDelay;

  /// AI analysis is optional: a 401 here falls back to on-device analysis
  /// instead of signing the user out mid-exercise.
  static final _optionalAuth = {AuthInterceptor.skipLogoutOn401: true};

  /// Sends exercise text to the backend NLP analyzer.
  ///
  /// Response envelope: `{success, message, data}` with `data` shaped as
  /// `analyzer.AnalyzeResponse` (score 0-100, score_breakdown map, feedback
  /// list, metrics, and `ai_feedback` when the LLM coach was used). See
  /// docs/md/ANALYZER.md in the backend repo.
  Future<Map<String, dynamic>> analyzeText({
    required String text,
    required List<String> requirements,
    required int minWords,
    required int maxWords,
  }) async {
    final response = await _dio.post(
      '/exercises/analyze-text',
      data: {
        'text': text,
        'requirements': requirements,
        'min_words': minWords,
        'max_words': maxWords,
      },
      options: Options(
        extra: _optionalAuth,
        receiveTimeout: const Duration(seconds: 45),
      ),
    );
    return response.data as Map<String, dynamic>;
  }

  /// Uploads an oratory take to the speech AI (Whisper transcription plus
  /// pace, pauses and filler words, and an LLM tip about the content).
  ///
  /// Same envelope as [analyzeText]; `data` adds `transcript`,
  /// `words_per_minute`, `pause_count`, `filler_words`, `ai_feedback`...
  /// See docs/md/ANALYZER.md in the backend repo. Transcription runs on
  /// CPU, so the receive timeout is generous, and a busy analyzer (503) is
  /// retried twice.
  Future<Map<String, dynamic>> analyzeSpeech({
    required String path,
    required String fileName,
    int? minSeconds,
    int? targetSeconds,
    String? topic,
  }) async {
    // On the web the take is a blob: URL, not a file: read its bytes once.
    final webBytes = kIsWeb ? await _blobBytes(path) : null;
    for (var attempt = 0; ; attempt++) {
      try {
        final response = await _dio.post(
          '/exercises/analyze-speech',
          data: FormData.fromMap({
            'audio': webBytes != null
                ? MultipartFile.fromBytes(webBytes, filename: fileName)
                : await MultipartFile.fromFile(path, filename: fileName),
            'min_seconds': ?minSeconds,
            'target_seconds': ?targetSeconds,
            if (topic != null && topic.isNotEmpty) 'topic': topic,
          }),
          options: Options(
            extra: _optionalAuth,
            sendTimeout: const Duration(seconds: 60),
            receiveTimeout: const Duration(seconds: 120),
          ),
        );
        return response.data as Map<String, dynamic>;
      } on DioException catch (e) {
        if (e.response?.statusCode != 503 || attempt >= 2) rethrow;
        await Future<void>.delayed(busyRetryDelay);
      }
    }
  }
}

/// Bytes of a recording made in the browser (`record` returns a blob URL).
Future<List<int>> _blobBytes(String url) async {
  final response = await Dio().get<List<int>>(
    url,
    options: Options(responseType: ResponseType.bytes),
  );
  return response.data ?? const [];
}

final analyzerServiceProvider = Provider<AnalyzerService>((ref) {
  return AnalyzerService(ref.read(apiClientProvider));
});
