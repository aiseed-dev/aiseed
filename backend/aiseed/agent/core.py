"""
AIseed Agent Core
Claude Agent SDKを使用したエージェントの実装

注意: Claude Agent SDKの実際のAPIは異なる可能性があります。
サーバー設定後に調整が必要です。
"""
import logging
from typing import Optional, AsyncIterator
from claude_agent_sdk import query, ClaudeAgentOptions

from .prompts import get_prompt
from .tools import InsightTools, SkillTools, HistoryTools
from memory.store import UserMemory
from config import get_model_id, get_model_info

logger = logging.getLogger("aiseed.agent")


class AIseedAgent:
    """AIseedのAIエージェント"""

    def __init__(self, memory_base_path: str = "user_memory"):
        self.memory = UserMemory(base_path=memory_base_path)

        # ツールの初期化
        self.insight_tools = InsightTools(self.memory)
        self.skill_tools = SkillTools(self.memory)
        self.history_tools = HistoryTools(self.memory)

    def _get_all_tool_definitions(self) -> list[dict]:
        """全ツール定義を取得"""
        tools = []
        tools.extend(self.insight_tools.get_tool_definitions())
        tools.extend(self.skill_tools.get_tool_definitions())
        tools.extend(self.history_tools.get_tool_definitions())
        return tools

    def _get_tool_handler(self, tool_name: str):
        """ツール名からハンドラーを取得"""
        handlers = {}
        handlers.update(self.insight_tools.get_handlers())
        handlers.update(self.skill_tools.get_handlers())
        handlers.update(self.history_tools.get_handlers())
        return handlers.get(tool_name)

    def _execute_tool(self, tool_name: str, arguments: dict) -> dict:
        """ツールを実行"""
        handler = self._get_tool_handler(tool_name)
        if handler:
            try:
                return handler(**arguments)
            except Exception as e:
                logger.error(f"Tool execution error: {tool_name} - {e}")
                return {"error": str(e)}
        return {"error": f"Unknown tool: {tool_name}"}

    async def chat(
        self,
        service: str,
        user_message: str,
        user_id: str,
        session_id: Optional[str] = None,
        conversation_history: list[dict] = None,
        task_name: Optional[str] = None
    ) -> str:
        """
        会話を処理してレスポンスを返す

        Args:
            service: サービス名（spark, grow, create）
            user_message: ユーザーのメッセージ
            user_id: ユーザーID
            session_id: セッションID
            conversation_history: 会話履歴
            task_name: 処理名（モデル選択用、未指定時は{service}_conversation）

        注意: Claude Agent SDKの実際のAPIに合わせて調整が必要です。
        """
        conversation_history = conversation_history or []

        # 処理名からモデルを決定
        task_name = task_name or f"{service}_conversation"
        model_info = get_model_info(task_name)
        model_id = model_info["model_id"]
        logger.info(f"[{task_name}] Using model: {model_info['model_key']} ({model_id})")

        # 会話履歴を文字列に変換
        history_text = ""
        for msg in conversation_history:
            role = "ユーザー" if msg.get("role") == "user" else "AI"
            history_text += f"{role}: {msg.get('content', '')}\n"

        # プロンプトを構築
        system_prompt = get_prompt(service)

        # ユーザープロファイルを取得（contextに含める）
        user_summary = self.memory.get_user_summary(user_id)
        context_info = f"""
## ユーザー情報
- ユーザーID: {user_id}
- セッションID: {session_id or 'なし'}
- 年齢層: {user_summary.get('age_group') or '未確認'}
- 会話回数: {user_summary.get('conversation_count', 0)}

## 発見済みの特性
- 能力: {', '.join([a['content'] for a in user_summary.get('abilities', [])]) or 'なし'}
- らしさ: {', '.join([p['content'] for p in user_summary.get('personalities', [])]) or 'なし'}
- 興味: {', '.join([i['content'] for i in user_summary.get('interests', [])]) or 'なし'}
"""

        full_prompt = f"""
{system_prompt}

{context_info}

【これまでの会話】
{history_text}

【ユーザーの最新メッセージ】
{user_message}

自然に会話を続けてください。
必要に応じてツールを使用して特性を記録してください。
"""

        try:
            # Claude Agent SDKを使用
            # 注意: 実際のAPIに合わせて調整が必要
            options = ClaudeAgentOptions(
                model=model_id,  # 設定から取得したモデル
                system_prompt="あなたはaiseedのAIパートナーです。",
                # tools=self._get_all_tool_definitions()  # ツール定義（SDK対応時に有効化）
            )

            response_text = ""
            async for message in query(prompt=full_prompt, options=options):
                if hasattr(message, 'content'):
                    for block in message.content:
                        if hasattr(block, 'text'):
                            response_text += block.text
                        # ツール呼び出しの処理（SDK対応時に有効化）
                        # elif hasattr(block, 'tool_use'):
                        #     tool_result = self._execute_tool(
                        #         block.tool_use.name,
                        #         block.tool_use.input
                        #     )
                        #     # ツール結果を処理...

            return response_text.strip()

        except Exception as e:
            logger.error(f"Agent chat error: {e}")
            raise

    async def analyze_conversation(
        self,
        user_id: str,
        session_id: str,
        service: str,
        conversation_history: list[dict]
    ) -> dict:
        """
        会話を分析して特性を抽出

        会話終了時に呼び出して、発見した特性を記録する
        """
        # モデルを取得（heavy処理）
        model_info = get_model_info("analyze_conversation")
        model_id = model_info["model_id"]
        logger.info(f"[analyze_conversation] Using model: {model_info['model_key']} ({model_id})")

        history_text = "\n".join([
            f"{'ユーザー' if msg.get('role') == 'user' else 'AI'}: {msg.get('content', '')}"
            for msg in conversation_history
        ])

        prompt = f"""
以下の会話を分析して、ユーザーの特性を抽出してください。

【会話】
{history_text}

JSON形式で出力してください：
{{
    "age_group": "child/teen/adult/parent/null",
    "abilities": [
        {{"content": "能力の説明", "context": "発見のきっかけ", "confidence": 0.5}}
    ],
    "personalities": [
        {{"content": "らしさの説明", "context": "発見のきっかけ", "confidence": 0.5}}
    ],
    "interests": [
        {{"content": "興味の内容", "context": "発見のきっかけ", "confidence": 0.5}}
    ],
    "summary": "会話の要約（1-2文）",
    "key_discoveries": ["発見1", "発見2"]
}}
"""

        try:
            options = ClaudeAgentOptions(model=model_id)

            response_text = ""
            async for message in query(prompt=prompt, options=options):
                if hasattr(message, 'content'):
                    for block in message.content:
                        if hasattr(block, 'text'):
                            response_text += block.text

            # JSONをパース
            import json
            import re

            json_match = re.search(r'\{.*\}', response_text, re.DOTALL)
            if json_match:
                result = json.loads(json_match.group())

                # 年齢層を更新
                if result.get("age_group"):
                    self.memory.update_age_group(user_id, result["age_group"])

                # 特性を記録
                for ability in result.get("abilities", []):
                    self.memory.add_insight(
                        user_id=user_id,
                        type="ability",
                        content=ability["content"],
                        context=ability.get("context", "会話分析"),
                        confidence=ability.get("confidence", 0.5)
                    )

                for personality in result.get("personalities", []):
                    self.memory.add_insight(
                        user_id=user_id,
                        type="personality",
                        content=personality["content"],
                        context=personality.get("context", "会話分析"),
                        confidence=personality.get("confidence", 0.5)
                    )

                for interest in result.get("interests", []):
                    self.memory.add_insight(
                        user_id=user_id,
                        type="interest",
                        content=interest["content"],
                        context=interest.get("context", "会話分析"),
                        confidence=interest.get("confidence", 0.5)
                    )

                # 履歴を保存
                self.memory.add_history(
                    user_id=user_id,
                    session_id=session_id,
                    service=service,
                    summary=result.get("summary", ""),
                    key_discoveries=result.get("key_discoveries", [])
                )

                return result

            return {"error": "Failed to parse analysis result"}

        except Exception as e:
            logger.error(f"Analyze conversation error: {e}")
            return {"error": str(e)}
