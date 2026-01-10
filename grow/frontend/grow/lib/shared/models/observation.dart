import 'weather.dart';

/// 観察記録モデル
class Observation {
  final String id;
  final String plantId;
  final String? note;
  final List<String> photoUrls;
  final Weather? weather;
  final double? temperature;
  final bool watered;
  final List<String> tags;
  final DateTime observedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // 関連データ（表示用）
  final String? plantName;

  const Observation({
    required this.id,
    required this.plantId,
    this.note,
    this.photoUrls = const [],
    this.weather,
    this.temperature,
    this.watered = false,
    this.tags = const [],
    required this.observedAt,
    required this.createdAt,
    required this.updatedAt,
    this.plantName,
  });

  /// JSONからObservationを生成
  factory Observation.fromJson(Map<String, dynamic> json) {
    return Observation(
      id: json['id'] as String,
      plantId: json['plant_id'] as String,
      note: json['note'] as String?,
      photoUrls: (json['photo_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      weather: json['weather'] != null
          ? Weather.fromId(json['weather'] as String)
          : null,
      temperature: (json['temperature'] as num?)?.toDouble(),
      watered: json['watered'] as bool? ?? false,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      observedAt: DateTime.parse(json['observed_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      plantName: json['plant_name'] as String?,
    );
  }

  /// ObservationをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plant_id': plantId,
      'note': note,
      'photo_urls': photoUrls,
      'weather': weather?.id,
      'temperature': temperature,
      'watered': watered,
      'tags': tags,
      'observed_at': observedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// コピーを作成
  Observation copyWith({
    String? id,
    String? plantId,
    String? note,
    List<String>? photoUrls,
    Weather? weather,
    double? temperature,
    bool? watered,
    List<String>? tags,
    DateTime? observedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? plantName,
  }) {
    return Observation(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      note: note ?? this.note,
      photoUrls: photoUrls ?? this.photoUrls,
      weather: weather ?? this.weather,
      temperature: temperature ?? this.temperature,
      watered: watered ?? this.watered,
      tags: tags ?? this.tags,
      observedAt: observedAt ?? this.observedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      plantName: plantName ?? this.plantName,
    );
  }

  /// 最初の写真URLを取得（サムネイル用）
  String? get thumbnailUrl => photoUrls.isNotEmpty ? photoUrls.first : null;

  /// 写真があるかどうか
  bool get hasPhotos => photoUrls.isNotEmpty;
}
