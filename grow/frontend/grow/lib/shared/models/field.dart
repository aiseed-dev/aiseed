import 'farming_method.dart';
import 'soil_type.dart';

/// 畑（栽培場所）モデル
///
/// 責務: ベランダ、畑、プランターなどの栽培場所を表す
class Field {
  final String id;
  final String name;  // 例: ベランダ、畑A、プランター

  // 位置情報
  final String? address;  // 住所（表示用）
  final double? latitude;
  final double? longitude;

  // 土壌情報（3要素）
  final SoilType? soilType;
  final String? soilPhysical;  // 物理性メモ
  final String? soilBiological;  // 生物性メモ
  final String? soilChemical;  // 化学性メモ
  final String? soilNotes;  // その他メモ

  // 農法
  final FarmingMethod farmingMethod;
  final String? farmingMethodNotes;

  // 気候データ（API取得結果をキャッシュ）
  final String? climateZone;  // ケッペン気候区分
  final String? lastFrostDate;  // 最終霜日
  final String? firstFrostDate;  // 初霜日

  // メタデータ
  final DateTime createdAt;
  final DateTime updatedAt;

  const Field({
    required this.id,
    required this.name,
    this.address,
    this.latitude,
    this.longitude,
    this.soilType,
    this.soilPhysical,
    this.soilBiological,
    this.soilChemical,
    this.soilNotes,
    required this.farmingMethod,
    this.farmingMethodNotes,
    this.climateZone,
    this.lastFrostDate,
    this.firstFrostDate,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSONからFieldを生成
  factory Field.fromJson(Map<String, dynamic> json) {
    return Field(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      soilType: json['soil_type'] != null
          ? SoilType.fromId(json['soil_type'] as String)
          : null,
      soilPhysical: json['soil_physical'] as String?,
      soilBiological: json['soil_biological'] as String?,
      soilChemical: json['soil_chemical'] as String?,
      soilNotes: json['soil_notes'] as String?,
      farmingMethod: FarmingMethod.fromId(json['farming_method'] as String),
      farmingMethodNotes: json['farming_method_notes'] as String?,
      climateZone: json['climate_zone'] as String?,
      lastFrostDate: json['last_frost_date'] as String?,
      firstFrostDate: json['first_frost_date'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// FieldをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'soil_type': soilType?.id,
      'soil_physical': soilPhysical,
      'soil_biological': soilBiological,
      'soil_chemical': soilChemical,
      'soil_notes': soilNotes,
      'farming_method': farmingMethod.id,
      'farming_method_notes': farmingMethodNotes,
      'climate_zone': climateZone,
      'last_frost_date': lastFrostDate,
      'first_frost_date': firstFrostDate,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// コピーを作成
  Field copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    SoilType? soilType,
    String? soilPhysical,
    String? soilBiological,
    String? soilChemical,
    String? soilNotes,
    FarmingMethod? farmingMethod,
    String? farmingMethodNotes,
    String? climateZone,
    String? lastFrostDate,
    String? firstFrostDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Field(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      soilType: soilType ?? this.soilType,
      soilPhysical: soilPhysical ?? this.soilPhysical,
      soilBiological: soilBiological ?? this.soilBiological,
      soilChemical: soilChemical ?? this.soilChemical,
      soilNotes: soilNotes ?? this.soilNotes,
      farmingMethod: farmingMethod ?? this.farmingMethod,
      farmingMethodNotes: farmingMethodNotes ?? this.farmingMethodNotes,
      climateZone: climateZone ?? this.climateZone,
      lastFrostDate: lastFrostDate ?? this.lastFrostDate,
      firstFrostDate: firstFrostDate ?? this.firstFrostDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 位置情報があるか
  bool get hasLocation => latitude != null && longitude != null;

  /// 土壌情報の入力状況
  String get soilCompleteness {
    int filled = 0;
    if (soilType != null) filled++;
    if (soilPhysical != null && soilPhysical!.isNotEmpty) filled++;
    if (soilBiological != null && soilBiological!.isNotEmpty) filled++;
    if (soilChemical != null && soilChemical!.isNotEmpty) filled++;
    return '$filled/4';
  }
}
