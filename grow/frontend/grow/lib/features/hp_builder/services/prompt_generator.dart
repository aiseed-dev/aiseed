import '../../../shared/models/plant.dart';
import '../../../shared/models/observation.dart';
import '../../../shared/models/field.dart';

/// HP作成用プロンプト生成サービス
class HpPromptGenerator {
  /// 栽培記録からプロンプトを生成
  static String generate({
    required List<Plant> plants,
    required List<Observation> observations,
    required List<Field> fields,
    required String userRequest,
    String? farmName,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('あなたはプロのWebデザイナーです。');
    buffer.writeln('以下の農家情報を元に、販売用ホームページのHTMLを作成してください。');
    buffer.writeln();

    // 農家情報セクション
    buffer.writeln('## 農家情報');
    buffer.writeln();

    if (farmName != null && farmName.isNotEmpty) {
      buffer.writeln('**農園名**: $farmName');
      buffer.writeln();
    }

    // 栽培方法
    final farmingMethods = _extractFarmingMethods(plants, fields);
    if (farmingMethods.isNotEmpty) {
      buffer.writeln('**栽培方法**: ${farmingMethods.join('、')}');
      buffer.writeln();
    }

    // 栽培場所
    if (fields.isNotEmpty) {
      buffer.writeln('**栽培場所**:');
      for (final field in fields) {
        buffer.writeln('- ${field.name}（${field.placeType.nameJa}）');
        if (field.farmingMethodNotes != null && field.farmingMethodNotes!.isNotEmpty) {
          buffer.writeln('  ${field.farmingMethodNotes}');
        }
      }
      buffer.writeln();
    }

    // 栽培中の野菜
    if (plants.isNotEmpty) {
      buffer.writeln('**栽培中の野菜**:');
      for (final plant in plants) {
        final variety = plant.variety != null ? '（${plant.variety}）' : '';
        final days = plant.daysGrowing;
        buffer.writeln('- ${plant.name}$variety - 栽培${days}日目');
        if (plant.notes != null && plant.notes!.isNotEmpty) {
          buffer.writeln('  ${plant.notes}');
        }
      }
      buffer.writeln();
    }

    // 最近の観察記録
    final recentObservations = _getRecentObservations(observations, limit: 5);
    if (recentObservations.isNotEmpty) {
      buffer.writeln('**最近の様子**:');
      for (final obs in recentObservations) {
        final plantName = obs.plantName ?? '不明';
        final date = _formatDate(obs.observedAt);
        buffer.writeln('- $date: $plantName');
        if (obs.note != null && obs.note!.isNotEmpty) {
          buffer.writeln('  ${obs.note}');
        }
        if (obs.hasPhotos) {
          buffer.writeln('  （写真${obs.photoUrls.length}枚）');
        }
      }
      buffer.writeln();
    }

    // ユーザーの要望
    buffer.writeln('## ユーザーの要望');
    buffer.writeln();
    buffer.writeln(userRequest);
    buffer.writeln();

    // 出力形式
    buffer.writeln('## 出力形式');
    buffer.writeln();
    buffer.writeln('- 単一のHTMLファイル（CSS埋め込み）');
    buffer.writeln('- レスポンシブ対応（スマートフォン・タブレット・PC）');
    buffer.writeln('- 日本語');
    buffer.writeln('- 画像は images/ ディレクトリを参照（例: images/tomato.jpg）');
    buffer.writeln('- 美しく洗練されたデザイン');
    buffer.writeln('- Google Fontsを使用可');
    buffer.writeln();

    // サンプル参考
    buffer.writeln('## 参考');
    buffer.writeln();
    buffer.writeln('以下のような構成を参考にしてください:');
    buffer.writeln('- ヒーローセクション（農園名、キャッチコピー）');
    buffer.writeln('- 私たちについて（栽培方法、こだわり）');
    buffer.writeln('- 今週の野菜（商品紹介）');
    buffer.writeln('- ギャラリー（畑の写真）');
    buffer.writeln('- お問い合わせ/購入方法');
    buffer.writeln('- フッター');

    return buffer.toString();
  }

  /// 修正指示用のプロンプトを生成
  static String generateModificationPrompt({
    required String currentHtml,
    required String modificationRequest,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('以下のHTMLを修正してください。');
    buffer.writeln();
    buffer.writeln('## 修正の要望');
    buffer.writeln();
    buffer.writeln(modificationRequest);
    buffer.writeln();
    buffer.writeln('## 現在のHTML');
    buffer.writeln();
    buffer.writeln('```html');
    buffer.writeln(currentHtml);
    buffer.writeln('```');
    buffer.writeln();
    buffer.writeln('## 出力');
    buffer.writeln();
    buffer.writeln('修正後の完全なHTMLを出力してください。');

    return buffer.toString();
  }

  /// 植物と畑から栽培方法を抽出
  static List<String> _extractFarmingMethods(List<Plant> plants, List<Field> fields) {
    final methods = <String>{};

    for (final field in fields) {
      if (field.farmingMethod != null) {
        methods.add(field.farmingMethod!.nameJa);
      }
    }

    for (final plant in plants) {
      if (plant.farmingMethodOverride != null) {
        methods.add(plant.farmingMethodOverride!.nameJa);
      }
    }

    return methods.toList();
  }

  /// 最近の観察記録を取得
  static List<Observation> _getRecentObservations(List<Observation> observations, {int limit = 5}) {
    final sorted = List<Observation>.from(observations)
      ..sort((a, b) => b.observedAt.compareTo(a.observedAt));
    return sorted.take(limit).toList();
  }

  /// 日付をフォーマット
  static String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}
