"""
AIseed Skill Tools
ユーザー専用スキルファイルを生成するツール

BYOA（Bring Your Own AI）の考え方：
スキルファイルはMarkdown形式で、ユーザーの特性を基に生成される。
生成されたスキルファイルは、Claude、ChatGPT、Gemini、その他のLLMで使用可能。
AIが変わっても、「あなたらしさ」は引き継がれる。
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

【BYOA - Bring Your Own AI】
生成されたスキルファイルは、どのAIでも使える。
Claude、ChatGPT、Gemini...あなた専用のパートナーに。

生成タイミング：
- ユーザーが「スキルを作って」と依頼した時
- 十分な情報（能力2つ以上、らしさ1つ以上）が溜まった時

スキルタイプ：
- spark: 強み発見の結果をまとめたスキル（メイン）
- grow: 栽培・育児に関するパーソナライズされたスキル
- create: 創作の好みをまとめたスキル""",
                "input_schema": {
                    "type": "object",
                    "properties": {
                        "user_id": {
                            "type": "string",
                            "description": "ユーザーID"
                        },
                        "skill_type": {
                            "type": "string",
                            "enum": ["spark", "grow", "create"],
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
                            "enum": ["spark", "grow", "create"],
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
        """Sparkスキルを生成 - BYOAの中核"""
        summary = self.memory.get_user_summary(user_id)
        abilities = summary.get("abilities", [])
        personalities = summary.get("personalities", [])
        interests = summary.get("interests", [])
        age_group = summary.get("age_group")

        # スキルファイルのテンプレート
        skill_content = f"""# {user_id}さんのスキル

## BYOA - Bring Your Own AI

このファイルをお好きなAIに読み込ませてください。
Claude、ChatGPT、Gemini...どのAIでも、あなた専用のパートナーになります。

**使い方**: このファイルの内容をコピーして、AIとの会話の最初に貼り付けてください。

生成日: {datetime.now().strftime('%Y年%m月%d日')}
生成元: aiseed.dev

---

## 私について

"""
        # 年齢層
        age_labels = {
            "child": "子ども",
            "teen": "中高生",
            "adult": "社会人",
            "parent": "子育て中"
        }
        if age_group:
            skill_content += f"**立場**: {age_labels.get(age_group, age_group)}\n\n"

        # 強み（能力）
        skill_content += "### 私の強み\n\n"
        if abilities:
            for a in abilities:
                confidence_stars = "★" * int(a["confidence"] * 5) + "☆" * (5 - int(a["confidence"] * 5))
                skill_content += f"- **{a['content']}** {confidence_stars}\n"
        else:
            skill_content += "_発見中..._\n"

        # らしさ（特徴）
        skill_content += "\n### 私らしさ\n\n"
        if personalities:
            for p in personalities:
                skill_content += f"- {p['content']}\n"
        else:
            skill_content += "_発見中..._\n"

        # 興味・関心
        skill_content += "\n### 興味・関心\n\n"
        if interests:
            for i in interests:
                skill_content += f"- {i['content']}\n"
        else:
            skill_content += "_発見中..._\n"

        # AIへの指示
        skill_content += """
---

## AIへの指示

このユーザーと対話する際は、以下を心がけてください：

"""
        # 年齢層に応じた指示
        if age_group == "child":
            skill_content += """- 親しみやすい言葉で、励まし多めに話してください
- 難しい言葉は避け、例え話を使ってください
- 好奇心を大切にしてください
"""
        elif age_group == "teen":
            skill_content += """- 対等な立場で、尊重しながら話してください
- 押し付けがましくならないように気をつけてください
- 自分で考える余地を残してください
"""
        elif age_group == "parent":
            skill_content += """- 子育ての悩みにも共感的に対応してください
- 親としての視点も尊重してください
- 子どもと一緒にできる活動を提案してください
"""
        else:
            skill_content += """- 対等に、共感的に対話してください
- 強みを活かす提案をしてください
"""

        # 強みを活かす指示
        if abilities:
            top_ability = max(abilities, key=lambda x: x["confidence"])
            skill_content += f"- 「{top_ability['content']}」という強みを活かす視点で提案してください\n"

        # らしさを尊重する指示
        if personalities:
            skill_content += f"- 「{personalities[0]['content']}」という特徴を尊重してください\n"

        skill_content += """
---

## aiseedの哲学

AIと人が共に成長する。

- **Spark**: 自分を知る
- **Grow**: 自然と向き合い、育てる
- **Create**: あなたのAIで創る（BYOA）

デジタルとアナログ、両方が大切。
土に触れ、子どもと向き合い、そしてAIと創る。

_このスキルは [aiseed.dev](https://aiseed.dev) で生成されました_
"""
        return skill_content

    def _generate_grow_skill(self, user_id: str) -> str:
        """Growスキルを生成"""
        summary = self.memory.get_user_summary(user_id)
        interests = summary.get("interests", [])
        personalities = summary.get("personalities", [])

        skill_content = f"""# {user_id}さんのGrowスキル

## 育てる - 野菜・子ども・自分

生成日: {datetime.now().strftime('%Y年%m月%d日')}

---

## 育てているもの

"""
        # 興味から育てているものを抽出
        grow_interests = [i for i in interests if any(
            keyword in i['content'] for keyword in
            ['野菜', '栽培', '育児', '子ども', '畑', '料理', '植物']
        )]

        if grow_interests:
            for i in grow_interests:
                skill_content += f"- {i['content']}\n"
        else:
            skill_content += "_まだ記録がありません_\n"

        skill_content += """
## 大切にしていること

"""
        if personalities:
            for p in personalities:
                skill_content += f"- {p['content']}\n"
        else:
            skill_content += "_発見中..._\n"

        skill_content += """
---

## AIへの指示

このユーザーの栽培・育児相談では：

- 初心者にも分かりやすく説明してください
- 失敗も学びとして捉える姿勢で
- 自然のリズムを大切にしてください
- 効率より「過程」を楽しむ提案を

_aiseed.dev Grow_
"""
        return skill_content

    def _generate_create_skill(self, user_id: str) -> str:
        """Createスキルを生成"""
        summary = self.memory.get_user_summary(user_id)
        abilities = summary.get("abilities", [])
        personalities = summary.get("personalities", [])
        interests = summary.get("interests", [])

        skill_content = f"""# {user_id}さんのCreateスキル

## BYOA - あなたのAIで創る

生成日: {datetime.now().strftime('%Y年%m月%d日')}

---

## 創作スタイル

"""
        # 創作に関連する特性を抽出
        if personalities:
            skill_content += "### 好みのスタイル\n"
            for p in personalities:
                skill_content += f"- {p['content']}\n"
            skill_content += "\n"

        if abilities:
            skill_content += "### 活かせる強み\n"
            for a in abilities:
                skill_content += f"- {a['content']}\n"
            skill_content += "\n"

        skill_content += """
## AIへの指示

このユーザーの創作サポートでは：

"""
        # スタイルに応じた指示
        if any('シンプル' in p['content'] for p in personalities):
            skill_content += "- シンプルで簡潔な表現を心がけてください\n"
        if any('論理' in a['content'] for a in abilities):
            skill_content += "- 論理的で分かりやすい構成にしてください\n"
        if any('共感' in a['content'] for a in abilities):
            skill_content += "- 読み手の気持ちに寄り添う表現を使ってください\n"

        skill_content += """- コピペしやすい形式で出力してください
- ユーザーの「らしさ」を活かした創作を

---

## 対応できる創作

- 広告・宣伝文
- 各種書類作成
- Webサイト・コンテンツ
- クリエイティブ（ストーリー、詩など）
- AIプロンプト作成

_aiseed.dev Create - BYOA_
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
                "message": "スキル生成には、もう少し会話が必要です。Sparkで対話を続けてみてください。",
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
        elif skill_type == "grow":
            content = self._generate_grow_skill(user_id)
        elif skill_type == "create":
            content = self._generate_create_skill(user_id)
        else:
            content = self._generate_spark_skill(user_id)  # デフォルト

        self.memory.save_skill(user_id, skill_type, content)

        return {
            "status": "generated",
            "skill_type": skill_type,
            "content": content,
            "message": "スキルファイルが生成されました。お好きなAIにコピペして使ってください！"
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
            "message": f"{skill_type}スキルはまだ生成されていません。Sparkで対話を始めてみてください。"
        }

    def _handle_list_skills(self, user_id: str) -> dict:
        """スキル一覧を取得"""
        skills = self.memory.list_skills(user_id)
        return {
            "skills": skills,
            "count": len(skills),
            "available_types": ["spark", "grow", "create"]
        }
