# Grow - ERA5気候データ機能 仕様書

## 概要

ERA5（ECMWF Reanalysis v5）を使用して、ユーザーの栽培場所の気候データを自動取得する機能。

## ERA5とは

- **提供元**: ECMWF（欧州中期予報センター）/ Copernicus Climate Change Service
- **期間**: 1940年〜現在（数日遅れで更新）
- **解像度**: 約31km（0.25° x 0.25°）、1時間ごと
- **データ**: 気温、降水量、湿度、風速、日射量など

## 取得したい気候データ

### 栽培に必要な情報

| データ項目 | ERA5変数 | 用途 |
|-----------|---------|------|
| 月別平均気温 | 2m temperature | 栽培適期の判断 |
| 月別最高気温 | 2m temperature (max) | 猛暑対策 |
| 月別最低気温 | 2m temperature (min) | 霜・凍結リスク |
| 月別降水量 | Total precipitation | 水やり計画 |
| 霜日数 | 2m temperature < 0°C | 栽培可能期間 |
| 日照時間 | Surface solar radiation | 作物選択 |

### 算出したい指標

| 指標 | 計算方法 | 用途 |
|------|---------|------|
| 最終霜日 | 春に最後に0°C以下になる日 | 定植時期 |
| 初霜日 | 秋に最初に0°C以下になる日 | 収穫時期 |
| 栽培可能日数 | 初霜日 - 最終霜日 | 品種選択 |
| 積算温度（GDD） | Σ(日平均気温 - 基準温度) | 生育予測 |

---

## データ取得方法

### Option 1: Copernicus CDS API（推奨）

```
CDS API → AIseed Backend → Grow App
```

**メリット**:
- 公式API、データの信頼性が高い
- 無料で利用可能
- 細かいデータ選択が可能

**デメリット**:
- APIキー登録が必要
- リクエスト制限あり
- データ取得に時間がかかる場合あり

### Option 2: Google Earth Engine

```
Earth Engine → AIseed Backend → Grow App
```

**メリット**:
- クラウド上で処理可能
- 高速

**デメリット**:
- 商用利用には制限
- Google Cloud課金

### Option 3: AWS Open Data

```
AWS S3 (ERA5) → AIseed Backend → Grow App
```

**メリット**:
- S3から直接取得
- AWSインフラと統合しやすい

**デメリット**:
- データ転送コスト
- 自前でパース処理が必要

---

## アーキテクチャ案

### シンプル構成

```
┌─────────────┐     ┌─────────────────┐     ┌──────────────┐
│  Grow App   │────▶│  AIseed Backend │────▶│  CDS API     │
│  (Flutter)  │◀────│  (Climate API)  │◀────│  (ERA5)      │
└─────────────┘     └─────────────────┘     └──────────────┘
                            │
                            ▼
                    ┌─────────────────┐
                    │  Cache (Redis)  │
                    │  or DB          │
                    └─────────────────┘
```

### API設計

#### エンドポイント

```
GET /api/v1/climate/{lat}/{lon}
```

#### レスポンス例

```json
{
  "location": {
    "lat": 35.4437,
    "lon": 139.6380,
    "name": "横浜市"
  },
  "climate_zone": "Cfa",
  "annual": {
    "avg_temp": 15.8,
    "total_precipitation": 1620,
    "frost_free_days": 230
  },
  "monthly": [
    {
      "month": 1,
      "avg_temp": 5.2,
      "min_temp": 1.8,
      "max_temp": 9.6,
      "precipitation": 52,
      "frost_days": 8
    },
    // ... 12ヶ月分
  ],
  "growing_calendar": {
    "last_frost": "04-05",
    "first_frost": "11-22",
    "growing_season_days": 231
  },
  "recommendations": {
    "spring_planting_start": "04-20",
    "fall_planting_start": "09-01",
    "rainy_season": {
      "start": "06-07",
      "end": "07-19"
    }
  }
}
```

---

## キャッシュ戦略

ERA5データは過去データなので、一度取得したら長期間キャッシュ可能。

| データ種別 | キャッシュ期間 |
|-----------|---------------|
| 過去30年平均 | 1年 |
| 月別データ | 1ヶ月 |
| 最新データ | 1週間 |

### キャッシュキー

```
climate:{lat_rounded}:{lon_rounded}:{year_range}
```

例: `climate:35.4:139.6:1991-2020`

---

## 実装フェーズ

### Phase 1: 基本機能

1. [ ] CDS APIアカウント作成・設定
2. [ ] 気候データ取得サービス実装
3. [ ] 月別気温・降水量の取得
4. [ ] キャッシュ機構
5. [ ] REST API エンドポイント

### Phase 2: 栽培指標の算出

1. [ ] 霜日の計算
2. [ ] 栽培可能期間の算出
3. [ ] 梅雨時期の推定（日本向け）
4. [ ] 積算温度（GDD）の計算

### Phase 3: Grow App統合

1. [ ] Flutter側のAPI呼び出し
2. [ ] 気候データ表示UI
3. [ ] 植物登録画面への統合
4. [ ] オフラインキャッシュ

---

## 技術的な検討事項

### 1. 座標の取得

ユーザーが入力する「場所」から緯度経度を取得する必要がある。

- **方法**: Geocoding API（Google Maps、OpenStreetMap Nominatim等）
- **Grow側で実装済み？**: 要確認

### 2. 日本固有の気候イベント

ERA5データから直接取得できない情報:
- 梅雨入り・梅雨明け → 過去の気象庁データから推定
- 台風シーズン → 統計的に8-10月

### 3. コスト見積もり

- CDS API: 無料
- サーバー: 既存インフラに追加
- キャッシュ（Redis）: 小規模なら無視できるレベル

---

## 参考リンク

- [Copernicus CDS](https://cds.climate.copernicus.eu/)
- [ERA5 Documentation](https://confluence.ecmwf.int/display/CKB/ERA5)
- [CDS API How-to](https://cds.climate.copernicus.eu/api-how-to)

---

## 次のステップ

1. [ ] CDS APIの利用登録
2. [ ] サンプルデータ取得テスト
3. [ ] AIseed Backendの言語・フレームワーク確認
4. [ ] 実装開始
