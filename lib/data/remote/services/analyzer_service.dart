import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

class AnalyzerService {
  AnalyzerService(this._dio);

  final Dio _dio;

  /// Sends exercise text to the backend NLP analyzer.
  ///
  /// Response envelope: `{success, message, data}` with `data` shaped as
  /// `analyzer.AnalyzeResponse` (score 0-100, score_breakdown map, feedback
  /// list, metrics). See docs/swagger.json in the backend repo.
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
    );
    return response.data as Map<String, dynamic>;
  }

  /// Uploads an oratory take to the speech AI (Whisper transcription plus
  /// pace, pauses and filler words).
  ///
  /// Same envelope as [analyzeText]; `data` adds `transcript`,
  /// `words_per_minute`, `pause_count`, `filler_words`... See
  /// docs/md/ANALYZER.md in the backend repo. Transcription runs on CPU,
  /// so the receive timeout is generous.
  Future<Map<String, dynamic>> analyzeSpeech({
    required String path,
    required String fileName,
    int? minSeconds,
    int? targetSeconds,
  }) async {
    final response = await _dio.post(
      '/exercises/analyze-speech',
      data: FormData.fromMap({
        'audio': await MultipartFile.fromFile(path, filename: fileName),
        'min_seconds': ?minSeconds,
        'target_seconds': ?targetSeconds,
      }),
      options: Options(
        sendTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 120),
      ),
    );
    return response.data as Map<String, dynamic>;
  }
}

final analyzerServiceProvider = Provider<AnalyzerService>((ref) {
  return AnalyzerService(ref.read(apiClientProvider));
});
