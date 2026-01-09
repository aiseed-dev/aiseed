import 'farming_method.dart';
import 'soil_type.dart';

/// 植物モデル
class Plant {
  final String id;
  final String name;
  final String? variety;
  final String? location;
  final FarmingMethod farmingMethod;
  final SoilType? soilType;
  final String? soilNotes;
  final DateTime plantedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? latestPhotoUrl;
  final int observationCount;

  const Plant({
    required this.id,
    required this.name,
    this.variety,
    this.location,
    required this.farmingMethod,
    this.soilType,
    this.soilNotes,
    required this.plantedAt,
    required this.createdAt,
    required this.updatedAt,
    this.latestPhotoUrl,
    this.observationCount = 0,
  });

  /// 栽培日数を計算
  int get daysGrowing {
    return DateTime.now().difference(plantedAt).inDays;
  }

  /// JSONからPlantを生成
  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['id'] as String,
      name: json['name'] as String,
      variety: json['variety'] as String?,
      location: json['location'] as String?,
      farmingMethod: FarmingMethod.fromId(json['farming_method'] as String),
      soilType: json['soil_type'] != null
          ? SoilType.fromId(json['soil_type'] as String)
          : null,
      soilNotes: json['soil_notes'] as String?,
      plantedAt: DateTime.parse(json['planted_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      latestPhotoUrl: json['latest_photo_url'] as String?,
      observationCount: json['observation_count'] as int? ?? 0,
    );
  }

  /// PlantをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'variety': variety,
      'location': location,
      'farming_method': farmingMethod.id,
      'soil_type': soilType?.id,
      'soil_notes': soilNotes,
      'planted_at': plantedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'latest_photo_url': latestPhotoUrl,
      'observation_count': observationCount,
    };
  }

  /// コピーを作成
  Plant copyWith({
    String? id,
    String? name,
    String? variety,
    String? location,
    FarmingMethod? farmingMethod,
    SoilType? soilType,
    String? soilNotes,
    DateTime? plantedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? latestPhotoUrl,
    int? observationCount,
  }) {
    return Plant(
      id: id ?? this.id,
      name: name ?? this.name,
      variety: variety ?? this.variety,
      location: location ?? this.location,
      farmingMethod: farmingMethod ?? this.farmingMethod,
      soilType: soilType ?? this.soilType,
      soilNotes: soilNotes ?? this.soilNotes,
      plantedAt: plantedAt ?? this.plantedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      latestPhotoUrl: latestPhotoUrl ?? this.latestPhotoUrl,
      observationCount: observationCount ?? this.observationCount,
    );
  }
}
