# AIseed API Server

Python FastAPI による AI 処理サーバー

## 概要

AI との会話処理を担当するサーバーです。
Go Gateway 経由でアクセスされることを想定しています。

## エンドポイント

| パス | 説明 |
|------|------|
| `GET /health` | ヘルスチェック |
| `POST /internal/spark/conversation` | Spark - 強み発見 |
| `POST /internal/grow/conversation` | Grow - 栽培・料理 |
| `POST /internal/create/conversation` | Create - Web制作 |
| `POST /internal/learn/conversation` | Learn - プログラミング学習 |
| `POST /internal/analyze` | 強み分析 |

## ローカル開発

```bash
# PostgreSQL起動（Docker）
docker run -d --name postgres \
  -e POSTGRES_USER=aiseed \
  -e POSTGRES_PASSWORD=aiseed \
  -e POSTGRES_DB=aiseed \
  -p 5432:5432 \
  postgres:16-alpine

# 依存関係インストール
pip install -r requirements.txt

# 起動
python main.py
```

## 環境変数

| 変数名 | 説明 | デフォルト |
|--------|------|-----------|
| `DATABASE_URL` | PostgreSQL接続URL | `postgresql://aiseed:aiseed@localhost:5432/aiseed` |
| `HOST` | バインドホスト | `0.0.0.0` |
| `PORT` | ポート番号 | `8001` |
| `LOG_LEVEL` | ログレベル | `INFO` |
| `DEV_MODE` | 開発モード | `false` |

## Docker

```bash
docker build -t aiseed-api .
docker run -p 8001:8001 -e DATABASE_URL=... aiseed-api
```
