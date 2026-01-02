# AIseed サーバーセットアップマニュアル

このドキュメントは、AIseed バックエンド API サーバーのセットアップと運用手順を説明します。

## 前提条件

- Ubuntu 20.04 以上（または互換性のある Linux ディストリビューション）
- Python 3.10 以上
- ドメイン名（例: `api.aiseed.dev`）
- SSL証明書（Let's Encrypt推奨）

---

## 1. サーバー初期設定

### 1.1 システムアップデート

```bash
sudo apt update && sudo apt upgrade -y
```

### 1.2 必要なパッケージのインストール

```bash
sudo apt install -y python3 python3-pip python3-venv nginx certbot python3-certbot-nginx
```

---

## 2. アプリケーションのデプロイ

### 2.1 ユーザーとディレクトリの作成

```bash
# 専用ユーザーを作成
sudo useradd -m -s /bin/bash aiseed

# アプリケーションディレクトリを作成
sudo mkdir -p /opt/aiseed
sudo chown aiseed:aiseed /opt/aiseed
```

### 2.2 コードのデプロイ

```bash
# aiseed ユーザーに切り替え
sudo su - aiseed

# アプリケーションディレクトリに移動
cd /opt/aiseed

# Git からクローン（または手動でファイルをアップロード）
git clone https://github.com/YOUR_USERNAME/aiseed.git .
cd backend/aiseed
```

### 2.3 仮想環境のセットアップ

```bash
# 仮想環境を作成
python3 -m venv venv

# 仮想環境を有効化
source venv/bin/activate

# 依存関係をインストール
pip install -r requirements.txt
```

### 2.4 環境変数の設定

```bash
# .env ファイルを作成
nano /opt/aiseed/backend/aiseed/.env
```

以下の内容を記述：

```env
# Claude Agent SDK Configuration
# Claude Code を使用するため、API キーは不要です
# サーバー上で Claude Code を実行する場合は、初回起動時にログインが必要です

# データベース設定（PostgreSQL使用時）
DATABASE_URL=postgresql+asyncpg://aiseed:password@localhost/aiseed

# サーバー設定
HOST=0.0.0.0
PORT=8000
WORKERS=4
```

**Claude Code のセットアップ:**
```bash
# Claude Code をインストール
curl -fsSL https://claude.ai/install.sh | bash

# 初回起動時に Claude Console または Claude App でログイン
# API キーは不要です
```

詳細は [Claude Code セットアップガイド](https://code.claude.com/docs/ja/setup) を参照してください。

**注意:** WebとAPIが同じドメイン（`yourdomain.com/api/` と `yourdomain.com/app/`）にデプロイされるため、CORS設定は不要です。


---

## 3. Systemd サービスの設定

### 3.1 サービスファイルの作成

```bash
sudo nano /etc/systemd/system/aiseed.service
```

以下の内容を記述：

```ini
[Unit]
Description=AIseed FastAPI Server
After=network.target

[Service]
Type=simple
User=aiseed
Group=aiseed
WorkingDirectory=/opt/aiseed/backend/aiseed
Environment="PATH=/opt/aiseed/backend/aiseed/venv/bin"
EnvironmentFile=/opt/aiseed/backend/aiseed/.env
ExecStart=/opt/aiseed/backend/aiseed/venv/bin/uvicorn main:app --host 0.0.0.0 --port 8000 --workers 4
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

### 3.2 サービスの有効化と起動

```bash
# サービスをリロード
sudo systemctl daemon-reload

# サービスを有効化
sudo systemctl enable aiseed

# サービスを起動
sudo systemctl start aiseed

# ステータス確認
sudo systemctl status aiseed
```

---

## 4. Nginx リバースプロキシの設定

### 4.1 Nginx 設定ファイルの作成

```bash
sudo nano /etc/nginx/sites-available/aiseed
```

以下の内容を記述：

```nginx
server {
    listen 80;
    server_name aiseed.dev www.aiseed.dev;

    # ルートディレクトリ（静的サイト + Flutter Web）
    root /opt/aiseed/frontend;
    index index.html;

    # Public API（Web用、認証なし、厳しいレート制限）
    location /api/public/ {
        proxy_pass http://127.0.0.1:8000/public/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # 厳しいレート制限（IP単位）
        limit_req zone=public_api burst=5 nodelay;
    }

    # Authenticated API（アプリ用、認証必須）
    location /api/v1/ {
        proxy_pass http://127.0.0.1:8000/v1/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket サポート（将来的に必要な場合）
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    # Flutter Web アプリ
    location /app/ {
        alias /opt/aiseed/frontend/aiseed/build/web/;
        try_files $uri $uri/ /app/index.html;
        
        # Flutter Web の適切な MIME タイプ設定
        location ~* \.(js|css|wasm)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }

    # 静的サイト（ランディングページ）
    location / {
        alias /opt/aiseed/frontend/aiseed.dev/html/;
        try_files $uri $uri/ /index.html;
    }

    # セキュリティヘッダー
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
}

# レート制限ゾーン定義（http ブロックに追加）
# /etc/nginx/nginx.conf に以下を追加:
# limit_req_zone $binary_remote_addr zone=public_api:10m rate=5r/m;
```

**注意:** レート制限の設定は `/etc/nginx/nginx.conf` の `http` ブロックに追加してください。

### 4.2 設定の有効化


```bash
# シンボリックリンクを作成
sudo ln -s /etc/nginx/sites-available/aiseed /etc/nginx/sites-enabled/

# 設定をテスト
sudo nginx -t

# Nginx を再起動
sudo systemctl restart nginx
```

---

## 5. SSL証明書の設定（Let's Encrypt）

```bash
# Certbot で SSL証明書を取得
sudo certbot --nginx -d aiseed.dev -d www.aiseed.dev

# 自動更新のテスト
sudo certbot renew --dry-run
```


---

## 6. ファイアウォールの設定

```bash
# UFW を有効化
sudo ufw enable

# SSH を許可
sudo ufw allow ssh

# HTTP/HTTPS を許可
sudo ufw allow 'Nginx Full'

# ステータス確認
sudo ufw status
```

---

## 7. 動作確認

### 7.1 ローカルテスト

```bash
curl http://localhost:8000/
```

期待される出力：
```json
{
  "message": "AIseed API",
  "status": "running",
  "services": ["spark", "grow", "learn", "create"]
}
```

### 7.2 外部からのテスト

```bash
curl https://aiseed.dev/api/
```


---

## 8. ログの確認

### 8.1 アプリケーションログ

```bash
# リアルタイムでログを確認
sudo journalctl -u aiseed -f

# 最新100行を表示
sudo journalctl -u aiseed -n 100
```

### 8.2 Nginx ログ

```bash
# アクセスログ
sudo tail -f /var/log/nginx/access.log

# エラーログ
sudo tail -f /var/log/nginx/error.log
```

---

## 9. メンテナンス

### 9.1 アプリケーションの更新

```bash
# aiseed ユーザーに切り替え
sudo su - aiseed
cd /opt/aiseed

# 最新のコードを取得
git pull origin main

# 仮想環境を有効化
cd backend/aiseed
source venv/bin/activate

# 依存関係を更新
pip install -r requirements.txt --upgrade

# サービスを再起動
exit
sudo systemctl restart aiseed
```

### 9.2 サービスの再起動

```bash
# アプリケーションのみ再起動
sudo systemctl restart aiseed

# Nginx も再起動
sudo systemctl restart nginx
```

---

## 10. トラブルシューティング

### サービスが起動しない場合

```bash
# ログを確認
sudo journalctl -u aiseed -n 50 --no-pager

# 手動で起動してエラーを確認
sudo su - aiseed
cd /opt/aiseed/backend/aiseed
source venv/bin/activate
uvicorn main:app --host 0.0.0.0 --port 8000
```

### ポートが使用中の場合

```bash
# ポート8000を使用しているプロセスを確認
sudo lsof -i :8000

# 必要に応じてプロセスを終了
sudo kill -9 <PID>
```

### SSL証明書の更新に失敗する場合

```bash
# Certbot のログを確認
sudo cat /var/log/letsencrypt/letsencrypt.log

# 手動で更新
sudo certbot renew --force-renewal
```

---

## 11. セキュリティ推奨事項

1. **API キーの管理**
   - `.env` ファイルのパーミッションを `600` に設定
   - Git に `.env` を含めない（`.gitignore` で除外済み）

2. **CORS 設定**
   - 本番環境では `allow_origins=["*"]` を特定のドメインに変更

3. **レート制限**
   - Nginx または FastAPI で API レート制限を実装

4. **定期的な更新**
   - システムパッケージと Python パッケージを定期的に更新

---

## 12. パフォーマンス最適化

### 12.1 ワーカー数の調整

```bash
# CPU コア数を確認
nproc

# 推奨: (2 × CPU コア数) + 1
# 例: 4コアの場合 → 9 ワーカー
```

### 12.2 Nginx キャッシュの設定（オプション）

静的レスポンスをキャッシュする場合は Nginx の設定を追加。

---

## 参考リンク

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Uvicorn Deployment](https://www.uvicorn.org/deployment/)
- [Let's Encrypt](https://letsencrypt.org/)
- [Nginx Documentation](https://nginx.org/en/docs/)
