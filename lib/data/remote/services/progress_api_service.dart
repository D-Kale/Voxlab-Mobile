import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../domain/models/progress.dart';

abstract class ProgressApiService {
  Future<UserProgress> getProgress();

  Future<ProgressSubmitData> submitProgress(ProgressSubmitRequest request);

  Future<ProgressSubmitData> syncProgress(List<ProgressSubmitRequest> entries);
}

class ProgressApiServiceImpl implements ProgressApiService {
  ProgressApiServiceImpl(this._dio);

  final Dio _dio;

  @override
  Future<UserProgress> getProgress() async {
    final response = await _dio.get('/progress');
    final data = response.data['data'] as Map<String, dynamic>;
    return UserProgress.fromJson(data);
  }

  @override
  Future<ProgressSubmitData> submitProgress(ProgressSubmitRequest request) async {
    final response = await _dio.post('/progress', data: request.toJson());
    final responseData = response.data as Map<String, dynamic>;
    return ProgressSubmitResponse.fromJson(responseData).data;
  }

  @override
  Future<ProgressSubmitData> syncProgress(List<ProgressSubmitRequest> entries) async {
    final response = await _dio.post(
      '/progress/sync',
      data: {'entries': entries.map((e) => e.toJson()).toList()},
    );
    final responseData = response.data as Map<String, dynamic>;
    return ProgressSubmitResponse.fromJson(responseData).data;
  }
}

final progressApiServiceProvider = Provider<ProgressApiService>((ref) {
  return ProgressApiServiceImpl(ref.read(apiClientProvider));
});