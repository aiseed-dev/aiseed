/// 土壌分類（WRB 32分類 + 日本農耕地土壌分類対応）
///
/// 日本でよく見られる土壌を優先表示
enum SoilType {
  // 日本でよく見られる土壌
  /// 黒ボク土（火山灰土）
  andosols('andosols', '黒ボク土', 'Andosols', true),

  /// 褐色森林土
  cambisols('cambisols', '褐色森林土', 'Cambisols', true),

  /// グライ土（低地水田土壌）
  gleysols('gleysols', 'グライ土', 'Gleysols', true),

  /// 沖積土
  fluvisols('fluvisols', '沖積土', 'Fluvisols', true),

  /// 灰色低地土
  stagnosols('stagnosols', '灰色低地土', 'Stagnosols', true),

  /// 赤黄色土
  acrisols('acrisols', '赤黄色土', 'Acrisols', true),

  /// ポドゾル
  podzols('podzols', 'ポドゾル', 'Podzols', true),

  /// 泥炭土
  histosols('histosols', '泥炭土', 'Histosols', true),

  /// 未熟土
  regosols('regosols', '未熟土', 'Regosols', true),

  /// 岩屑土
  leptosols('leptosols', '岩屑土', 'Leptosols', true),

  // その他のWRB分類
  /// アリソル
  alisols('alisols', 'アリソル', 'Alisols', false),

  /// 人工土壌
  anthrosols('anthrosols', '人工土壌', 'Anthrosols', false),

  /// 乾燥土
  arenosols('arenosols', '砂質土', 'Arenosols', false),

  /// 石灰質土
  calcisols('calcisols', '石灰質土', 'Calcisols', false),

  /// チェルノーゼム
  chernozems('chernozems', 'チェルノーゼム', 'Chernozems', false),

  /// 凍土
  cryosols('cryosols', '凍土', 'Cryosols', false),

  /// 砂漠土
  durisols('durisols', '硬盤土', 'Durisols', false),

  /// フェラルソル
  ferralsols('ferralsols', 'フェラルソル', 'Ferralsols', false),

  /// ジプシソル
  gypsisols('gypsisols', '石膏質土', 'Gypsisols', false),

  /// カスタノーゼム
  kastanozems('kastanozems', '栗色土', 'Kastanozems', false),

  /// リキソル
  lixisols('lixisols', 'リキソル', 'Lixisols', false),

  /// ルビソル
  luvisols('luvisols', 'ルビソル', 'Luvisols', false),

  /// ニティソル
  nitisols('nitisols', 'ニティソル', 'Nitisols', false),

  /// ファエオゼム
  phaeozems('phaeozems', 'ファエオゼム', 'Phaeozems', false),

  /// プラノソル
  planosols('planosols', 'プラノソル', 'Planosols', false),

  /// プリンソソル
  plinthosols('plinthosols', 'プリンソソル', 'Plinthosols', false),

  /// レチソル
  retisols('retisols', 'レチソル', 'Retisols', false),

  /// ソロネッツ
  solonetz('solonetz', 'ソロネッツ', 'Solonetz', false),

  /// ソロンチャク
  solonchaks('solonchaks', 'ソロンチャク', 'Solonchaks', false),

  /// テクノソル
  technosols('technosols', 'テクノソル', 'Technosols', false),

  /// アンブリソル
  umbrisols('umbrisols', 'アンブリソル', 'Umbrisols', false),

  /// バーティソル
  vertisols('vertisols', '膨張性粘土土', 'Vertisols', false),

  /// 不明
  unknown('unknown', '不明', 'Unknown', false);

  final String id;
  final String nameJa;
  final String nameEn;
  final bool commonInJapan;

  const SoilType(this.id, this.nameJa, this.nameEn, this.commonInJapan);

  /// 現在のロケールに応じた名前を取得
  String getName({String locale = 'ja'}) {
    return locale == 'ja' ? nameJa : nameEn;
  }

  /// IDから土壌タイプを取得
  static SoilType fromId(String id) {
    return SoilType.values.firstWhere(
      (type) => type.id == id,
      orElse: () => SoilType.unknown,
    );
  }

  /// 日本でよく見られる土壌のみを取得
  static List<SoilType> getJapanCommon() {
    return SoilType.values.where((type) => type.commonInJapan).toList();
  }

  /// 絵文字アイコン（代表的な色）
  String get emoji {
    switch (this) {
      case SoilType.andosols:
        return '⬛'; // 黒
      case SoilType.cambisols:
        return '🟫'; // 褐色
      case SoilType.gleysols:
        return '🔵'; // 青灰色（還元状態）
      case SoilType.fluvisols:
        return '🟡'; // 黄褐色
      case SoilType.stagnosols:
        return '⬜'; // 灰色
      case SoilType.acrisols:
        return '🟠'; // 赤黄色
      case SoilType.histosols:
        return '🟤'; // 泥炭色
      default:
        return '🌍';
    }
  }
}
