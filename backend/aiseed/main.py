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
from agent.tools.experience import SparkExperience, TaskResult, TASKS, TASK_ORDER
from memory.store import UserMemory
from config import get_model_id, get_model_info, setup_logging, get_logger, SERVER, MEMORY
from shipment import ShipmentService
from shipment.models import (
    ShipmentInfo, ShipmentItem, Subscriber,
    ShipmentPostRequest, ShipmentPostStructuredRequest,
    SubscribeRequest, NotificationResult
)
from shipment.parser import ShipmentParser, parse_with_ai
from community import CommunityService
from community.models import (
    Favorite, CheckIn, NotificationSettings,
    FavoriteRequest, CheckInRequest, NotificationSettingsRequest
)

# ==================== 設定 ====================
class Settings(BaseSettings):
    # Database（秘匿情報は.envから）
    database_url: str = "postgresql://aiseed:aiseed@localhost:5432/aiseed"

    # Server（settings.pyからデフォルト値）
    host: str = SERVER["host"]
    port: int = SERVER["port"]

    # Memory（settings.pyからデフォルト値）
    memory_base_path: str = MEMORY["base_path"]

    class Config:
        env_file = ".env"
        extra = "ignore"

settings = Settings()

# ==================== ログ設定 ====================
setup_logging()
logger = get_logger("aiseed.api")

# ==================== グローバル ====================
db_pool: Optional[asyncpg.Pool] = None
agent: Optional[AIseedAgent] = None
spark_experience: Optional[SparkExperience] = None
shipment_service: Optional[ShipmentService] = None
community_service: Optional[CommunityService] = None

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
    global agent, spark_experience, shipment_service, community_service

    await init_db()

    # エージェントの初期化
    agent = AIseedAgent(memory_base_path=settings.memory_base_path)
    logger.info(f"AIseed Agent 初期化完了 (memory: {settings.memory_base_path})")

    # 体験タスクの初期化
    spark_experience = SparkExperience(memory=agent.memory)
    logger.info("Spark Experience 初期化完了")

    # 出荷情報サービスの初期化
    shipment_service = ShipmentService(base_path="shipment_data")
    logger.info("Shipment Service 初期化完了")

    # コミュニティサービスの初期化
    community_service = CommunityService(base_path="community_data")
    logger.info("Community Service 初期化完了")

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
# [AI-USAGE: HIGH] この関数はAIを使用します
# 公開版では BYOA または テンプレート に置き換えてください
# 詳細: docs/FORKING.md
async def handle_conversation(service: str, request: ConversationRequest) -> ConversationResponse:
    """会話処理（エージェントを使用）"""
    global agent

    # ユーザーIDの決定（未指定の場合はセッションIDを使用）
    user_id = request.user_id or request.session_id or "anonymous"

    try:
        # [AI-CALL] エージェントで会話を処理
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
        "version": "2.2.0",
        "philosophy": "AIと人が共に成長する",
        "services": {
            "spark": {
                "description": "✨ 自分を知る",
                "modes": {
                    "conversation": "💬 おしゃべりで発見",
                    "experience": "🎮 体験で発見（NEW）"
                }
            },
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
    """Spark - 強み発見（おしゃべりモード）"""
    logger.info(f"[Spark/Chat] user={request.user_id or 'anon'} message={request.user_message[:50]}...")
    return await handle_conversation("spark", request)


# ==================== Spark体験タスク ====================
class ExperienceStartRequest(BaseModel):
    user_id: str
    session_id: Optional[str] = None


class ExperienceResultRequest(BaseModel):
    task_id: str
    user_id: str
    session_id: str
    tap_position: Optional[dict] = None
    selected_option: Optional[str] = None
    other_text: Optional[str] = None
    arranged_positions: Optional[list] = None
    tap_sequence: Optional[list] = None
    selected_color: Optional[str] = None
    duration_ms: int
    hesitation_count: int = 0


@app.post("/internal/spark/experience/start")
async def start_spark_experience(request: ExperienceStartRequest):
    """Spark体験タスクを開始"""
    global spark_experience

    import uuid
    session_id = request.session_id or f"exp_{uuid.uuid4().hex[:12]}"

    logger.info(f"[Spark/Experience] START user={request.user_id} session={session_id}")

    result = spark_experience.start_session(
        user_id=request.user_id,
        session_id=session_id
    )
    return result


@app.get("/internal/spark/experience/tasks")
async def get_experience_tasks():
    """利用可能なタスク一覧を取得"""
    return {
        "tasks": [
            {
                "id": task_id,
                "name": TASKS[task_id]["name"],
                "type": TASKS[task_id]["type"],
            }
            for task_id in TASK_ORDER
        ],
        "total": len(TASK_ORDER)
    }


@app.get("/internal/spark/experience/task/{task_id}")
async def get_experience_task(task_id: str):
    """特定のタスク情報を取得"""
    global spark_experience
    return spark_experience.get_task(task_id)


@app.post("/internal/spark/experience/submit")
async def submit_experience_result(request: ExperienceResultRequest):
    """タスク結果を送信"""
    global spark_experience

    logger.info(f"[Spark/Experience] SUBMIT task={request.task_id} user={request.user_id}")

    result = TaskResult(
        task_id=request.task_id,
        user_id=request.user_id,
        session_id=request.session_id,
        tap_position=request.tap_position,
        selected_option=request.selected_option,
        other_text=request.other_text,
        arranged_positions=request.arranged_positions,
        tap_sequence=request.tap_sequence,
        selected_color=request.selected_color,
        duration_ms=request.duration_ms,
        hesitation_count=request.hesitation_count,
    )

    return spark_experience.submit_result(result)

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
# [AI-USAGE: HIGH] この関数はAIを使用します
# 公開版では ルールベース に置き換えてください
# 詳細: docs/FORKING.md
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
        # モデルを取得（heavy処理）
        model_info = get_model_info("analyze_strengths")
        model_id = model_info["model_id"]
        logger.info(f"[Analyze] Using model: {model_info['model_key']} ({model_id})")

        options = ClaudeAgentOptions(model=model_id)

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

# [AI-USAGE: HIGH] この関数はAIを使用します
# 公開版では ルールベース に置き換えてください
# 詳細: docs/FORKING.md
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
        # [AI-CALL] 会話分析
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

# ==================== 出荷情報 ====================
# [AI-USAGE: MEDIUM] ルールベースで解析失敗時のみAIを使用
# 公開版では 構造化入力のみ に限定してください
# 詳細: docs/FORKING.md
@app.post("/internal/shipment/post")
async def post_shipment_natural(request: ShipmentPostRequest):
    """
    出荷情報を自然言語で投稿

    例: "今日10時に道の駅ひまわりにトマト100円とナス150円出します"
    """
    global shipment_service, agent

    logger.info(f"[Shipment] POST natural: farmer={request.farmer_id} msg={request.message[:50]}...")

    # パーサーで解析（ルールベース - AI不使用）
    parser = ShipmentParser()
    shipment = parser.parse(request.farmer_id, request.message)

    if not shipment:
        # [AI-CALL] ルールベースで失敗した場合のみAIで再解析
        # 公開版ではこのブロックを削除し、エラーを返す
        async def ai_query(prompt):
            response = await agent.chat(
                service="create",
                user_message=prompt,
                user_id=request.farmer_id,
                task_name="parse_shipment"
            )
            return response

        shipment = await parse_with_ai(request.farmer_id, request.message, ai_query)

    if not shipment:
        raise HTTPException(
            status_code=400,
            detail="出荷情報を解析できませんでした。もう少し具体的に入力してください。"
        )

    # 保存
    saved = shipment_service.post_shipment(shipment)

    # 購読者に通知
    notify_result = await shipment_service.notify_subscribers(request.farmer_id, saved)

    return {
        "status": "posted",
        "shipment": saved.model_dump(),
        "notification": notify_result.model_dump()
    }


@app.post("/internal/shipment/post/structured")
async def post_shipment_structured(request: ShipmentPostStructuredRequest):
    """出荷情報を構造化データで投稿"""
    global shipment_service

    logger.info(f"[Shipment] POST structured: farmer={request.farmer_id}")

    shipment = ShipmentInfo(
        farmer_id=request.farmer_id,
        date=request.date,
        time=request.time,
        location_name=request.location_name,
        location_address=request.location_address,
        items=request.items,
        note=request.note,
    )

    saved = shipment_service.post_shipment(shipment)
    notify_result = await shipment_service.notify_subscribers(request.farmer_id, saved)

    return {
        "status": "posted",
        "shipment": saved.model_dump(),
        "notification": notify_result.model_dump()
    }


@app.get("/internal/shipment/{farmer_id}/latest")
async def get_latest_shipment(farmer_id: str):
    """最新の出荷情報を取得"""
    global shipment_service

    shipment = shipment_service.get_latest_shipment(farmer_id)
    if not shipment:
        return {"status": "not_found", "shipment": None}

    return {"status": "ok", "shipment": shipment.model_dump()}


@app.get("/internal/shipment/{farmer_id}/today")
async def get_today_shipments(farmer_id: str):
    """今日の出荷情報を取得"""
    global shipment_service

    shipments = shipment_service.get_today_shipments(farmer_id)
    return {
        "status": "ok",
        "date": datetime.now().strftime("%Y-%m-%d"),
        "shipments": [s.model_dump() for s in shipments]
    }


@app.get("/internal/shipment/{farmer_id}/history")
async def get_shipment_history(farmer_id: str, limit: int = 10, offset: int = 0):
    """出荷情報の履歴を取得"""
    global shipment_service

    shipments = shipment_service.get_shipments(farmer_id, limit=limit, offset=offset)
    return {
        "status": "ok",
        "shipments": [s.model_dump() for s in shipments],
        "count": len(shipments)
    }


@app.get("/internal/shipment/{farmer_id}/page")
async def get_shipment_page(farmer_id: str, farmer_name: str = ""):
    """出荷情報ページのHTMLを取得"""
    global shipment_service

    html = shipment_service.generate_shipment_html(farmer_id, farmer_name)
    from fastapi.responses import HTMLResponse
    return HTMLResponse(content=html)


# ==================== 購読 ====================
@app.post("/internal/subscribe")
async def subscribe(request: SubscribeRequest):
    """出荷情報の購読登録"""
    global shipment_service

    logger.info(f"[Subscribe] farmer={request.farmer_id} email={request.email}")

    subscriber = Subscriber(
        farmer_id=request.farmer_id,
        email=request.email,
        push_subscription=request.push_subscription,
    )

    saved = shipment_service.subscribe(subscriber)
    return {"status": "subscribed", "subscriber_id": saved.id}


@app.delete("/internal/subscribe")
async def unsubscribe(farmer_id: str, email: str):
    """購読解除"""
    global shipment_service

    logger.info(f"[Unsubscribe] farmer={farmer_id} email={email}")

    success = shipment_service.unsubscribe(farmer_id, email)
    if success:
        return {"status": "unsubscribed"}
    return {"status": "not_found"}


@app.get("/internal/subscribe/{farmer_id}/count")
async def get_subscriber_count(farmer_id: str):
    """購読者数を取得"""
    global shipment_service

    subscribers = shipment_service.get_subscribers(farmer_id)
    return {"count": len(subscribers)}


# ==================== コミュニティ ====================
@app.post("/internal/favorite")
async def add_favorite(request: FavoriteRequest):
    """お気に入り（フォロー）を追加"""
    global community_service

    logger.info(f"[Community] FAVORITE user={request.user_id} farmer={request.farmer_id}")

    favorite = community_service.add_favorite(
        user_id=request.user_id,
        farmer_id=request.farmer_id
    )

    return {
        "status": "added",
        "favorite": favorite.model_dump()
    }


@app.delete("/internal/favorite")
async def remove_favorite(user_id: str, farmer_id: str):
    """お気に入り（フォロー）を解除"""
    global community_service

    logger.info(f"[Community] UNFAVORITE user={user_id} farmer={farmer_id}")

    success = community_service.remove_favorite(user_id, farmer_id)
    if success:
        return {"status": "removed"}
    return {"status": "not_found"}


@app.get("/internal/favorite/{user_id}")
async def get_favorites(user_id: str):
    """ユーザーのお気に入りリストを取得"""
    global community_service

    favorites = community_service.get_user_favorites(user_id)
    return {
        "status": "ok",
        "favorites": [f.model_dump() for f in favorites]
    }


@app.get("/internal/favorite/{farmer_id}/followers")
async def get_farmer_followers(farmer_id: str):
    """農家のフォロワーリストを取得"""
    global community_service

    followers = community_service.get_farmer_followers(farmer_id)
    return {
        "status": "ok",
        "followers": [f.model_dump() for f in followers],
        "count": len(followers)
    }


@app.post("/internal/checkin")
async def check_in(request: CheckInRequest):
    """来店記録（QRスキャン）"""
    global community_service

    logger.info(f"[Community] CHECKIN user={request.user_id} farmer={request.farmer_id}")

    checkin = community_service.check_in(
        user_id=request.user_id,
        farmer_id=request.farmer_id,
        location_name=request.location_name
    )

    return {
        "status": "checked_in",
        "checkin": checkin.model_dump(),
        "message": f"ご来店ありがとうございます！"
    }


@app.get("/internal/checkin/{user_id}/history")
async def get_checkin_history(user_id: str, limit: int = 20):
    """来店履歴を取得"""
    global community_service

    checkins = community_service.get_user_checkins(user_id, limit=limit)
    return {
        "status": "ok",
        "checkins": [c.model_dump() for c in checkins],
        "count": len(checkins)
    }


@app.get("/internal/farmer/{farmer_id}/stats")
async def get_farmer_stats(farmer_id: str):
    """農家の統計情報を取得"""
    global community_service

    stats = community_service.get_farmer_stats(farmer_id)
    return {
        "status": "ok",
        "stats": stats.model_dump()
    }


@app.post("/internal/notification/settings")
async def update_notification_settings(request: NotificationSettingsRequest):
    """通知設定を更新"""
    global community_service

    logger.info(f"[Community] NOTIFICATION_SETTINGS user={request.user_id}")

    settings = community_service.update_notification_settings(
        user_id=request.user_id,
        email_enabled=request.email_enabled,
        push_enabled=request.push_enabled,
        email=request.email,
        push_subscription=request.push_subscription
    )

    return {
        "status": "updated",
        "settings": settings.model_dump()
    }


@app.get("/internal/notification/settings/{user_id}")
async def get_notification_settings(user_id: str):
    """通知設定を取得"""
    global community_service

    settings = community_service.get_notification_settings(user_id)
    if not settings:
        return {"status": "not_found", "settings": None}

    return {
        "status": "ok",
        "settings": settings.model_dump()
    }


@app.get("/internal/checkin/{farmer_id}/page")
async def get_checkin_page(farmer_id: str, farmer_name: str = ""):
    """来店記録用のQRスキャンページを取得"""
    global community_service

    html = community_service.generate_checkin_page(farmer_id, farmer_name)
    from fastapi.responses import HTMLResponse
    return HTMLResponse(content=html)


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host=settings.host, port=settings.port)
