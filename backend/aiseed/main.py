"""
AIseed API Server
AIと人が共に成長するプラットフォームのAPIサーバー

Copyright (c) 2026 AIseed.dev
Licensed under the GNU Affero General Public License v3.0 (AGPL-3.0)
Dual-licensed with a Commercial License. See LICENSE for details.
"""
import os
import sys
import logging
import asyncpg
from contextlib import asynccontextmanager
from fastapi import FastAPI, HTTPException, Header, Request
from pydantic import BaseModel
from pydantic_settings import BaseSettings
from typing import Optional
from datetime import datetime

# パスの追加（agent, memoryモジュールのため）
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from agent.core import AIseedAgent
from agent.prompts import get_prompt, PROMPTS, SERVICES, get_service_info
from memory.store import UserMemory

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

    # Memory
    memory_base_path: str = "user_memory"

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

# ==================== グローバル ====================
db_pool: Optional[asyncpg.Pool] = None
agent: Optional[AIseedAgent] = None

# ==================== データベース ====================
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
    global agent

    await init_db()

    # エージェントの初期化
    agent = AIseedAgent(memory_base_path=settings.memory_base_path)
    logger.info(f"AIseed Agent 初期化完了 (memory: {settings.memory_base_path})")

    logger.info("AIseed API Server 起動")
    yield
    await close_db()
    logger.info("AIseed API Server 停止")

# ==================== FastAPI ====================
app = FastAPI(
    title="AIseed API",
    description="AIと人が共に成長するプラットフォーム - AI処理API",
    version="2.0.0",
    lifespan=lifespan
)

# ==================== モデル ====================
class ConversationRequest(BaseModel):
    user_message: str
    conversation_history: list[dict] = []
    session_id: Optional[str] = None
    user_id: Optional[str] = None  # 追加: ユーザーID
    user_context: Optional[dict] = None

class ConversationResponse(BaseModel):
    ai_message: str
    service: str
    timestamp: str
    user_id: Optional[str] = None

class StrengthAnalysis(BaseModel):
    abilities: list[dict]
    personality: list[dict]

class UserProfileResponse(BaseModel):
    user_id: str
    age_group: Optional[str]
    conversation_count: int
    abilities: list[dict]
    personalities: list[dict]
    interests: list[dict]
    skills: list[str]

class SkillGenerateRequest(BaseModel):
    user_id: str
    skill_type: str  # spark, grow, create, learn

class SkillResponse(BaseModel):
    status: str
    skill_type: str
    content: Optional[str] = None
    message: Optional[str] = None

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
    """会話処理（エージェントを使用）"""
    global agent

    # ユーザーIDの決定（未指定の場合はセッションIDを使用）
    user_id = request.user_id or request.session_id or "anonymous"

    try:
        # エージェントで会話を処理
        response_text = await agent.chat(
            service=service,
            user_message=request.user_message,
            user_id=user_id,
            session_id=request.session_id,
            conversation_history=request.conversation_history
        )

        # 会話履歴をDBに保存
        if request.session_id:
            await save_conversation(request.session_id, service, "user", request.user_message, user_id)
            await save_conversation(request.session_id, service, "assistant", response_text, user_id)

        return ConversationResponse(
            ai_message=response_text,
            service=service,
            timestamp=datetime.now().isoformat(),
            user_id=user_id
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
        "version": "2.1.0",
        "philosophy": "AIと人が共に成長する",
        "services": {
            "spark": "✨ 自分を知る - 対話から能力と「らしさ」を発見",
            "grow": "🌱 自然と向き合い、育てる - 野菜・子ども・自分を育てる",
            "create": "🎨 あなたのAIで創る - BYOA（Bring Your Own AI）",
        },
        "note": "このAPIはgateway経由でアクセスしてください"
    }

@app.get("/health")
async def health_check():
    """ヘルスチェック"""
    db_status = "connected" if db_pool else "disconnected"
    agent_status = "ready" if agent else "not_initialized"
    return {
        "status": "healthy",
        "database": db_status,
        "agent": agent_status,
        "timestamp": datetime.now().isoformat()
    }

# ==================== 会話エンドポイント ====================
@app.post("/internal/spark/conversation", response_model=ConversationResponse)
async def spark_conversation(request: ConversationRequest):
    """Spark - 強み発見"""
    logger.info(f"[Spark] user={request.user_id or 'anon'} message={request.user_message[:50]}...")
    return await handle_conversation("spark", request)

@app.post("/internal/grow/conversation", response_model=ConversationResponse)
async def grow_conversation(request: ConversationRequest):
    """Grow - 自然と向き合い、育てる（野菜・子ども・自分）"""
    logger.info(f"[Grow] user={request.user_id or 'anon'} message={request.user_message[:50]}...")
    return await handle_conversation("grow", request)

@app.post("/internal/create/conversation", response_model=ConversationResponse)
async def create_conversation(request: ConversationRequest):
    """Create - BYOA（Bring Your Own AI）で創る"""
    logger.info(f"[Create] user={request.user_id or 'anon'} message={request.user_message[:50]}...")
    return await handle_conversation("create", request)

@app.post("/internal/learn/conversation", response_model=ConversationResponse)
async def learn_conversation(request: ConversationRequest):
    """Learn - Createに統合（後方互換性のため維持）"""
    logger.info(f"[Learn→Create] user={request.user_id or 'anon'} message={request.user_message[:50]}...")
    return await handle_conversation("create", request)  # Createにリダイレクト

# ==================== ユーザープロファイル ====================
@app.get("/internal/user/{user_id}/profile", response_model=UserProfileResponse)
async def get_user_profile(user_id: str):
    """ユーザープロファイルを取得"""
    global agent

    try:
        summary = agent.memory.get_user_summary(user_id)
        return UserProfileResponse(
            user_id=user_id,
            age_group=summary.get("age_group"),
            conversation_count=summary.get("conversation_count", 0),
            abilities=summary.get("abilities", []),
            personalities=summary.get("personalities", []),
            interests=summary.get("interests", []),
            skills=summary.get("skills", [])
        )
    except Exception as e:
        logger.error(f"プロファイル取得エラー: {e}")
        raise HTTPException(status_code=500, detail=str(e))

# ==================== スキル ====================
@app.post("/internal/skill/generate", response_model=SkillResponse)
async def generate_skill(request: SkillGenerateRequest):
    """スキルファイルを生成"""
    global agent

    try:
        result = agent.skill_tools._handle_generate_skill(
            user_id=request.user_id,
            skill_type=request.skill_type
        )

        if result.get("status") == "insufficient_data":
            return SkillResponse(
                status="insufficient_data",
                skill_type=request.skill_type,
                message=result.get("message")
            )

        return SkillResponse(
            status="generated",
            skill_type=request.skill_type,
            content=result.get("content")
        )
    except Exception as e:
        logger.error(f"スキル生成エラー: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/internal/skill/{user_id}/{skill_type}")
async def get_skill(user_id: str, skill_type: str):
    """スキルファイルを取得"""
    global agent

    try:
        result = agent.skill_tools._handle_get_skill(
            user_id=user_id,
            skill_type=skill_type
        )
        return result
    except Exception as e:
        logger.error(f"スキル取得エラー: {e}")
        raise HTTPException(status_code=500, detail=str(e))

# ==================== 分析 ====================
@app.post("/internal/analyze", response_model=StrengthAnalysis)
async def analyze_strengths(conversation_history: list[dict]):
    """強み分析（レガシー互換）"""
    logger.info(f"[Analyze] history_len={len(conversation_history)}")

    # レガシー実装を維持（Claude Agent SDK直接使用）
    from claude_agent_sdk import query, ClaudeAgentOptions

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

@app.post("/internal/conversation/analyze")
async def analyze_conversation(
    user_id: str,
    session_id: str,
    service: str,
    conversation_history: list[dict]
):
    """会話を分析して特性を抽出・保存"""
    global agent

    try:
        result = await agent.analyze_conversation(
            user_id=user_id,
            session_id=session_id,
            service=service,
            conversation_history=conversation_history
        )
        return result
    except Exception as e:
        logger.error(f"会話分析エラー: {e}")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host=settings.host, port=settings.port)
