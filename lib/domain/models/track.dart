import 'package:freezed_annotation/freezed_annotation.dart';
import 'module.dart';

part 'track.freezed.dart';
part 'track.g.dart';

@Freezed(toJson: false)
class Track with _$Track {
  const factory Track({
    required int id,
    required String title,
    required String description,
    String? iconUrl,
    required bool isActive,
    required List<Module> modules,
  }) = _Track;

  factory Track.fromJson(Map<String, dynamic> json) => _$TrackFromJson(json);
}
