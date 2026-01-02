"""
AIseed Insight Tools
ユーザーの特性を記録するツール

AIが対話中に発見したユーザーの特性を記録するためのツール。
以下の3種類の特性を記録できる：
- ability: 能力（論理的思考、問題解決力、傾聴力など）
- personality: らしさ（価値観、対人スタイルなど）
- interest: 興味関心
"""
from typing import Callable
from memory.store import UserMemory


class InsightTools:
    """特性記録ツール"""

    def __init__(self, memory: UserMemory):
        self.memory = memory

    def get_tool_definitions(self) -> list[dict]:
        """Claude Agent SDKで使用するツール定義"""
        return [
            {
                "name": "record_insight",
                "description": """ユーザーの強み・特性・興味を記録する。
対話の中で気づいた特性を記録してください。

記録すべきタイミング：
- ユーザーが得意なことを話した時
- 問題解決の方法が見えた時
- 価値観が表れた時
- 興味関心が明らかになった時

注意：
- 1つの会話で複数回呼び出して良い
- 確信度は控えめに（最初は0.3-0.5）
- 同じ特性が複数回確認されたら確信度を上げる""",
                "input_schema": {
                    "type": "object",
                    "properties": {
                        "user_id": {
                            "type": "string",
                            "description": "ユーザーID"
                        },
                        "type": {
                            "type": "string",
                            "enum": ["ability", "personality", "interest"],
                            "description": "特性の種類（ability=能力, personality=らしさ, interest=興味）"
                        },
                        "content": {
                            "type": "string",
                            "description": "発見した特性の内容（例：「論理的に物事を整理する力」）"
                        },
                        "context": {
                            "type": "string",
                            "description": "発見のきっかけとなった会話の文脈（例：「チームでの役割について聞いた時、自然とまとめ役になることが多いと話していた」）"
                        },
                        "confidence": {
                            "type": "number",
                            "description": "確信度（0.0-1.0）。初回は0.3-0.5を推奨",
                            "minimum": 0.0,
                            "maximum": 1.0
                        }
                    },
                    "required": ["user_id", "type", "content", "context"]
                }
            },
            {
                "name": "get_user_profile",
                "description": """ユーザーの蓄積された情報を取得する。
会話の最初や、ユーザーの背景を確認したい時に使用。

返される情報：
- 年齢層
- 過去に発見した能力・らしさ・興味
- 会話回数
- 最近の会話履歴の要約""",
                "input_schema": {
                    "type": "object",
                    "properties": {
                        "user_id": {
                            "type": "string",
                            "description": "ユーザーID"
                        }
                    },
                    "required": ["user_id"]
                }
            },
            {
                "name": "update_age_group",
                "description": """ユーザーの年齢層を更新する。
会話の中で年齢層が判明した時に呼び出す。

年齢層の判断基準：
- child: 小学生以下
- teen: 中高生
- adult: 大学生・社会人
- parent: 子育て中の親""",
                "input_schema": {
                    "type": "object",
                    "properties": {
                        "user_id": {
                            "type": "string",
                            "description": "ユーザーID"
                        },
                        "age_group": {
                            "type": "string",
                            "enum": ["child", "teen", "adult", "parent"],
                            "description": "年齢層"
                        }
                    },
                    "required": ["user_id", "age_group"]
                }
            }
        ]

    def get_handlers(self) -> dict[str, Callable]:
        """ツールハンドラーを返す"""
        return {
            "record_insight": self._handle_record_insight,
            "get_user_profile": self._handle_get_user_profile,
            "update_age_group": self._handle_update_age_group,
        }

    def _handle_record_insight(
        self,
        user_id: str,
        type: str,
        content: str,
        context: str,
        confidence: float = 0.5
    ) -> dict:
        """特性を記録"""
        insight = self.memory.add_insight(
            user_id=user_id,
            type=type,
            content=content,
            context=context,
            confidence=confidence
        )
        return {
            "status": "recorded",
            "insight": {
                "type": insight.type,
                "content": insight.content,
                "confidence": insight.confidence,
                "discovered_at": insight.discovered_at
            }
        }

    def _handle_get_user_profile(self, user_id: str) -> dict:
        """プロファイルを取得"""
        return self.memory.get_user_summary(user_id)

    def _handle_update_age_group(self, user_id: str, age_group: str) -> dict:
        """年齢層を更新"""
        self.memory.update_age_group(user_id, age_group)
        return {"status": "updated", "age_group": age_group}
