import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../domain/models/progress.dart';
import '../../../domain/models/lesson_status.dart';

class ProgressService {
  ProgressService(this._dio);

  final Dio _dio;

  Future<List<Progress>> getProgress() async {
    final response = await _dio.get('/progress');
    final data = response.data['data'] as List;
    return data.map((e) => _mapProgress(e as Map<String, dynamic>)).toList();
  }

  Future<Progress> completeLesson(int lessonId, int score) async {
    final response = await _dio.post('/progress', data: {
      'lesson_id': lessonId,
      'score': score,
    });
    final data = response.data['data'] as Map<String, dynamic>;
    return _mapProgress(data);
  }

  Future<Progress> updateProgress(int lessonId, int score) async {
    final response = await _dio.patch('/progress/$lessonId', data: {
      'score': score,
    });
    final data = response.data['data'] as Map<String, dynamic>;
    return _mapProgress(data);
  }

  Future<Map<String, dynamic>> syncProgress(
    List<Map<String, dynamic>> items,
  ) async {
    final response = await _dio.post('/progress/sync', data: {
      'progress_items': items,
    });
    return response.data['data'] as Map<String, dynamic>;
  }

  Progress _mapProgress(Map<String, dynamic> json) {
    final lessonId = json['lesson_id'] as int;
    final xpEarned = json['xp_earned'] as int?;
    return Progress(
      exerciseId: lessonId.toString(),
      lessonId: lessonId,
      status: LessonStatus.values.firstWhere(
        (s) => s.name == (json['status'] as String? ?? 'available'),
        orElse: () => LessonStatus.available,
      ),
      score: xpEarned,
      xpEarned: xpEarned,
      completedAt:
          json['completed_at'] != null
              ? DateTime.tryParse(json['completed_at'] as String)
              : null,
      startedAt:
          json['started_at'] != null
              ? DateTime.tryParse(json['started_at'] as String)
              : null,
    );
  }
}

final progressServiceProvider = Provider<ProgressService>((ref) {
  return ProgressService(ref.read(apiClientProvider));
});
