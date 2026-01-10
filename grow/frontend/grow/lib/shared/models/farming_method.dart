/// 農法の種類
///
/// 日本発祥の自然農法を中心に定義
enum FarmingMethod {
  /// 福岡正信自然農法
  fukuokaNaturalFarming('fukuoka_natural_farming', '福岡自然農法', 'Fukuoka Natural Farming'),

  /// MOA自然農法（岡田茂吉）
  moaNaturalFarming('moa_natural_farming', 'MOA自然農法', 'MOA Natural Farming'),

  /// 自然栽培（木村秋則など）
  naturalCultivation('natural_cultivation', '自然栽培', 'Natural Cultivation'),

  /// 自然農（川口由一など）
  shizenNo('shizen_no', '自然農', 'Shizen-no'),

  /// 炭素循環農法
  carbonCyclingFarming('carbon_cycling_farming', '炭素循環農法', 'Carbon Cycling Farming'),

  /// 有機農法
  organicFarming('organic_farming', '有機農法', 'Organic Farming'),

  /// 慣行農法
  conventionalFarming('conventional_farming', '慣行農法', 'Conventional Farming'),

  /// その他
  other('other', 'その他', 'Other');

  final String id;
  final String nameJa;
  final String nameEn;

  const FarmingMethod(this.id, this.nameJa, this.nameEn);

  /// 現在のロケールに応じた名前を取得
  String getName({String locale = 'ja'}) {
    return locale == 'ja' ? nameJa : nameEn;
  }

  /// IDから農法を取得
  static FarmingMethod fromId(String id) {
    return FarmingMethod.values.firstWhere(
      (method) => method.id == id,
      orElse: () => FarmingMethod.other,
    );
  }

  /// 絵文字アイコン
  String get emoji {
    switch (this) {
      case FarmingMethod.fukuokaNaturalFarming:
        return '🌾';
      case FarmingMethod.moaNaturalFarming:
        return '🌸';
      case FarmingMethod.naturalCultivation:
        return '🌱';
      case FarmingMethod.shizenNo:
        return '🌿';
      case FarmingMethod.carbonCyclingFarming:
        return '♻️';
      case FarmingMethod.organicFarming:
        return '🍃';
      case FarmingMethod.conventionalFarming:
        return '🚜';
      case FarmingMethod.other:
        return '🌻';
    }
  }
}
