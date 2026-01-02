"""
AIseed API Server
AIと人が共に成長するプラットフォームのAPIサーバー

Copyright (c) 2026 AIseed.dev
Licensed under the GNU Affero General Public License v3.0 (AGPL-3.0)
Dual-licensed with a Commercial License. See LICENSE for details.
"""
import os
import logging
import asyncpg
from contextlib import asynccontextmanager
from fastapi import FastAPI, HTTPException, Header, Request
from pydantic import BaseModel
from pydantic_settings import BaseSettings
from typing import Optional
from claude_agent_sdk import query, ClaudeAgentOptions
from datetime import datetime

# ==================== 設定 ====================
class Settings(BaseSettings):
    # Database
    database_url: str = "postgresql://aiseed:aiseed@localhost:5432/aiseed"

    # Server
    host: str = "0.0.0.0"
    port: int = 8001  # Goのgatewayが8000を使用

    # Logging
    log_level: str = "INFO"

    # Development
    dev_mode: bool = False

    class Config:
        env_file = ".env"
        extra = "ignore"

settings = Settings()

# ==================== ログ設定 ====================
LOG_FORMAT = "%(asctime)s | %(levelname)-8s | %(name)s | %(message)s"
logging.basicConfig(
    level=getattr(logging, settings.log_level.upper(), logging.INFO),
    format=LOG_FORMAT,
)
logger = logging.getLogger("aiseed.api")

# ==================== データベース ====================
db_pool: Optional[asyncpg.Pool] = None

async def init_db():
    """PostgreSQL接続プール初期化"""
    global db_pool
    logger.info(f"PostgreSQL接続: {settings.database_url.split('@')[1] if '@' in settings.database_url else settings.database_url}")

    try:
        db_pool = await asyncpg.create_pool(
            settings.database_url,
            min_size=2,
            max_size=10,
            command_timeout=60
        )
        logger.info("PostgreSQL接続プール作成完了")
    except Exception as e:
        logger.error(f"PostgreSQL接続エラー: {e}")
        raise

async def close_db():
    """データベース接続クローズ"""
    global db_pool
    if db_pool:
        await db_pool.close()
        logger.info("PostgreSQL接続クローズ")

@asynccontextmanager
async def lifespan(app: FastAPI):
    """アプリケーションライフサイクル管理"""
    await init_db()
    logger.info("AIseed API Server 起動")
    yield
    await close_db()
    logger.info("AIseed API Server 停止")

# ==================== FastAPI ====================
app = FastAPI(
    title="AIseed API",
    description="AIと人が共に成長するプラットフォーム - AI処理API",
    version="1.0.0",
    lifespan=lifespan
)

# ==================== モデル ====================
class ConversationRequest(BaseModel):
    user_message: str
    conversation_history: list[dict] = []
    session_id: Optional[str] = None
    user_context: Optional[dict] = None

class ConversationResponse(BaseModel):
    ai_message: str
    service: str
    timestamp: str

class StrengthAnalysis(BaseModel):
    abilities: list[dict]
    personality: list[dict]

# ==================== システムプロンプト ====================
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
あなたは「AI学習パートナー」です。
ユーザーと一緒にAIの使い方を学んでいくサポートをしてください。

【できること】
- AIの基礎概念の説明（LLM、プロンプト、トークンなど）
- 効果的なプロンプトの書き方
- AIツールの活用方法（ChatGPT、Claude、画像生成AIなど）
- AIを使った問題解決のサポート
- AIとの上手な付き合い方

【スタンス】
- 教えるのではなく一緒に学ぶ
- 実際に使いながら理解を深める
- AIの得意・不得意を理解する
- ユーザーのペースに合わせる
- 「なぜそうなるか」を一緒に考える
"""
}

# ==================== DBヘルパー ====================
async def save_conversation(
    session_id: str,
    service: str,
    role: str,
    content: str,
    user_id: Optional[str] = None
):
    """会話履歴をDBに保存"""
    if not db_pool:
        return

    try:
        async with db_pool.acquire() as conn:
            await conn.execute(
                """INSERT INTO conversations (session_id, user_id, service, role, content)
                   VALUES ($1, $2, $3, $4, $5)""",
                session_id, user_id, service, role, content
            )
    except Exception as e:
        logger.error(f"会話履歴保存エラー: {e}")

# ==================== 会話処理 ====================
async def handle_conversation(service: str, request: ConversationRequest) -> ConversationResponse:
    """会話処理"""

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

        # 会話履歴を保存
        if request.session_id:
            await save_conversation(request.session_id, service, "user", request.user_message)
            await save_conversation(request.session_id, service, "assistant", response_text.strip())

        return ConversationResponse(
            ai_message=response_text.strip(),
            service=service,
            timestamp=datetime.now().isoformat()
        )
    except Exception as e:
        logger.error(f"AI処理エラー: {e}")
        raise HTTPException(status_code=500, detail=f"AI処理エラー: {str(e)}")

# ==================== エンドポイント ====================
# 注意: 認証・レート制限はGoのgatewayで処理
# このAPIはgateway経由でのみアクセスされる想定

@app.get("/")
async def root():
    """ルートエンドポイント"""
    return {
        "message": "AIseed API Server",
        "version": "1.0.0",
        "note": "このAPIはgateway経由でアクセスしてください"
    }

@app.get("/health")
async def health_check():
    """ヘルスチェック"""
    db_status = "connected" if db_pool else "disconnected"
    return {
        "status": "healthy",
        "database": db_status,
        "timestamp": datetime.now().isoformat()
    }

@app.post("/internal/spark/conversation", response_model=ConversationResponse)
async def spark_conversation(request: ConversationRequest):
    """Spark - 強み発見"""
    logger.info(f"[Spark] message={request.user_message[:50]}...")
    return await handle_conversation("spark", request)

@app.post("/internal/grow/conversation", response_model=ConversationResponse)
async def grow_conversation(request: ConversationRequest):
    """Grow - 栽培・料理"""
    logger.info(f"[Grow] message={request.user_message[:50]}...")
    return await handle_conversation("grow", request)

@app.post("/internal/create/conversation", response_model=ConversationResponse)
async def create_conversation(request: ConversationRequest):
    """Create - Web制作"""
    logger.info(f"[Create] message={request.user_message[:50]}...")
    return await handle_conversation("create", request)

@app.post("/internal/learn/conversation", response_model=ConversationResponse)
async def learn_conversation(request: ConversationRequest):
    """Learn - AIと一緒にAIの使い方を学ぶ"""
    logger.info(f"[Learn] message={request.user_message[:50]}...")
    return await handle_conversation("learn", request)

@app.post("/internal/analyze", response_model=StrengthAnalysis)
async def analyze_strengths(conversation_history: list[dict]):
    """強み分析"""
    logger.info(f"[Analyze] history_len={len(conversation_history)}")

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
        logger.error(f"分析エラー: {e}")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host=settings.host, port=settings.port)
