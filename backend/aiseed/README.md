# AIseed Backend

FastAPI バックエンド API サーバー

## セットアップ

### 1. 依存関係のインストール

```bash
pip install -r requirements.txt
```

### 2. 環境変数の設定

`.env.example` をコピーして `.env` を作成：

```bash
cp .env.example .env
```

### 3. サーバーの起動

```bash
# 開発環境（DEV_MODE有効）
DEV_MODE=true uvicorn main:app --reload --port 8000

# 本番環境
uvicorn main:app --host 0.0.0.0 --port 8000 --workers 4
```

## API エンドポイント

### Public API（認証不要、レート制限あり）

| エンドポイント | 説明 |
|--------------|------|
| `GET /public/` | Public API ステータス |
| `POST /public/conversation` | 会話（サービス自動判定） |

### Authenticated API（認証必要）

| エンドポイント | 説明 |
|--------------|------|
| `GET /v1/` | API ステータス |
| `POST /v1/spark/conversation` | 強み発見サービス |
| `POST /v1/grow/conversation` | 栽培・料理サービス |
| `POST /v1/learn/conversation` | プログラミング学習サービス |
| `POST /v1/create/conversation` | Web制作サービス |
| `POST /v1/analyze` | 会話履歴から強みを分析 |

### 管理API（DEV_MODE時のみ）

| エンドポイント | 説明 |
|--------------|------|
| `GET /health` | ヘルスチェック |
| `POST /admin/api-keys` | APIキー作成 |
| `GET /admin/stats` | 統計情報 |

## 認証

### 開発モード（DEV_MODE=true）
- APIキーなしでアクセス可能
- Admin APIが使用可能

### 本番モード
- `X-API-Key` ヘッダーにAPIキーを指定
- APIキーはDBまたは環境変数で管理

```bash
# APIキーを使用したリクエスト例
curl -X POST http://localhost:8000/v1/spark/conversation \
  -H "X-API-Key: aiseed_xxxxx" \
  -H "Content-Type: application/json" \
  -d '{"user_message": "こんにちは", "conversation_history": []}'
```

## データベース

開発環境では SQLite を使用（`aiseed.db`が自動作成されます）。

### テーブル構成

- `api_keys` - APIキー管理
- `conversations` - 会話履歴
- `request_logs` - リクエストログ

## 環境変数

| 変数名 | 説明 | デフォルト値 |
|--------|------|-------------|
| `DEV_MODE` | 開発モード（認証スキップ） | `false` |
| `LOG_LEVEL` | ログレベル | `INFO` |
| `API_KEYS` | 有効なAPIキー（カンマ区切り） | - |
| `HOST` | サーバーホスト | `0.0.0.0` |
| `PORT` | サーバーポート | `8000` |

## テスト

```bash
# サーバー起動
DEV_MODE=true uvicorn main:app --reload

# 別ターミナルでテスト実行
python test_api.py
```

## ライセンス

AGPL-3.0 / Commercial License
詳細は [LICENSE](../../LICENSE) を参照
