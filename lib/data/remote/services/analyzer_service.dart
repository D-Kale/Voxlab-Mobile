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
}

final analyzerServiceProvider = Provider<AnalyzerService>((ref) {
  return AnalyzerService(ref.read(apiClientProvider));
});
