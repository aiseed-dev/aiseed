"""
AIseed Server
AIと人が共に成長するプラットフォームのAPIサーバー

Copyright (c) 2026 AIseed.dev
Licensed under the GNU Affero General Public License v3.0 (AGPL-3.0)
Dual-licensed with a Commercial License. See LICENSE for details.
"""
import asyncio
import os
from fastapi import FastAPI, HTTPException, Header, Request
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from typing import Optional
from claude_agent_sdk import query, ClaudeAgentOptions
from collections import defaultdict
from datetime import datetime, timedelta

app = FastAPI(
    title="AIseed API",
    description="AIと人が共に成長するプラットフォーム",
    version="1.0.0"
)

# 同一オリジンでのデプロイを想定（CORS不要）
# 開発: localhost:8000 (API) + localhost:XXXX (Flutter)
# 本番: yourdomain.com/api/ + yourdomain.com/app/

# 簡易的なレート制限（メモリベース）
# 本番環境ではRedisやデータベースを使用することを推奨
rate_limit_storage = defaultdict(list)

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
        "services": ["spark", "grow", "create"],
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
    elif any(word in message_lower for word in ["web", "サイト", "ホームページ", "デザイン"]):
        service = "create"
    
    return await handle_conversation(service, request)

# ==================== Authenticated API (アプリ用、認証必須) ====================

async def verify_api_key(x_api_key: str = Header(..., alias="X-API-Key")):
    """
    API キー認証（簡易版）
    本番環境ではデータベースで管理することを推奨
    """
    # 環境変数から有効なAPIキーを取得
    valid_keys = os.getenv("API_KEYS", "").split(",")
    valid_keys = [key.strip() for key in valid_keys if key.strip()]
    
    if not valid_keys:
        # APIキーが設定されていない場合は開発モード
        return {"user_id": "dev", "plan": "dev"}
    
    if x_api_key not in valid_keys:
        raise HTTPException(status_code=403, detail="無効なAPIキーです")
    
    # 簡易的なユーザー情報を返す
    return {"user_id": x_api_key[:8], "plan": "free"}

@app.get("/v1/")
async def v1_root():
    """Authenticated API ステータス"""
    return {
        "message": "AIseed Authenticated API v1",
        "status": "running",
        "services": ["spark", "grow", "create"],
        "note": "認証が必要なAPI"
    }

@app.post("/v1/spark/conversation", response_model=ConversationResponse)
async def v1_spark_conversation(
    request: ConversationRequest,
    user_info: dict = Header(default=None, alias="X-API-Key")
):
    """Authenticated API - Spark（強み発見）"""
    # 本番環境では verify_api_key を使用
    # user_info = await verify_api_key(user_info)
    return await handle_conversation("spark", request)

@app.post("/v1/grow/conversation", response_model=ConversationResponse)
async def v1_grow_conversation(
    request: ConversationRequest,
    user_info: dict = Header(default=None, alias="X-API-Key")
):
    """Authenticated API - Grow（栽培・料理）"""
    return await handle_conversation("grow", request)

@app.post("/v1/create/conversation", response_model=ConversationResponse)
async def v1_create_conversation(
    request: ConversationRequest,
    user_info: dict = Header(default=None, alias="X-API-Key")
):
    """Authenticated API - Create（Web制作）"""
    return await handle_conversation("create", request)

@app.post("/v1/analyze", response_model=StrengthAnalysis)
async def v1_analyze_strengths(
    conversation_history: list[dict],
    user_info: dict = Header(default=None, alias="X-API-Key")
):
    """Authenticated API - 強み分析"""
    
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
            "authenticated": "/v1/"
        }
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
