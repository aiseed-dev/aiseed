/// 栽培場所タイプ
///
/// 栽培場所の種類を定義
enum PlaceType {
  balcony('balcony', 'ベランダ', '🏠'),
  field('field', '畑', '🌾'),
  planter('planter', 'プランター', '🪴'),
  indoors('indoors', '室内', '🏡'),
  rooftop('rooftop', '屋上', '🏢'),
  other('other', 'その他', '📍');

  final String id;
  final String nameJa;
  final String emoji;

  const PlaceType(this.id, this.nameJa, this.emoji);

  /// IDからPlaceTypeを取得
  static PlaceType fromId(String id) {
    return PlaceType.values.firstWhere(
      (type) => type.id == id,
      orElse: () => PlaceType.other,
    );
  }

  /// 畑タイプかどうか（農法が必要）
  bool get requiresFarmingMethod => this == PlaceType.field;
}
