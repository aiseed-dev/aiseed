"""
AIseed Skill Tools
ユーザー専用スキルファイルを生成するツール

スキルファイルはMarkdown形式で、ユーザーの特性を基に生成される。
生成されたスキルファイルは、Claude、ChatGPT、その他のLLMで使用可能。
"""
from typing import Callable, Optional
from datetime import datetime
from memory.store import UserMemory


class SkillTools:
    """スキル生成ツール"""

    def __init__(self, memory: UserMemory):
        self.memory = memory

    def get_tool_definitions(self) -> list[dict]:
        """Claude Agent SDKで使用するツール定義"""
        return [
            {
                "name": "generate_skill",
                "description": """ユーザー専用のスキルファイル（SKILL.md）を生成する。
蓄積された特性情報を基に、ユーザーに合ったスキルを作成。

生成タイミング：
- ユーザーが「スキルを作って」と依頼した時
- 十分な情報（能力3つ以上、らしさ2つ以上）が溜まった時

スキルタイプ：
- spark: 強み発見の結果をまとめたスキル
- grow: 栽培に関するパーソナライズされたスキル
- create: Web制作の好みをまとめたスキル
- learn: 学習スタイルをまとめたスキル""",
                "input_schema": {
                    "type": "object",
                    "properties": {
                        "user_id": {
                            "type": "string",
                            "description": "ユーザーID"
                        },
                        "skill_type": {
                            "type": "string",
                            "enum": ["spark", "grow", "create", "learn"],
                            "description": "生成するスキルの種類"
                        }
                    },
                    "required": ["user_id", "skill_type"]
                }
            },
            {
                "name": "get_skill",
                "description": """既存のスキルファイルを取得する。
ユーザーがスキルを確認したい時や、更新の参考にする時に使用。""",
                "input_schema": {
                    "type": "object",
                    "properties": {
                        "user_id": {
                            "type": "string",
                            "description": "ユーザーID"
                        },
                        "skill_type": {
                            "type": "string",
                            "enum": ["spark", "grow", "create", "learn"],
                            "description": "取得するスキルの種類"
                        }
                    },
                    "required": ["user_id", "skill_type"]
                }
            },
            {
                "name": "list_skills",
                "description": """ユーザーの持っているスキル一覧を取得する。""",
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
            }
        ]

    def get_handlers(self) -> dict[str, Callable]:
        """ツールハンドラーを返す"""
        return {
            "generate_skill": self._handle_generate_skill,
            "get_skill": self._handle_get_skill,
            "list_skills": self._handle_list_skills,
        }

    def _generate_spark_skill(self, user_id: str) -> str:
        """Sparkスキルを生成"""
        summary = self.memory.get_user_summary(user_id)
        abilities = summary.get("abilities", [])
        personalities = summary.get("personalities", [])
        interests = summary.get("interests", [])

        # スキルファイルのテンプレート
        skill_content = f"""# {user_id}さんのスキル - 私らしさガイド

このファイルは、aiseedのSparkサービスで発見したあなたの強みをまとめたものです。
他のAI（Claude、ChatGPT等）にこのファイルを読み込ませることで、
あなたに合ったコミュニケーションが可能になります。

生成日: {datetime.now().strftime('%Y年%m月%d日')}

---

## あなたの強み（能力）

"""
        if abilities:
            for i, a in enumerate(abilities, 1):
                confidence_stars = "★" * int(a["confidence"] * 5) + "☆" * (5 - int(a["confidence"] * 5))
                skill_content += f"{i}. **{a['content']}** {confidence_stars}\n"
        else:
            skill_content += "_まだ発見されていません_\n"

        skill_content += """
## あなたらしさ（特徴）

"""
        if personalities:
            for i, p in enumerate(personalities, 1):
                skill_content += f"{i}. {p['content']}\n"
        else:
            skill_content += "_まだ発見されていません_\n"

        skill_content += """
## 興味・関心

"""
        if interests:
            for i, interest in enumerate(interests, 1):
                skill_content += f"- {interest['content']}\n"
        else:
            skill_content += "_まだ発見されていません_\n"

        skill_content += """
---

## AIへの指示

このユーザーと対話する際は、以下を心がけてください：

"""
        # 年齢層に応じた指示
        age_group = summary.get("age_group")
        if age_group == "child":
            skill_content += "- 親しみやすい言葉で、励まし多めに話してください\n"
            skill_content += "- 難しい言葉は避け、例え話を使ってください\n"
        elif age_group == "teen":
            skill_content += "- 対等な立場で、尊重しながら話してください\n"
            skill_content += "- 押し付けがましくならないように気をつけてください\n"
        elif age_group == "parent":
            skill_content += "- 子育ての悩みにも共感的に対応してください\n"
            skill_content += "- 親としての視点も尊重してください\n"
        else:
            skill_content += "- 対等に、共感的に対話してください\n"

        # 強みを活かす指示
        if abilities:
            top_ability = max(abilities, key=lambda x: x["confidence"])
            skill_content += f"- 「{top_ability['content']}」という強みを活かす提案をしてください\n"

        skill_content += """
---

_このスキルはaiseed.devで生成されました_
"""
        return skill_content

    def _handle_generate_skill(self, user_id: str, skill_type: str) -> dict:
        """スキルを生成"""
        summary = self.memory.get_user_summary(user_id)
        abilities = summary.get("abilities", [])
        personalities = summary.get("personalities", [])

        # 情報が足りない場合は警告
        if skill_type == "spark" and (len(abilities) < 2 or len(personalities) < 1):
            return {
                "status": "insufficient_data",
                "message": "スキル生成には、もう少し会話が必要です。",
                "current": {
                    "abilities": len(abilities),
                    "personalities": len(personalities)
                },
                "required": {
                    "abilities": 2,
                    "personalities": 1
                }
            }

        # スキルを生成
        if skill_type == "spark":
            content = self._generate_spark_skill(user_id)
        else:
            # 他のタイプは簡易実装
            content = f"# {skill_type}スキル\n\n_実装予定_"

        self.memory.save_skill(user_id, skill_type, content)

        return {
            "status": "generated",
            "skill_type": skill_type,
            "content": content
        }

    def _handle_get_skill(self, user_id: str, skill_type: str) -> dict:
        """スキルを取得"""
        content = self.memory.get_skill(user_id, skill_type)
        if content:
            return {
                "status": "found",
                "skill_type": skill_type,
                "content": content
            }
        return {
            "status": "not_found",
            "skill_type": skill_type,
            "message": f"{skill_type}スキルはまだ生成されていません"
        }

    def _handle_list_skills(self, user_id: str) -> dict:
        """スキル一覧を取得"""
        skills = self.memory.list_skills(user_id)
        return {
            "skills": skills,
            "count": len(skills)
        }
