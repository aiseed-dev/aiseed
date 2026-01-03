"""
AIseed History Tools
会話履歴を管理するツール
"""
from typing import Callable
from memory.store import UserMemory


class HistoryTools:
    """履歴管理ツール"""

    def __init__(self, memory: UserMemory):
        self.memory = memory

    def get_tool_definitions(self) -> list[dict]:
        """Claude Agent SDKで使用するツール定義"""
        return [
            {
                "name": "get_history",
                "description": """過去の会話履歴（要約）を取得する。
ユーザーとの過去のやり取りを確認したい時に使用。

返される情報：
- セッションID
- サービス種別
- 会話の要約
- 発見した内容
- 日時""",
                "input_schema": {
                    "type": "object",
                    "properties": {
                        "user_id": {
                            "type": "string",
                            "description": "ユーザーID"
                        },
                        "limit": {
                            "type": "integer",
                            "description": "取得件数（デフォルト: 10）",
                            "minimum": 1,
                            "maximum": 50
                        }
                    },
                    "required": ["user_id"]
                }
            },
            {
                "name": "save_conversation_summary",
                "description": """会話の要約を保存する。
会話が終了する際、または区切りの良いタイミングで呼び出す。

要約に含めるべき内容：
- 話した主なトピック
- 発見した特性
- ユーザーの反応・感情""",
                "input_schema": {
                    "type": "object",
                    "properties": {
                        "user_id": {
                            "type": "string",
                            "description": "ユーザーID"
                        },
                        "session_id": {
                            "type": "string",
                            "description": "セッションID"
                        },
                        "service": {
                            "type": "string",
                            "enum": ["spark", "grow", "create", "learn"],
                            "description": "サービス種別"
                        },
                        "summary": {
                            "type": "string",
                            "description": "会話の要約（1-2文）"
                        },
                        "key_discoveries": {
                            "type": "array",
                            "items": {"type": "string"},
                            "description": "発見した重要なこと（箇条書き）"
                        }
                    },
                    "required": ["user_id", "session_id", "service", "summary"]
                }
            }
        ]

    def get_handlers(self) -> dict[str, Callable]:
        """ツールハンドラーを返す"""
        return {
            "get_history": self._handle_get_history,
            "save_conversation_summary": self._handle_save_summary,
        }

    def _handle_get_history(self, user_id: str, limit: int = 10) -> dict:
        """履歴を取得"""
        history = self.memory.get_history(user_id)
        recent = history[-limit:] if len(history) > limit else history

        return {
            "total": len(history),
            "returned": len(recent),
            "history": [
                {
                    "session_id": h.session_id,
                    "service": h.service,
                    "summary": h.summary,
                    "key_discoveries": h.key_discoveries,
                    "created_at": h.created_at
                }
                for h in recent
            ]
        }

    def _handle_save_summary(
        self,
        user_id: str,
        session_id: str,
        service: str,
        summary: str,
        key_discoveries: list[str] = None
    ) -> dict:
        """要約を保存"""
        self.memory.add_history(
            user_id=user_id,
            session_id=session_id,
            service=service,
            summary=summary,
            key_discoveries=key_discoveries
        )
        self.memory.increment_conversation_count(user_id)

        return {
            "status": "saved",
            "session_id": session_id,
            "service": service
        }
