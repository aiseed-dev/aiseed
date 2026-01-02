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
└── README.md
```

## デプロイ

本番環境: `api.aiseed.dev`

開発時もFlutterアプリは本番サーバーに接続します。

## API使用例

### 会話（Public API）

```bash
curl -X POST https://api.aiseed.dev/public/conversation \
  -H "Content-Type: application/json" \
  -d '{"user_message": "こんにちは", "conversation_history": []}'
```

### 会話（認証あり）

```bash
curl -X POST https://api.aiseed.dev/v1/spark/conversation \
  -H "Content-Type: application/json" \
  -H "X-API-Key: aiseed_xxxxx" \
  -d '{"user_message": "こんにちは", "conversation_history": []}'
```

## ライセンス

AGPL-3.0 / Commercial License
