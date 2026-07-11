import 'package:freezed_annotation/freezed_annotation.dart';
import 'lesson.dart';

part 'module.freezed.dart';
part 'module.g.dart';

@Freezed(toJson: false)
class Module with _$Module {
  const factory Module({
    required int id,
    required int trackId,
    required String title,
    required String description,
    String? imageUrl,
    required int orderIndex,
    required List<Lesson> lessons,
  }) = _Module;

  factory Module.fromJson(Map<String, dynamic> json) =>
      _$ModuleFromJson(json);
}
