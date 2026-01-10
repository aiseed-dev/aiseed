import 'farming_method.dart';
import 'soil_type.dart';

/// 植物モデル
///
/// 畑（Field）に紐づく。農法・土壌は畑から継承するが、
/// 植物固有の設定で上書き可能。
class Plant {
  final String id;
  final String? fieldId;  // 畑ID（必須ではない、移行期間用）
  final String name;
  final String? variety;
  final String? notes;  // 植物についてのメモ

  // 畑から継承するが上書き可能
  final String? location;  // 畑の場所を上書き（deprecated、fieldIdに移行）
  final FarmingMethod? farmingMethodOverride;  // 畑と異なる農法
  final SoilType? soilTypeOverride;  // 畑と異なる土壌
  final String? soilNotes;

  final DateTime plantedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? latestPhotoUrl;
  final int observationCount;

  const Plant({
    required this.id,
    this.fieldId,
    required this.name,
    this.variety,
    this.notes,
    this.location,
    this.farmingMethodOverride,
    this.soilTypeOverride,
    this.soilNotes,
    required this.plantedAt,
    required this.createdAt,
    required this.updatedAt,
    this.latestPhotoUrl,
    this.observationCount = 0,
  });

  // 後方互換性のためのgetter（deprecated）
  FarmingMethod get farmingMethod => farmingMethodOverride ?? FarmingMethod.naturalCultivation;
  SoilType? get soilType => soilTypeOverride;

  /// 栽培日数を計算
  int get daysGrowing {
    return DateTime.now().difference(plantedAt).inDays;
  }

  /// JSONからPlantを生成
  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['id'] as String,
      fieldId: json['field_id'] as String?,
      name: json['name'] as String,
      variety: json['variety'] as String?,
      notes: json['notes'] as String?,
      location: json['location'] as String?,
      farmingMethodOverride: json['farming_method'] != null
          ? FarmingMethod.fromId(json['farming_method'] as String)
          : null,
      soilTypeOverride: json['soil_type'] != null
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
      'field_id': fieldId,
      'name': name,
      'variety': variety,
      'notes': notes,
      'location': location,
      'farming_method': farmingMethodOverride?.id,
      'soil_type': soilTypeOverride?.id,
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
    String? fieldId,
    String? name,
    String? variety,
    String? notes,
    String? location,
    FarmingMethod? farmingMethodOverride,
    SoilType? soilTypeOverride,
    String? soilNotes,
    DateTime? plantedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? latestPhotoUrl,
    int? observationCount,
  }) {
    return Plant(
      id: id ?? this.id,
      fieldId: fieldId ?? this.fieldId,
      name: name ?? this.name,
      variety: variety ?? this.variety,
      notes: notes ?? this.notes,
      location: location ?? this.location,
      farmingMethodOverride: farmingMethodOverride ?? this.farmingMethodOverride,
      soilTypeOverride: soilTypeOverride ?? this.soilTypeOverride,
      soilNotes: soilNotes ?? this.soilNotes,
      plantedAt: plantedAt ?? this.plantedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      latestPhotoUrl: latestPhotoUrl ?? this.latestPhotoUrl,
      observationCount: observationCount ?? this.observationCount,
    );
  }
}
