/// 栽培場所タイプ
///
/// 食用作物向けにシンプル化した栽培場所分類
enum PlaceType {
  /// 畑・庭（地植え）- 土の量が十分
  ground('ground', '畑・庭（地植え）', '🌾'),

  /// プランター・鉢 - 土の量が限定的
  container('container', 'プランター・鉢', '🪴'),

  /// その他（水耕栽培、きのこ栽培など）- 自由記述
  other('other', 'その他', '📍');

  final String id;
  final String nameJa;
  final String emoji;

  const PlaceType(this.id, this.nameJa, this.emoji);

  /// IDからPlaceTypeを取得
  static PlaceType fromId(String id) {
    // 旧IDからの移行対応
    switch (id) {
      case 'field':
      case 'balcony':
      case 'rooftop':
      case 'indoors':
        return PlaceType.ground;
      case 'planter':
        return PlaceType.container;
      default:
        return PlaceType.values.firstWhere(
          (type) => type.id == id,
          orElse: () => PlaceType.other,
        );
    }
  }

  /// 農法選択が必要か（地植えの場合のみ）
  bool get requiresFarmingMethod => this == PlaceType.ground;

  /// その他の場合の説明例
  static String get otherExamples => '例: 水耕栽培、きのこ栽培、袋栽培など';
}
