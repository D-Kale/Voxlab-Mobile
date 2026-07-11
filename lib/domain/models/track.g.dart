// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrackImpl _$$TrackImplFromJson(Map<String, dynamic> json) => _$TrackImpl(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  description: json['description'] as String,
  iconUrl: json['iconUrl'] as String?,
  isActive: json['isActive'] as bool,
  modules: (json['modules'] as List<dynamic>)
      .map((e) => Module.fromJson(e as Map<String, dynamic>))
      .toList(),
);
