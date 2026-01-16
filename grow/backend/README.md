# Grow HP Builder - AIサーバー

農家向けホームページ作成のためのAIサーバー。

## 構成

```
アプリ（Flutter）
    ↓ HTTP
Linux サーバー（Python/FastAPI）
    ↓ subprocess
Claude Code CLI（Claude MAX）
    ↓
HTML返却
```

## セットアップ

```bash
cd grow/backend

# 仮想環境作成
python -m venv venv
source venv/bin/activate

# 依存パッケージインストール
pip install -r requirements.txt

# Claude Code CLIがインストールされていることを確認
claude --version
```

## 起動

```bash
# 開発用
python main.py

# または uvicorn で起動
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

## API

### ヘルスチェック

```
GET /
```

### HP生成

```
POST /api/hp/generate

{
  "farm_name": "山田農園",
  "farming_methods": ["自然栽培"],
  "plants": [
    {"name": "トマト", "variety": "サンマルツァーノ", "days_growing": 45}
  ],
  "user_request": "イタリア風のおしゃれなデザインで"
}
```

### HP修正

```
POST /api/hp/modify

{
  "current_html": "<!DOCTYPE html>...",
  "modification_request": "色をもう少し緑っぽくして"
}
```

## 認証

- **内部テスト**: 認証なし（内部ネットワーク）
- **クローズドテスト以降**: 認証を追加予定

## TODO

- [ ] 認証の追加
- [ ] レート制限
- [ ] ログ出力
- [ ] エラーハンドリングの改善
