# AIseed Backend

## アーキテクチャ

```
                    ┌─────────────────┐
                    │    クライアント   │
                    └────────┬────────┘
                             │
                             ▼
┌────────────────────────────────────────────────────┐
│                  Gateway (Go)                       │
│  ・認証（APIキー検証）                               │
│  ・レート制限（インメモリ）                          │
│  ・リクエストログ                                    │
│  ・リバースプロキシ                                  │
│                      :8000                          │
└────────────────────────┬───────────────────────────┘
                         │
                         ▼
┌────────────────────────────────────────────────────┐
│                  API Server (Python)                │
│  ・AI会話処理                                       │
│  ・会話履歴保存                                     │
│                      :8001                          │
└────────────────────────┬───────────────────────────┘
                         │
                         ▼
┌────────────────────────────────────────────────────┐
│                 PostgreSQL                          │
│  ・api_keys（APIキー管理）                          │
│  ・conversations（会話履歴）                        │
│  ・request_logs（リクエストログ）                   │
│                      :5432                          │
└────────────────────────────────────────────────────┘
```

## ディレクトリ構成

```
backend/
├── gateway/           # Go Gateway（認証・レート制限）
├── aiseed/            # Python API（AI処理）
├── docker-compose.yml # 一括起動設定
└── README.md
```

## クイックスタート

### Docker Compose（推奨）

```bash
cd backend
docker-compose up -d
```

起動後:
- Gateway: http://localhost:8000
- API Server: http://localhost:8001
- PostgreSQL: localhost:5432

### ローカル開発

1. PostgreSQLを起動:
```bash
docker run -d --name postgres \
  -e POSTGRES_USER=aiseed \
  -e POSTGRES_PASSWORD=aiseed \
  -e POSTGRES_DB=aiseed \
  -p 5432:5432 \
  postgres:16-alpine
```

2. Python APIを起動:
```bash
cd aiseed
pip install -r requirements.txt
python main.py
```

3. Go Gatewayを起動:
```bash
cd gateway
go build -o gateway .
DEV_MODE=true ./gateway
```

## API使用例

### APIキー作成（開発モード）

```bash
curl -X POST http://localhost:8000/admin/api-keys \
  -H "Content-Type: application/json" \
  -d '{"user_id": "test_user", "plan": "free"}'
```

### 会話（認証あり）

```bash
curl -X POST http://localhost:8000/v1/spark/conversation \
  -H "Content-Type: application/json" \
  -H "X-API-Key: aiseed_xxxxx" \
  -d '{"user_message": "こんにちは", "conversation_history": []}'
```

### 会話（Public API）

```bash
curl -X POST http://localhost:8000/public/conversation \
  -H "Content-Type: application/json" \
  -d '{"user_message": "プログラミングを学びたい", "conversation_history": []}'
```

## 環境変数

### Gateway

| 変数名 | 説明 | デフォルト |
|--------|------|-----------|
| `DATABASE_URL` | PostgreSQL接続URL | `postgresql://aiseed:aiseed@localhost:5432/aiseed` |
| `API_SERVER` | Python APIサーバー | `http://localhost:8001` |
| `PORT` | ポート番号 | `8000` |
| `DEV_MODE` | 開発モード | `false` |

### API Server

| 変数名 | 説明 | デフォルト |
|--------|------|-----------|
| `DATABASE_URL` | PostgreSQL接続URL | `postgresql://aiseed:aiseed@localhost:5432/aiseed` |
| `PORT` | ポート番号 | `8001` |
| `LOG_LEVEL` | ログレベル | `INFO` |

## ライセンス

AGPL-3.0 / Commercial License
