# AIseed 🌱

AIと共に成長するプラットフォーム

## 哲学

AIの時代だからこそ、デジタルとアナログの両方が大切。
土に触れ、子どもと向き合い、そしてAIと創る。

## サービス一覧

| サービス | 説明 |
|---------|------|
| **Spark** ✨ | 自分を知る - 対話や体験から強みと「らしさ」を発見 |
| **Grow** 🌱 | 育てる - 栽培・遊び・成長記録 |
| **Create** 🎨 | BYOA - あなたのAIで創る |

### Spark - 自分を知る

2つのモードで強みを発見：

- **💬 おしゃべりで発見**: 自然な会話から能力と「らしさ」を見つける
- **🎮 体験で発見**: 6つの簡単な体験から言葉にならない傾向を発見

#### 体験タスク

1. 👀 **観察** - 何が気になる？
2. 🔊 **音と連想** - 何を思い浮かべた？
3. 🧩 **並べてみる** - 好きなように
4. 🌱 **続きを選ぶ** - 種が飛んで...
5. 🥁 **リズム** - 好きなようにタップ
6. 🎨 **色を選ぶ** - 今日の気分は？

### BYOA - Bring Your Own AI

生成されたスキルファイル（SKILL.md）は、どのAIでも使えます。
Claude、ChatGPT、Gemini...あなた専用のパートナーに。

## 構成

```
aiseed/
├── frontend/aiseed/        # Flutter アプリ
│   └── lib/
│       ├── screens/spark/  # Spark（モード選択・体験タスク）
│       ├── screens/grow/   # Grow
│       └── screens/create/ # Create
└── backend/
    ├── gateway/            # APIゲートウェイ Go
    └── aiseed/             # FastAPI
        ├── agent/          # AIエージェント
        │   ├── core.py     # AIseedAgent
        │   ├── prompts.py  # プロンプト定義
        │   └── tools/      # ツール群
        │       ├── insight.py  # 特性記録
        │       ├── skill.py    # スキル生成（BYOA）
        │       ├── history.py  # 履歴管理
        │       └── experience.py # 体験タスク
        └── memory/         # メモリ管理
            └── store.py    # ユーザーメモリ
```

## セットアップ

### バックエンド

```bash
cd backend/aiseed
pip install -r requirements.txt
uvicorn main:app --reload --port 8001
```

### フロントエンド

```bash
cd frontend/aiseed
flutter pub get
flutter run
```

## API

### Spark API

```
POST /internal/spark/conversation      # おしゃべりモード
POST /internal/spark/experience/start  # 体験モード開始
GET  /internal/spark/experience/tasks  # タスク一覧
POST /internal/spark/experience/submit # タスク結果送信
```

### その他

```
POST /internal/grow/conversation   # Grow会話
POST /internal/create/conversation # Create会話
GET  /internal/user/{id}/profile   # ユーザープロファイル
POST /internal/skill/generate      # スキル生成（BYOA）
```

## ライセンス

このプロジェクトは **デュアルライセンス** で提供されています：

### オープンソース利用

[GNU Affero General Public License v3.0 (AGPL-3.0)](LICENSE) の条件に従って自由に利用できます。

### 商用利用

AGPL-3.0 の条件を満たせない場合、商用ライセンスを取得できます。
詳細は [contact@aiseed.dev](mailto:contact@aiseed.dev) までお問い合わせください。

## 著者

Copyright (c) 2026 AIseed.dev
