/// 天気の種類
enum Weather {
  sunny('sunny', '晴れ', 'Sunny', '☀️'),
  partlyCloudy('partly_cloudy', '曇り時々晴れ', 'Partly Cloudy', '⛅'),
  cloudy('cloudy', '曇り', 'Cloudy', '☁️'),
  rainy('rainy', '雨', 'Rainy', '🌧️'),
  snowy('snowy', '雪', 'Snowy', '❄️'),
  stormy('stormy', '雷雨', 'Stormy', '⛈️'),
  foggy('foggy', '霧', 'Foggy', '🌫️'),
  windy('windy', '強風', 'Windy', '💨');

  final String id;
  final String nameJa;
  final String nameEn;
  final String emoji;

  const Weather(this.id, this.nameJa, this.nameEn, this.emoji);

  /// 現在のロケールに応じた名前を取得
  String getName({String locale = 'ja'}) {
    return locale == 'ja' ? nameJa : nameEn;
  }

  /// IDから天気を取得
  static Weather fromId(String id) {
    return Weather.values.firstWhere(
      (weather) => weather.id == id,
      orElse: () => Weather.sunny,
    );
  }
}
