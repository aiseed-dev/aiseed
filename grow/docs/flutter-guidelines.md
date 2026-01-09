# Grow Flutter 開発憲法 v1.0

あなたは熟練したFlutterアーキテクト兼実装エンジニアです。
以下の「開発憲法」を厳格に守り、Grow（自然派向け栽培記録アプリ）のコードを実装してください。

## 0. Philosophy: 必要なものを必要な時に

* **YAGNI原則**: 今必要でない機能は作らない
* **自己完結**: 各Widgetは単体で理解・テスト可能であること
* **透明性**: ブラックボックスを排除し、コードの流れが追えること
* **自然農法の思想**: 「何をしたか」ではなく「何が起きているか」を記録するUI設計

---

## 1. Architecture: Vertical Slice (Feature-First)

```
lib/
├── features/
│   ├── observation/           # 観察記録
│   │   ├── observation_screen.dart
│   │   ├── observation_service.dart
│   │   ├── observation_card_widget.dart
│   │   └── observation_model.dart
│   ├── plant/                 # 植物管理
│   │   ├── plant_screen.dart
│   │   ├── plant_service.dart
│   │   └── plant_model.dart
│   ├── weather/               # 気象データ
│   │   ├── weather_service.dart
│   │   └── weather_widget.dart
│   ├── soil/                  # 土壌観察
│   │   ├── soil_observation_widget.dart
│   │   └── soil_types.dart    # WRB 32分類
│   ├── farming_method/        # 栽培方法
│   │   └── farming_method_selector.dart
│   └── photo/                 # 写真管理
│       ├── photo_capture_widget.dart
│       ├── exif_service.dart
│       └── photo_storage_service.dart
├── shared/                    # 複数機能で共有するもののみ
│   ├── widgets/
│   │   └── loading_indicator.dart
│   ├── services/
│   │   └── api_client.dart
│   └── l10n/                  # 国際化
│       ├── app_ja.arb
│       └── app_en.arb
└── main.dart
```

* **機能別ディレクトリ構成**を徹底する
* レイヤー（MVVM等）でディレクトリを分けない
* `shared/` は「2つ以上の機能で使う」ことが確定してから移動

---

## 2. State Management: No External Libraries

* **Riverpod, Bloc, Provider 等の使用禁止**
* Flutter標準機能のみで完結：
  - `setState` - Widget内の単純な状態
  - `ValueNotifier` + `ValueListenableBuilder` - 複数箇所での状態共有
  - `FutureBuilder` / `StreamBuilder` - 非同期データ表示
  - `InheritedWidget` - 深い階層への値の受け渡し（稀に使用）

---

## 3. Widget Design: 自己完結型Widget

### 3.1 基本構造

```dart
/// 観察記録カードを表示するWidget
///
/// 依存: [ObservationService] を外部から注入
/// 責務: 単一の観察記録を表示し、タップで詳細へ遷移
class ObservationCard extends StatefulWidget {
  final ObservationService service;
  final Observation observation;
  final void Function(Observation)? onTap;

  const ObservationCard({
    super.key,
    required this.service,
    required this.observation,
    this.onTap,
  });
}
```

### 3.2 設計原則

* **依存注入**: Serviceは外部から渡す（テスト容易性）
* **コールバック**: 結果は `onXxx` で親に通知
* **内部状態**: Widget内で完結する状態のみ `setState` で管理
* **単一責務**: 1 Widget = 1 機能

---

## 4. Data Strategy: Service + FutureBuilder

### 4.1 Service設計

```dart
/// 観察記録のデータ取得・保存を担当
class ObservationService {
  final ApiClient _api;
  final LocalStorage _local;

  // キャッシュ
  List<Observation>? _cachedObservations;
  DateTime? _lastFetch;

  ObservationService(this._api, this._local);

  /// 観察記録一覧を取得（オフライン対応）
  Future<List<Observation>> getObservations({
    required String plantId,
    bool forceRefresh = false,
  }) async {
    // オフライン時はローカルから
    if (!await _hasNetwork()) {
      return _local.getObservations(plantId);
    }

    if (!forceRefresh && _cachedObservations != null && _isCacheValid()) {
      return _cachedObservations!;
    }

    _cachedObservations = await _api.fetchObservations(plantId);
    _lastFetch = DateTime.now();

    // ローカルにも保存（オフライン用）
    await _local.saveObservations(plantId, _cachedObservations!);

    return _cachedObservations!;
  }

  bool _isCacheValid() =>
    _lastFetch != null &&
    DateTime.now().difference(_lastFetch!) < const Duration(minutes: 5);
}
```

### 4.2 画面での使用

```dart
class ObservationListScreen extends StatelessWidget {
  final ObservationService service;
  final String plantId;

  const ObservationListScreen({
    super.key,
    required this.service,
    required this.plantId,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Observation>>(
      future: service.getObservations(plantId: plantId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return ErrorDisplay(
            message: snapshot.error.toString(),
            onRetry: () => /* 再取得トリガー */,
          );
        }
        return ObservationListView(observations: snapshot.data!);
      },
    );
  }
}
```

---

## 5. Coding Rules

### 5.1 必須ルール

* **import文**: コード提示時は必ず含める
* **コメント**: How（方法）ではなく Why（設計意図）を書く
* **命名**: `_buildXxx()` はプライベートビルダー、`XxxWidget` は公開Widget
* **const**: 可能な限り `const` コンストラクタを使用
* **国際化**: ユーザー向け文字列は全て `AppLocalizations` 経由

### 5.2 禁止事項

* `build()` 内での直接API呼び出し
* グローバル変数・シングルトンの乱用
* 1ファイル500行超え（分割を検討）
* ハードコードされた日本語/英語文字列（l10n必須）

### 5.3 エラーハンドリング

```dart
// ❌ Bad: 握りつぶし
try { await api.fetch(); } catch (_) {}

// ✅ Good: 明示的なハンドリング
try {
  await api.fetch();
} on NetworkException catch (e) {
  // オフラインモードへ切り替え
  return _local.getCached();
} on AuthException {
  // ログイン画面へ
}
```

---

## 6. Backend Integration (Cloudflare Workers)

### 6.1 ApiClient設計

```dart
class ApiClient {
  final String baseUrl;
  final http.Client _client;
  final String? _authToken;

  ApiClient({
    required this.baseUrl,
    String? authToken,
  }) : _client = http.Client(),
       _authToken = authToken;

  Future<T> get<T>(String path, T Function(dynamic) fromJson) async {
    final response = await _client.get(
      Uri.parse('$baseUrl$path'),
      headers: _authToken != null
        ? {'Authorization': 'Bearer $_authToken'}
        : null,
    );
    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }
    return fromJson(jsonDecode(response.body));
  }

  Future<T> post<T>(String path, dynamic body, T Function(dynamic) fromJson) async {
    final response = await _client.post(
      Uri.parse('$baseUrl$path'),
      headers: {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      },
      body: jsonEncode(body),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ApiException(response.statusCode, response.body);
    }
    return fromJson(jsonDecode(response.body));
  }
}
```

### 6.2 環境設定

```dart
// lib/config.dart
class Config {
  // Cloudflare Workers API
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://grow-api.your-domain.workers.dev',
  );

  // Cloudflare Pages (公開写真)
  static const String pagesBaseUrl = String.fromEnvironment(
    'PAGES_BASE_URL',
    defaultValue: 'https://grow.pages.dev',
  );

  // Cloudflare R2 (非公開写真)
  static const String r2BaseUrl = String.fromEnvironment(
    'R2_BASE_URL',
    defaultValue: 'https://grow-private.your-domain.workers.dev',
  );
}
```

---

## 7. Grow固有の設計

### 7.1 写真管理（EXIF処理）

```dart
/// 写真のEXIF処理を担当
class ExifService {
  /// GPS座標の処理オプション
  Future<File> processPhoto(
    File photo, {
    required GpsHandling gpsHandling,
  }) async {
    switch (gpsHandling) {
      case GpsHandling.delete:
        return _removeGps(photo);
      case GpsHandling.keep:
        return photo;
      case GpsHandling.blur:
        return _blurGps(photo, radiusMeters: 1000);
      case GpsHandling.publish:
        return photo;
    }
  }
}

enum GpsHandling { delete, keep, blur, publish }
```

### 7.2 栽培方法・土壌分類

```dart
// 栽培方法（国際化対応済み）
enum FarmingMethod {
  undecided,
  naturalFukuoka,    // 福岡正信 自然農法
  naturalOkada,      // 岡田茂吉 自然農法
  naturalCultivation, // 自然栽培
  naturalFarming,    // 自然農
  carbonCycling,     // 炭素循環農法
  organic,           // 有機農業
  conventional,      // 慣行農業
  other,
}

// WRB 32 土壌分類
enum SoilType {
  unknown,
  histosols,    // 泥炭土
  andosols,     // 黒ボク土（日本の代表的土壌）
  fluvisols,    // 沖積土（日本の農地で最多）
  cambisols,    // 褐色森林土
  gleysols,     // グライ土
  // ... 他27種
}
```

### 7.3 オフライン対応

```dart
/// ローカルストレージ（SQLite）
class LocalStorage {
  late final Database _db;

  Future<void> init() async {
    _db = await openDatabase(
      'grow.db',
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE observations (
            id TEXT PRIMARY KEY,
            plant_id TEXT,
            data TEXT,
            synced INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }

  /// 未同期の観察記録を取得
  Future<List<Observation>> getUnsyncedObservations() async {
    final rows = await _db.query('observations', where: 'synced = 0');
    return rows.map((r) => Observation.fromJson(jsonDecode(r['data'] as String))).toList();
  }
}
```

---

## 8. Testing Strategy

* **Widget単体**: 各自己完結型WidgetをMock Serviceでテスト
* **Service単体**: API応答のモックでロジックテスト
* **画面統合**: 主要フロー（撮影→記録→保存）のみ
* **オフライン**: ネットワーク切断時の動作確認

---

## 9. Quick Reference

| やりたいこと | 使う手法 |
|-------------|---------|
| 単純なUIの状態管理 | `setState` |
| 複数Widget間での状態共有 | `ValueNotifier` + `ValueListenableBuilder` |
| 非同期データの表示 | `FutureBuilder` |
| リアルタイム更新 | `StreamBuilder` |
| 深い階層への値渡し | コンストラクタ注入（または稀に`InheritedWidget`）|
| API通信 + キャッシュ | Feature別Service |
| オフライン対応 | SQLite + 同期フラグ |
| 国際化 | `flutter_localizations` + `.arb` ファイル |
| 写真のEXIF処理 | `ExifService` |
| 公開/非公開写真 | Pages (公開) / R2 (非公開) |

---

## 10. 国際化（i18n）

### 10.1 ARBファイル構成

```
lib/shared/l10n/
├── app_ja.arb    # 日本語（主言語）
└── app_en.arb    # 英語
```

### 10.2 使用例

```dart
// 文字列の定義（app_ja.arb）
{
  "observationTitle": "観察記録",
  "farmingMethodFukuoka": "自然農法（福岡正信）",
  "soilTypeAndosols": "黒ボク土"
}

// 文字列の定義（app_en.arb）
{
  "observationTitle": "Observation Journal",
  "farmingMethodFukuoka": "Fukuoka Natural Farming",
  "soilTypeAndosols": "Andosols"
}

// 使用
Text(AppLocalizations.of(context)!.observationTitle)
```
