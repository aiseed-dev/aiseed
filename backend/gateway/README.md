# AIseed Gateway

Go による高速 API ゲートウェイ

## 概要

認証、レート制限、リクエストログなどの高速処理を担当するゲートウェイです。
Python API サーバーへのリバースプロキシとして機能します。

## 機能

- **認証**: APIキーベースの認証
- **レート制限**: インメモリでの高速レート制限
- **リクエストログ**: PostgreSQLへの非同期ログ記録
- **リバースプロキシ**: Python APIへのリクエスト転送

## エンドポイント

### Public API（認証不要）

| パス | 説明 |
|------|------|
| `GET /public/` | ステータス |
| `POST /public/conversation` | 会話（サービス自動判定） |

### v1 API（認証必要）

| パス | 説明 |
|------|------|
| `GET /v1/` | ステータス |
| `POST /v1/spark/conversation` | Spark |
| `POST /v1/grow/conversation` | Grow |
| `POST /v1/create/conversation` | Create |
| `POST /v1/learn/conversation` | Learn |
| `POST /v1/analyze` | 強み分析 |

### Admin API（DEV_MODE時のみ）

| パス | 説明 |
|------|------|
| `POST /admin/api-keys` | APIキー作成 |
| `GET /admin/stats` | 統計情報 |

## ローカル開発

```bash
# PostgreSQL起動
docker run -d --name postgres \
  -e POSTGRES_USER=aiseed \
  -e POSTGRES_PASSWORD=aiseed \
  -e POSTGRES_DB=aiseed \
  -p 5432:5432 \
  postgres:16-alpine

# ビルド＆起動
go build -o gateway .
DEV_MODE=true ./gateway
```

## 環境変数

| 変数名 | 説明 | デフォルト |
|--------|------|-----------|
| `DATABASE_URL` | PostgreSQL接続URL | `postgresql://aiseed:aiseed@localhost:5432/aiseed` |
| `API_SERVER` | Python APIサーバー | `http://localhost:8001` |
| `PORT` | ポート番号 | `8000` |
| `DEV_MODE` | 開発モード | `false` |

## Docker

```bash
docker build -t aiseed-gateway .
docker run -p 8000:8000 -e DATABASE_URL=... -e API_SERVER=... aiseed-gateway
```
