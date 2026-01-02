"""
AIseed Server
AIと人が共に成長するプラットフォームのAPIサーバー

Copyright (c) 2026 AIseed.dev
Licensed under the GNU Affero General Public License v3.0 (AGPL-3.0)
Dual-licensed with a Commercial License. See LICENSE for details.
"""
import asyncio
import os
import logging
import aiosqlite
from contextlib import asynccontextmanager
from pathlib import Path
from fastapi import FastAPI, HTTPException, Header, Request, Depends
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from typing import Optional
from claude_agent_sdk import query, ClaudeAgentOptions
from collections import defaultdict
from datetime import datetime, timedelta

# ==================== ログ設定 ====================
LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO").upper()
LOG_FORMAT = "%(asctime)s | %(levelname)-8s | %(name)s | %(message)s"

logging.basicConfig(
    level=getattr(logging, LOG_LEVEL, logging.INFO),
    format=LOG_FORMAT,
    handlers=[
        logging.StreamHandler(),
    ]
)
logger = logging.getLogger("aiseed")

# ==================== データベース設定 ====================
DB_PATH = Path(__file__).parent / "aiseed.db"
db_connection: Optional[aiosqlite.Connection] = None

async def init_db():
    """データベース初期化"""
    global db_connection
    logger.info(f"データベース初期化: {DB_PATH}")
    db_connection = await aiosqlite.connect(DB_PATH)

    # テーブル作成
    await db_connection.executescript("""
        -- APIキー管理
        CREATE TABLE IF NOT EXISTS api_keys (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            key TEXT UNIQUE NOT NULL,
            user_id TEXT NOT NULL,
            plan TEXT DEFAULT 'free',
            rate_limit INTEGER DEFAULT 10,
            is_active INTEGER DEFAULT 1,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP,
            last_used_at TEXT
        );

        -- 会話履歴
        CREATE TABLE IF NOT EXISTS conversations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            session_id TEXT NOT NULL,
            user_id TEXT,
            service TEXT NOT NULL,
            role TEXT NOT NULL,
            content TEXT NOT NULL,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP
        );

        -- リクエストログ
        CREATE TABLE IF NOT EXISTS request_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            client_ip TEXT,
            user_id TEXT,
            endpoint TEXT NOT NULL,
            service TEXT,
            status_code INTEGER,
            response_time_ms INTEGER,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP
        );

        -- インデックス
        CREATE INDEX IF NOT EXISTS idx_api_keys_key ON api_keys(key);
        CREATE INDEX IF NOT EXISTS idx_conversations_session ON conversations(session_id);
        CREATE INDEX IF NOT EXISTS idx_request_logs_created ON request_logs(created_at);
    """)
    await db_connection.commit()
    logger.info("データベース初期化完了")

async def close_db():
    """データベース接続クローズ"""
    global db_connection
    if db_connection:
        await db_connection.close()
        logger.info("データベース接続クローズ")

@asynccontextmanager
async def lifespan(app: FastAPI):
    """アプリケーションライフサイクル管理"""
    await init_db()
    logger.info("AIseed Server 起動")
    yield
    await close_db()
    logger.info("AIseed Server 停止")

app = FastAPI(
    title="AIseed API",
    description="AIと人が共に成長するプラットフォーム",
    version="1.0.0",
    lifespan=lifespan
)

# 同一オリジンでのデプロイを想定（CORS不要）
# 開発: localhost:8000 (API) + localhost:XXXX (Flutter)
# 本番: yourdomain.com/api/ + yourdomain.com/app/

# 簡易的なレート制限（メモリベース）
# 本番環境ではRedisやデータベースを使用することを推奨
rate_limit_storage = defaultdict(list)

# ==================== DB ヘルパー関数 ====================

async def log_request(
    client_ip: str,
    endpoint: str,
    service: Optional[str] = None,
    user_id: Optional[str] = None,
    status_code: int = 200,
    response_time_ms: int = 0
):
    """リクエストログをDBに記録"""
    if db_connection:
        try:
            await db_connection.execute(
                """INSERT INTO request_logs
                   (client_ip, user_id, endpoint, service, status_code, response_time_ms)
                   VALUES (?, ?, ?, ?, ?, ?)""",
                (client_ip, user_id, endpoint, service, status_code, response_time_ms)
            )
            await db_connection.commit()
        except Exception as e:
            logger.error(f"リクエストログ記録エラー: {e}")

async def save_conversation(
    session_id: str,
    service: str,
    role: str,
    content: str,
    user_id: Optional[str] = None
):
    """会話履歴をDBに保存"""
    if db_connection:
        try:
            await db_connection.execute(
                """INSERT INTO conversations
                   (session_id, user_id, service, role, content)
                   VALUES (?, ?, ?, ?, ?)""",
                (session_id, user_id, service, role, content)
            )
            await db_connection.commit()
        except Exception as e:
            logger.error(f"会話履歴保存エラー: {e}")

async def verify_api_key_from_db(api_key: str) -> Optional[dict]:
    """DBからAPIキーを検証"""
    if not db_connection:
        return None

    try:
        cursor = await db_connection.execute(
            """SELECT user_id, plan, rate_limit, is_active
               FROM api_keys WHERE key = ?""",
            (api_key,)
        )
        row = await cursor.fetchone()

        if row and row[3]:  # is_active
            # last_used_at を更新
            await db_connection.execute(
                "UPDATE api_keys SET last_used_at = ? WHERE key = ?",
                (datetime.now().isoformat(), api_key)
            )
            await db_connection.commit()
            return {
                "user_id": row[0],
                "plan": row[1],
                "rate_limit": row[2]
            }
    except Exception as e:
        logger.error(f"APIキー検証エラー: {e}")

    return None

async def create_api_key(user_id: str, plan: str = "free") -> str:
    """新しいAPIキーを作成"""
    import secrets
    api_key = f"aiseed_{secrets.token_hex(16)}"

    if db_connection:
        await db_connection.execute(
            """INSERT INTO api_keys (key, user_id, plan) VALUES (?, ?, ?)""",
            (api_key, user_id, plan)
        )
        await db_connection.commit()
        logger.info(f"新しいAPIキー作成: user_id={user_id}, plan={plan}")

    return api_key

# リクエスト/レスポンスモデル
class ConversationRequest(BaseModel):
    user_message: str
    conversation_history: list[dict] = []
    user_context: Optional[dict] = None

class ConversationResponse(BaseModel):
    ai_message: str
    service: str
    timestamp: str

class StrengthAnalysis(BaseModel):
    abilities: list[dict]
    personality: list[dict]

# システムプロンプト
PROMPTS = {
    "spark": """
あなたは「強み発見アシスタント」です。
自然な会話を通じて、相手の能力や「らしさ」を発見してください。

【重要なルール】
- 「テスト」や「評価」の雰囲気を出さない
- 友達と話すようなリラックスした雰囲気で
- 相手の話に興味を持って聞く

【発見したい能力】
- 論理的思考、問題解決力、傾聴力、説明力、状況判断力、共感力

【発見したい「らしさ」】
- 価値観、興味関心、対人スタイル
""",
    "grow": """
あなたは「栽培・料理アドバイザー」です。
自然栽培、伝統野菜、料理についてアドバイスしてください。

【できること】
- 季節に合った野菜の提案
- 栽培方法のアドバイス
- 伝統野菜の歴史と育て方
- 収穫した野菜の料理レシピ

【スタンス】
- 初心者にも分かりやすく
- 実践的なアドバイス
- 一緒に学ぶ姿勢
""",
    "create": """
あなたは「Web制作アシスタント」です。
ユーザーの希望を聞いて、Webサイトを作る手伝いをしてください。

【できること】
- サイトの構成提案
- デザインのアドバイス
- コード生成
- 公開方法のガイド

【スタンス】
- 技術知識がなくても大丈夫
- ユーザーの希望を引き出す
- シンプルで美しいデザイン
""",
    "learn": """
あなたは「プログラミング学習パートナー」です。
ユーザーと一緒にプログラミングを学んでいくサポートをしてください。

【できること】
- プログラミングの基礎概念の説明
- コードの書き方・読み方のガイド
- エラーの解決サポート
- 実践的なプロジェクト提案
- 学習ロードマップの作成

【スタンス】
- 教えるのではなく一緒に考える
- 失敗を恐れない雰囲気作り
- 小さな成功体験を大切に
- ユーザーのペースに合わせる
- 「なぜ」を大切にする
"""
}

# レート制限チェック（簡易版）
def check_rate_limit(client_ip: str, limit: int = 5, window_minutes: int = 1) -> bool:
    """
    IPアドレスベースの簡易レート制限
    
    Args:
        client_ip: クライアントのIPアドレス
        limit: 制限回数
        window_minutes: 時間窓（分）
    
    Returns:
        True: 制限内, False: 制限超過
    """
    now = datetime.now()
    cutoff = now - timedelta(minutes=window_minutes)
    
    # 古いエントリを削除
    rate_limit_storage[client_ip] = [
        timestamp for timestamp in rate_limit_storage[client_ip]
        if timestamp > cutoff
    ]
    
    # 制限チェック
    if len(rate_limit_storage[client_ip]) >= limit:
        return False
    
    # 新しいリクエストを記録
    rate_limit_storage[client_ip].append(now)
    return True

async def handle_conversation(service: str, request: ConversationRequest) -> ConversationResponse:
    """共通の会話処理"""
    
    history = ""
    for msg in request.conversation_history:
        role = "ユーザー" if msg.get("role") == "user" else "AI"
        history += f"{role}: {msg.get('content', '')}\n"
    
    prompt = f"""
{PROMPTS.get(service, PROMPTS["spark"])}

【これまでの会話】
{history}

【ユーザーの最新メッセージ】
{request.user_message}

自然に会話を続けてください。返答のみを出力してください。
"""
    
    try:
        options = ClaudeAgentOptions(
            system_prompt="あなたは親しみやすい対話パートナーです。"
        )
        
        response_text = ""
        async for message in query(prompt=prompt, options=options):
            if hasattr(message, 'content'):
                for block in message.content:
                    if hasattr(block, 'text'):
                        response_text += block.text
        
        return ConversationResponse(
            ai_message=response_text.strip(),
            service=service,
            timestamp=datetime.now().isoformat()
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"AI処理エラー: {str(e)}")

# ==================== Public API (Web用、認証なし) ====================

@app.get("/public/")
async def public_root():
    """Public API ステータス"""
    return {
        "message": "AIseed Public API",
        "status": "running",
        "services": ["spark", "grow", "learn", "create"],
        "note": "Web用の制限付きAPI"
    }

@app.post("/public/conversation", response_model=ConversationResponse)
async def public_conversation(request: ConversationRequest, req: Request):
    """
    Public API - 会話エンドポイント（認証なし、厳しいレート制限）
    Spark, Grow, Create のいずれかを自動判定
    """
    client_ip = req.client.host
    
    # レート制限チェック（5リクエスト/分）
    if not check_rate_limit(client_ip, limit=5, window_minutes=1):
        raise HTTPException(
            status_code=429,
            detail="レート制限を超過しました。1分後に再試行してください。"
        )
    
    # デフォルトは Spark サービス
    service = "spark"
    
    # メッセージ内容から簡易的にサービスを判定
    message_lower = request.user_message.lower()
    if any(word in message_lower for word in ["野菜", "栽培", "料理", "レシピ", "育て"]):
        service = "grow"
    elif any(word in message_lower for word in ["プログラミング", "コード", "python", "javascript", "エラー", "バグ", "関数", "変数"]):
        service = "learn"
    elif any(word in message_lower for word in ["web", "サイト", "ホームページ", "デザイン"]):
        service = "create"
    
    return await handle_conversation(service, request)

# ==================== Authenticated API (アプリ用、認証必須) ====================

async def verify_api_key(x_api_key: str = Header(None, alias="X-API-Key")):
    """
    API キー認証
    DBまたは環境変数から検証
    """
    # 開発モード判定
    dev_mode = os.getenv("DEV_MODE", "false").lower() == "true"

    if not x_api_key:
        if dev_mode:
            logger.debug("開発モード: APIキーなしでアクセス許可")
            return {"user_id": "dev", "plan": "dev", "rate_limit": 100}
        raise HTTPException(status_code=401, detail="APIキーが必要です")

    # DBから検証
    user_info = await verify_api_key_from_db(x_api_key)
    if user_info:
        logger.debug(f"APIキー認証成功: user_id={user_info['user_id']}")
        return user_info

    # 環境変数からも検証（フォールバック）
    valid_keys = os.getenv("API_KEYS", "").split(",")
    valid_keys = [key.strip() for key in valid_keys if key.strip()]

    if x_api_key in valid_keys:
        return {"user_id": x_api_key[:8], "plan": "free", "rate_limit": 10}

    # 開発モードならAPIキーが無効でも許可
    if dev_mode:
        logger.warning(f"開発モード: 無効なAPIキーを許可: {x_api_key[:8]}...")
        return {"user_id": "dev", "plan": "dev", "rate_limit": 100}

    raise HTTPException(status_code=403, detail="無効なAPIキーです")

@app.get("/v1/")
async def v1_root():
    """Authenticated API ステータス"""
    return {
        "message": "AIseed Authenticated API v1",
        "status": "running",
        "services": ["spark", "grow", "learn", "create"],
        "note": "認証が必要なAPI"
    }

@app.post("/v1/spark/conversation", response_model=ConversationResponse)
async def v1_spark_conversation(
    request: ConversationRequest,
    req: Request,
    user_info: dict = Depends(verify_api_key)
):
    """Authenticated API - Spark（強み発見）"""
    logger.info(f"[Spark] user={user_info['user_id']} message={request.user_message[:50]}...")
    await log_request(req.client.host, "/v1/spark/conversation", "spark", user_info["user_id"])
    return await handle_conversation("spark", request)

@app.post("/v1/grow/conversation", response_model=ConversationResponse)
async def v1_grow_conversation(
    request: ConversationRequest,
    req: Request,
    user_info: dict = Depends(verify_api_key)
):
    """Authenticated API - Grow（栽培・料理）"""
    logger.info(f"[Grow] user={user_info['user_id']} message={request.user_message[:50]}...")
    await log_request(req.client.host, "/v1/grow/conversation", "grow", user_info["user_id"])
    return await handle_conversation("grow", request)

@app.post("/v1/create/conversation", response_model=ConversationResponse)
async def v1_create_conversation(
    request: ConversationRequest,
    req: Request,
    user_info: dict = Depends(verify_api_key)
):
    """Authenticated API - Create（Web制作）"""
    logger.info(f"[Create] user={user_info['user_id']} message={request.user_message[:50]}...")
    await log_request(req.client.host, "/v1/create/conversation", "create", user_info["user_id"])
    return await handle_conversation("create", request)

@app.post("/v1/learn/conversation", response_model=ConversationResponse)
async def v1_learn_conversation(
    request: ConversationRequest,
    req: Request,
    user_info: dict = Depends(verify_api_key)
):
    """Authenticated API - Learn（プログラミング学習）"""
    logger.info(f"[Learn] user={user_info['user_id']} message={request.user_message[:50]}...")
    await log_request(req.client.host, "/v1/learn/conversation", "learn", user_info["user_id"])
    return await handle_conversation("learn", request)

@app.post("/v1/analyze", response_model=StrengthAnalysis)
async def v1_analyze_strengths(
    conversation_history: list[dict],
    req: Request,
    user_info: dict = Depends(verify_api_key)
):
    """Authenticated API - 強み分析"""
    logger.info(f"[Analyze] user={user_info['user_id']} history_len={len(conversation_history)}")
    await log_request(req.client.host, "/v1/analyze", "spark", user_info["user_id"])
    
    history = "\n".join([
        f"{'ユーザー' if msg.get('role') == 'user' else 'AI'}: {msg.get('content', '')}"
        for msg in conversation_history
    ])
    
    prompt = f"""
以下の会話から、ユーザーの強みを分析してください。

【会話】
{history}

JSON形式で出力:
{{
  "abilities": [{{"name": "能力名", "score": 0.8, "evidence": "根拠"}}],
  "personality": [{{"name": "特徴", "evidence": "根拠"}}]
}}
"""
    
    try:
        options = ClaudeAgentOptions()
        
        response_text = ""
        async for message in query(prompt=prompt, options=options):
            if hasattr(message, 'content'):
                for block in message.content:
                    if hasattr(block, 'text'):
                        response_text += block.text
        
        import json
        import re
        
        json_match = re.search(r'\{.*\}', response_text, re.DOTALL)
        if json_match:
            result = json.loads(json_match.group())
            return StrengthAnalysis(**result)
        
        return StrengthAnalysis(abilities=[], personality=[])
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# ==================== 管理用エンドポイント ====================

@app.get("/")
async def root():
    """ルートエンドポイント"""
    return {
        "message": "AIseed API",
        "version": "1.0.0",
        "endpoints": {
            "public": "/public/",
            "authenticated": "/v1/",
            "admin": "/admin/"
        }
    }

@app.get("/health")
async def health_check():
    """ヘルスチェック"""
    db_status = "connected" if db_connection else "disconnected"
    return {
        "status": "healthy",
        "database": db_status,
        "timestamp": datetime.now().isoformat()
    }

# ==================== Admin API (開発・管理用) ====================

class CreateApiKeyRequest(BaseModel):
    user_id: str
    plan: str = "free"

class ApiKeyResponse(BaseModel):
    api_key: str
    user_id: str
    plan: str

@app.post("/admin/api-keys", response_model=ApiKeyResponse)
async def admin_create_api_key(request: CreateApiKeyRequest):
    """
    APIキー作成（開発用）
    本番環境では適切な認証を追加すること
    """
    dev_mode = os.getenv("DEV_MODE", "false").lower() == "true"
    if not dev_mode:
        raise HTTPException(status_code=403, detail="開発モードでのみ利用可能")

    api_key = await create_api_key(request.user_id, request.plan)
    logger.info(f"[Admin] APIキー作成: user_id={request.user_id}")

    return ApiKeyResponse(
        api_key=api_key,
        user_id=request.user_id,
        plan=request.plan
    )

@app.get("/admin/stats")
async def admin_stats():
    """
    統計情報取得（開発用）
    """
    dev_mode = os.getenv("DEV_MODE", "false").lower() == "true"
    if not dev_mode:
        raise HTTPException(status_code=403, detail="開発モードでのみ利用可能")

    if not db_connection:
        return {"error": "データベース未接続"}

    # 統計情報を取得
    stats = {}

    # APIキー数
    cursor = await db_connection.execute("SELECT COUNT(*) FROM api_keys")
    row = await cursor.fetchone()
    stats["total_api_keys"] = row[0] if row else 0

    # 会話数
    cursor = await db_connection.execute("SELECT COUNT(*) FROM conversations")
    row = await cursor.fetchone()
    stats["total_conversations"] = row[0] if row else 0

    # リクエスト数
    cursor = await db_connection.execute("SELECT COUNT(*) FROM request_logs")
    row = await cursor.fetchone()
    stats["total_requests"] = row[0] if row else 0

    # サービス別リクエスト数
    cursor = await db_connection.execute(
        "SELECT service, COUNT(*) FROM request_logs WHERE service IS NOT NULL GROUP BY service"
    )
    rows = await cursor.fetchall()
    stats["requests_by_service"] = {row[0]: row[1] for row in rows}

    return stats

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
