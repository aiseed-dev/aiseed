/// 農法カテゴリ（第1階層）
///
/// 化学肥料・農薬の使用有無で分類
enum FarmingCategory {
  /// 化学肥料・農薬を使う
  chemical('chemical', '化学肥料・農薬を使う', '🧪'),

  /// 化学肥料・農薬を使わない
  nonChemical('non_chemical', '化学肥料・農薬を使わない', '🌿');

  final String id;
  final String nameJa;
  final String emoji;

  const FarmingCategory(this.id, this.nameJa, this.emoji);

  static FarmingCategory fromId(String id) {
    return FarmingCategory.values.firstWhere(
      (c) => c.id == id,
      orElse: () => FarmingCategory.nonChemical,
    );
  }
}

/// 農法タイプ（第2階層）
///
/// 化学肥料・農薬を使わない場合の分類
enum FarmingType {
  /// 有機栽培 - 有機肥料で栄養を補う
  organic('organic', '有機栽培', '有機肥料で栄養を補う', '🍃'),

  /// 自然系栽培 - 土の力を引き出す
  natural('natural', '自然系栽培', '土の力を引き出す（循環・生態系型）', '🌱');

  final String id;
  final String nameJa;
  final String description;
  final String emoji;

  const FarmingType(this.id, this.nameJa, this.description, this.emoji);

  static FarmingType fromId(String id) {
    return FarmingType.values.firstWhere(
      (t) => t.id == id,
      orElse: () => FarmingType.natural,
    );
  }
}

/// 農法の種類（第3階層 - 詳細）
///
/// 具体的な農法を定義
enum FarmingMethod {
  // ========== 化学肥料・農薬を使う ==========

  /// 慣行農法
  conventional(
    'conventional',
    '慣行農法',
    'Conventional Farming',
    '一般的な農法',
    '🚜',
    FarmingCategory.chemical,
    null,
  ),

  // ========== 有機栽培 ==========

  /// 有機農法（JAS有機など）
  organic(
    'organic',
    '有機農法',
    'Organic Farming',
    'JAS有機認証など',
    '🍃',
    FarmingCategory.nonChemical,
    FarmingType.organic,
  ),

  /// ぼかし肥料栽培
  bokashi(
    'bokashi',
    'ぼかし肥料栽培',
    'Bokashi Composting',
    '発酵有機肥料を使用',
    '🫙',
    FarmingCategory.nonChemical,
    FarmingType.organic,
  ),

  // ========== 自然系栽培（土の力を引き出す） ==========

  /// 自然栽培（木村秋則など）
  naturalCultivation(
    'natural_cultivation',
    '自然栽培',
    'Natural Cultivation',
    '無肥料・無農薬、木村秋則など',
    '🌱',
    FarmingCategory.nonChemical,
    FarmingType.natural,
  ),

  /// 自然農（川口由一など）
  shizenNo(
    'shizen_no',
    '自然農',
    'Shizen-no',
    '不耕起・草生、川口由一など',
    '🌾',
    FarmingCategory.nonChemical,
    FarmingType.natural,
  ),

  /// 福岡正信自然農法
  fukuokaNaturalFarming(
    'fukuoka_natural_farming',
    '福岡自然農法',
    'Fukuoka Natural Farming',
    '不耕起・無除草・無肥料・無農薬',
    '🌾',
    FarmingCategory.nonChemical,
    FarmingType.natural,
  ),

  /// MOA自然農法（岡田茂吉）
  moaNaturalFarming(
    'moa_natural_farming',
    'MOA自然農法',
    'MOA Natural Farming',
    '落ち葉・草などの自然堆肥',
    '🍂',
    FarmingCategory.nonChemical,
    FarmingType.natural,
  ),

  /// 炭素循環農法
  carbonCyclingFarming(
    'carbon_cycling_farming',
    '炭素循環農法',
    'Carbon Cycling Farming',
    '高炭素資材で土壌微生物を活性化',
    '♻️',
    FarmingCategory.nonChemical,
    FarmingType.natural,
  ),

  /// 協生農法
  synecoculture(
    'synecoculture',
    '協生農法',
    'Synecoculture',
    '多種混植で生態系を構築',
    '🌳',
    FarmingCategory.nonChemical,
    FarmingType.natural,
  ),

  /// パーマカルチャー
  permaculture(
    'permaculture',
    'パーマカルチャー',
    'Permaculture',
    '持続可能な循環型デザイン',
    '🔄',
    FarmingCategory.nonChemical,
    FarmingType.natural,
  ),

  /// 不耕起栽培
  noTill(
    'no_till',
    '不耕起栽培',
    'No-Till Farming',
    '土を耕さずに栽培',
    '🌿',
    FarmingCategory.nonChemical,
    FarmingType.natural,
  ),

  /// 草マルチ栽培
  grassMulch(
    'grass_mulch',
    '草マルチ栽培',
    'Grass Mulching',
    '刈り草で土を覆う',
    '🥬',
    FarmingCategory.nonChemical,
    FarmingType.natural,
  ),

  /// コンパニオンプランティング
  companionPlanting(
    'companion_planting',
    'コンパニオンプランティング',
    'Companion Planting',
    '相性の良い植物を混植',
    '🤝',
    FarmingCategory.nonChemical,
    FarmingType.natural,
  ),

  /// バイオダイナミック農法
  biodynamic(
    'biodynamic',
    'バイオダイナミック農法',
    'Biodynamic Agriculture',
    'シュタイナー提唱、宇宙リズムと連動',
    '🌙',
    FarmingCategory.nonChemical,
    FarmingType.natural,
  ),

  /// 森林農法/アグロフォレストリー
  agroforestry(
    'agroforestry',
    '森林農法',
    'Agroforestry',
    '樹木と作物を組み合わせる',
    '🌲',
    FarmingCategory.nonChemical,
    FarmingType.natural,
  ),

  /// JADAM（韓国式自然農法）
  jadam(
    'jadam',
    'JADAM自然農法',
    'JADAM Natural Farming',
    '韓国発、低コスト自然農法',
    '🇰🇷',
    FarmingCategory.nonChemical,
    FarmingType.natural,
  ),

  /// KNF（韓国式自然農法）
  knf(
    'knf',
    'KNF（韓国自然農法）',
    'Korean Natural Farming',
    '土着微生物を活用',
    '🦠',
    FarmingCategory.nonChemical,
    FarmingType.natural,
  ),

  /// リジェネラティブ農業
  regenerative(
    'regenerative',
    'リジェネラティブ農業',
    'Regenerative Agriculture',
    '土壌再生・炭素固定を重視',
    '🔃',
    FarmingCategory.nonChemical,
    FarmingType.natural,
  ),

  /// その他の自然系
  otherNatural(
    'other_natural',
    'その他（自然系）',
    'Other Natural',
    '上記に該当しない自然系農法',
    '🌻',
    FarmingCategory.nonChemical,
    FarmingType.natural,
  );

  final String id;
  final String nameJa;
  final String nameEn;
  final String description;
  final String emoji;
  final FarmingCategory category;
  final FarmingType? type; // 化学系はnull

  const FarmingMethod(
    this.id,
    this.nameJa,
    this.nameEn,
    this.description,
    this.emoji,
    this.category,
    this.type,
  );

  /// 現在のロケールに応じた名前を取得
  String getName({String locale = 'ja'}) {
    return locale == 'ja' ? nameJa : nameEn;
  }

  /// IDから農法を取得
  static FarmingMethod fromId(String id) {
    return FarmingMethod.values.firstWhere(
      (method) => method.id == id,
      orElse: () => FarmingMethod.naturalCultivation,
    );
  }

  /// カテゴリで絞り込み
  static List<FarmingMethod> byCategory(FarmingCategory category) {
    return FarmingMethod.values
        .where((m) => m.category == category)
        .toList();
  }

  /// タイプで絞り込み
  static List<FarmingMethod> byType(FarmingType type) {
    return FarmingMethod.values
        .where((m) => m.type == type)
        .toList();
  }

  /// 自然系農法のみ取得
  static List<FarmingMethod> get naturalMethods {
    return byType(FarmingType.natural);
  }

  /// 有機系農法のみ取得
  static List<FarmingMethod> get organicMethods {
    return byType(FarmingType.organic);
  }
}
