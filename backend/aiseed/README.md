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

`.env` ファイルを編集して、必要な設定を行います：

```env
# Claude Agent SDK Configuration
# Claude Code を使用するため、API キーは不要です
# 初回起動時に Claude Console または Claude App でログインしてください

# データベース接続（PostgreSQL使用時）
DATABASE_URL=postgresql+asyncpg://aiseed:password@localhost/aiseed
```

**Claude Code のセットアップ:**
1. Claude Code をインストール: `curl -fsSL https://claude.ai/install.sh | bash`
2. 初回起動時に Claude Console または Claude App（Pro/Max）でログイン
3. API キーは不要です（Claude Code が自動的に認証を処理）

詳細は [Claude Code セットアップガイド](https://code.claude.com/docs/ja/setup) を参照してください。

**注意:** WebとAPIは同じドメインにデプロイされるため、CORS設定は不要です。

### 3. サーバーの起動

```bash
# 開発環境
uvicorn main:app --reload --port 8000

# 本番環境
uvicorn main:app --host 0.0.0.0 --port 8000 --workers 4
```

## API エンドポイント

### ルート
- `GET /` - API ステータス確認

### サービスエンドポイント
- `POST /spark/conversation` - 強み発見サービス
- `POST /grow/conversation` - 栽培・料理サービス
- `POST /learn/conversation` - プログラミング学習サービス
- `POST /create/conversation` - Web制作サービス

### 分析エンドポイント
- `POST /analyze` - 会話履歴から強みを分析

## 環境変数

| 変数名 | 説明 | デフォルト値 |
|--------|------|-------------|
| `ANTHROPIC_API_KEY` | Claude API キー（必須） | - |
| `DATABASE_URL` | PostgreSQL 接続URL | - |
| `HOST` | サーバーホスト | `0.0.0.0` |
| `PORT` | サーバーポート | `8000` |
| `WORKERS` | ワーカー数 | `4` |
| `DEFAULT_RATE_LIMIT_FREE` | 無料ユーザーのレート制限 | `10` |
| `DEFAULT_RATE_LIMIT_PREMIUM` | 有料ユーザーのレート制限 | `100` |

## ライセンス

このプロジェクトは AGPL-3.0 ライセンスの下で公開されています。
商用利用については別途ライセンスが必要です。詳細は [LICENSE](../../LICENSE) を参照してください。
