/// 栽培方法カテゴリ（化学肥料・農薬の使用）
///
/// 第1段階：化学肥料・農薬を使うかどうか
enum CultivationCategory {
  /// 化学肥料・農薬を使う
  chemical('chemical', '化学肥料・農薬を使う', '🧪'),

  /// 化学肥料・農薬を使わない
  nonChemical('non_chemical', '化学肥料・農薬を使わない', '🌿');

  final String id;
  final String nameJa;
  final String emoji;

  const CultivationCategory(this.id, this.nameJa, this.emoji);

  static CultivationCategory fromId(String id) {
    return CultivationCategory.values.firstWhere(
      (c) => c.id == id,
      orElse: () => CultivationCategory.nonChemical,
    );
  }
}

/// 栽培方法タイプ（第2段階）
///
/// 化学肥料・農薬を使わない場合の分類
enum CultivationType {
  /// 有機栽培 - 有機肥料で栄養を補う
  organic('organic', '有機栽培', '有機肥料で栄養を補う', '🍃'),

  /// 自然系栽培 - 土の力を引き出す
  natural('natural', '自然系栽培', '土の力を引き出す（循環・生態系型）', '🌱');

  final String id;
  final String nameJa;
  final String description;
  final String emoji;

  const CultivationType(this.id, this.nameJa, this.description, this.emoji);

  static CultivationType fromId(String id) {
    return CultivationType.values.firstWhere(
      (t) => t.id == id,
      orElse: () => CultivationType.natural,
    );
  }
}

/// 栽培方法（第3段階 - 詳細）
///
/// 具体的な栽培方法を定義
enum CultivationMethod {
  // ========== 慣行栽培（化学肥料・農薬を使う） ==========

  /// 慣行栽培
  conventional(
    'conventional',
    '慣行栽培',
    'Conventional',
    '化学肥料・農薬を使用',
    '🧪',
    null,
  ),

  // ========== 有機栽培 ==========

  /// 有機栽培
  organic(
    'organic',
    '有機栽培',
    'Organic',
    '有機肥料で栄養を補う（化学肥料・農薬不使用）',
    '🍃',
    CultivationType.organic,
  ),

  // ========== 自然系栽培（土の力を引き出す） ==========

  /// 自然栽培（木村秋則など）
  naturalCultivation(
    'natural_cultivation',
    '自然栽培',
    'Natural Cultivation',
    '無肥料・無農薬、木村秋則など',
    '🌱',
    CultivationType.natural,
  ),

  /// 自然農（川口由一など）
  shizenNo(
    'shizen_no',
    '自然農',
    'Shizen-no',
    '不耕起・草生、川口由一など',
    '🌾',
    CultivationType.natural,
  ),

  /// 福岡自然農法
  fukuokaNaturalFarming(
    'fukuoka_natural_farming',
    '福岡自然農法',
    'Fukuoka Natural Farming',
    '不耕起・無除草・無肥料・無農薬',
    '🌾',
    CultivationType.natural,
  ),

  /// MOA自然農法（岡田茂吉）
  moaNaturalFarming(
    'moa_natural_farming',
    'MOA自然農法',
    'MOA Natural Farming',
    '落ち葉・草などの自然堆肥',
    '🍂',
    CultivationType.natural,
  ),

  /// 炭素循環農法
  carbonCyclingFarming(
    'carbon_cycling_farming',
    '炭素循環農法',
    'Carbon Cycling Farming',
    '高炭素資材で土壌微生物を活性化',
    '♻️',
    CultivationType.natural,
  ),

  /// 協生農法
  synecoculture(
    'synecoculture',
    '協生農法',
    'Synecoculture',
    '多種混植で生態系を構築',
    '🌳',
    CultivationType.natural,
  ),

  /// パーマカルチャー
  permaculture(
    'permaculture',
    'パーマカルチャー',
    'Permaculture',
    '持続可能な循環型デザイン',
    '🔄',
    CultivationType.natural,
  ),

  /// 不耕起栽培
  noTill(
    'no_till',
    '不耕起栽培',
    'No-Till Farming',
    '土を耕さずに栽培',
    '🌿',
    CultivationType.natural,
  ),

  /// 草マルチ栽培
  grassMulch(
    'grass_mulch',
    '草マルチ栽培',
    'Grass Mulching',
    '刈り草で土を覆う',
    '🥬',
    CultivationType.natural,
  ),

  /// コンパニオンプランティング
  companionPlanting(
    'companion_planting',
    'コンパニオンプランティング',
    'Companion Planting',
    '相性の良い植物を混植',
    '🤝',
    CultivationType.natural,
  ),

  /// バイオダイナミック農法
  biodynamic(
    'biodynamic',
    'バイオダイナミック農法',
    'Biodynamic Agriculture',
    'シュタイナー提唱、宇宙リズムと連動',
    '🌙',
    CultivationType.natural,
  ),

  /// 森林農法/アグロフォレストリー
  agroforestry(
    'agroforestry',
    '森林農法',
    'Agroforestry',
    '樹木と作物を組み合わせる',
    '🌲',
    CultivationType.natural,
  ),

  /// JADAM（韓国式自然農法）
  jadam(
    'jadam',
    'JADAM自然農法',
    'JADAM Natural Farming',
    '韓国発、低コスト自然農法',
    '🇰🇷',
    CultivationType.natural,
  ),

  /// KNF（韓国式自然農法）
  knf(
    'knf',
    'KNF（韓国自然農法）',
    'Korean Natural Farming',
    '土着微生物を活用',
    '🦠',
    CultivationType.natural,
  ),

  /// リジェネラティブ農業
  regenerative(
    'regenerative',
    'リジェネラティブ農業',
    'Regenerative Agriculture',
    '土壌再生・炭素固定を重視',
    '🔃',
    CultivationType.natural,
  ),

  /// その他の自然系
  otherNatural(
    'other_natural',
    'その他（自然系）',
    'Other Natural',
    '上記に該当しない自然系栽培',
    '🌻',
    CultivationType.natural,
  );

  final String id;
  final String nameJa;
  final String nameEn;
  final String description;
  final String emoji;
  final CultivationType? type;

  const CultivationMethod(
    this.id,
    this.nameJa,
    this.nameEn,
    this.description,
    this.emoji,
    this.type,
  );

  /// 化学肥料・農薬を使うかどうか
  bool get usesChemical => this == CultivationMethod.conventional;

  /// カテゴリを取得
  CultivationCategory get category =>
      usesChemical ? CultivationCategory.chemical : CultivationCategory.nonChemical;

  /// 現在のロケールに応じた名前を取得
  String getName({String locale = 'ja'}) {
    return locale == 'ja' ? nameJa : nameEn;
  }

  /// IDから栽培方法を取得
  static CultivationMethod fromId(String id) {
    return CultivationMethod.values.firstWhere(
      (method) => method.id == id,
      orElse: () => CultivationMethod.naturalCultivation,
    );
  }

  /// タイプで絞り込み
  static List<CultivationMethod> byType(CultivationType type) {
    return CultivationMethod.values
        .where((m) => m.type == type)
        .toList();
  }

  /// 自然系栽培のみ取得
  static List<CultivationMethod> get naturalMethods {
    return byType(CultivationType.natural);
  }

  /// 化学肥料・農薬を使わない栽培方法のみ取得
  static List<CultivationMethod> get nonChemicalMethods {
    return CultivationMethod.values
        .where((m) => !m.usesChemical)
        .toList();
  }
}

// ========== 後方互換性のためのエイリアス ==========
// 既存コードが FarmingMethod を使っている場合のため
typedef FarmingMethod = CultivationMethod;
typedef FarmingType = CultivationType;
typedef FarmingCategory = CultivationCategory;
