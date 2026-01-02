"""
AIseed Memory Store
ユーザーメモリの永続化と管理

ファイル構成:
user_memory/
  ├── {user_id}/
  │   ├── profile.json      # 特性・強み
  │   ├── history.json      # 対話履歴（要約）
  │   └── skills/           # 生成したスキル
  │       ├── spark.md
  │       └── grow.md
"""
import json
import os
from datetime import datetime
from pathlib import Path
from typing import Optional
from pydantic import BaseModel


class Insight(BaseModel):
    """発見した特性"""
    type: str  # ability（能力）, personality（らしさ）, interest（興味）
    content: str  # 発見した内容
    context: str  # 発見のきっかけとなった文脈
    confidence: float = 0.5  # 確信度 (0.0-1.0)
    discovered_at: str = ""

    def __init__(self, **data):
        if not data.get("discovered_at"):
            data["discovered_at"] = datetime.now().isoformat()
        super().__init__(**data)


class UserProfile(BaseModel):
    """ユーザープロファイル"""
    user_id: str
    age_group: Optional[str] = None  # child, teen, adult, parent
    insights: list[Insight] = []
    conversation_count: int = 0
    first_seen: str = ""
    last_seen: str = ""

    def __init__(self, **data):
        now = datetime.now().isoformat()
        if not data.get("first_seen"):
            data["first_seen"] = now
        if not data.get("last_seen"):
            data["last_seen"] = now
        super().__init__(**data)


class ConversationSummary(BaseModel):
    """会話の要約"""
    session_id: str
    service: str
    summary: str
    key_discoveries: list[str] = []
    created_at: str = ""

    def __init__(self, **data):
        if not data.get("created_at"):
            data["created_at"] = datetime.now().isoformat()
        super().__init__(**data)


class UserMemory:
    """ユーザーメモリ管理クラス"""

    def __init__(self, base_path: str = "user_memory"):
        self.base_path = Path(base_path)
        self.base_path.mkdir(parents=True, exist_ok=True)

    def _user_dir(self, user_id: str) -> Path:
        """ユーザーディレクトリのパス"""
        user_dir = self.base_path / user_id
        user_dir.mkdir(parents=True, exist_ok=True)
        return user_dir

    def _profile_path(self, user_id: str) -> Path:
        return self._user_dir(user_id) / "profile.json"

    def _history_path(self, user_id: str) -> Path:
        return self._user_dir(user_id) / "history.json"

    def _skills_dir(self, user_id: str) -> Path:
        skills_dir = self._user_dir(user_id) / "skills"
        skills_dir.mkdir(parents=True, exist_ok=True)
        return skills_dir

    # ==================== プロファイル管理 ====================

    def get_profile(self, user_id: str) -> UserProfile:
        """ユーザープロファイルを取得"""
        path = self._profile_path(user_id)
        if path.exists():
            with open(path, "r", encoding="utf-8") as f:
                data = json.load(f)
                return UserProfile(**data)
        return UserProfile(user_id=user_id)

    def save_profile(self, profile: UserProfile):
        """プロファイルを保存"""
        profile.last_seen = datetime.now().isoformat()
        path = self._profile_path(profile.user_id)
        with open(path, "w", encoding="utf-8") as f:
            json.dump(profile.model_dump(), f, ensure_ascii=False, indent=2)

    def add_insight(
        self,
        user_id: str,
        type: str,
        content: str,
        context: str,
        confidence: float = 0.5
    ) -> Insight:
        """特性を記録"""
        profile = self.get_profile(user_id)
        insight = Insight(
            type=type,
            content=content,
            context=context,
            confidence=confidence
        )
        profile.insights.append(insight)
        self.save_profile(profile)
        return insight

    def get_insights_by_type(self, user_id: str, type: str) -> list[Insight]:
        """タイプ別に特性を取得"""
        profile = self.get_profile(user_id)
        return [i for i in profile.insights if i.type == type]

    def update_age_group(self, user_id: str, age_group: str):
        """年齢層を更新"""
        profile = self.get_profile(user_id)
        profile.age_group = age_group
        self.save_profile(profile)

    def increment_conversation_count(self, user_id: str):
        """会話回数をインクリメント"""
        profile = self.get_profile(user_id)
        profile.conversation_count += 1
        self.save_profile(profile)

    # ==================== 履歴管理 ====================

    def get_history(self, user_id: str) -> list[ConversationSummary]:
        """会話履歴（要約）を取得"""
        path = self._history_path(user_id)
        if path.exists():
            with open(path, "r", encoding="utf-8") as f:
                data = json.load(f)
                return [ConversationSummary(**s) for s in data]
        return []

    def add_history(
        self,
        user_id: str,
        session_id: str,
        service: str,
        summary: str,
        key_discoveries: list[str] = None
    ):
        """会話履歴を追加"""
        history = self.get_history(user_id)
        entry = ConversationSummary(
            session_id=session_id,
            service=service,
            summary=summary,
            key_discoveries=key_discoveries or []
        )
        history.append(entry)

        # 最新100件のみ保持
        if len(history) > 100:
            history = history[-100:]

        path = self._history_path(user_id)
        with open(path, "w", encoding="utf-8") as f:
            json.dump([h.model_dump() for h in history], f, ensure_ascii=False, indent=2)

    # ==================== スキル管理 ====================

    def save_skill(self, user_id: str, skill_type: str, content: str):
        """スキルファイルを保存"""
        path = self._skills_dir(user_id) / f"{skill_type}.md"
        with open(path, "w", encoding="utf-8") as f:
            f.write(content)

    def get_skill(self, user_id: str, skill_type: str) -> Optional[str]:
        """スキルファイルを取得"""
        path = self._skills_dir(user_id) / f"{skill_type}.md"
        if path.exists():
            with open(path, "r", encoding="utf-8") as f:
                return f.read()
        return None

    def list_skills(self, user_id: str) -> list[str]:
        """スキル一覧を取得"""
        skills_dir = self._skills_dir(user_id)
        return [f.stem for f in skills_dir.glob("*.md")]

    # ==================== ユーティリティ ====================

    def get_user_summary(self, user_id: str) -> dict:
        """ユーザーの概要情報を取得"""
        profile = self.get_profile(user_id)
        history = self.get_history(user_id)
        skills = self.list_skills(user_id)

        # 特性をタイプ別に整理
        abilities = [i for i in profile.insights if i.type == "ability"]
        personalities = [i for i in profile.insights if i.type == "personality"]
        interests = [i for i in profile.insights if i.type == "interest"]

        return {
            "user_id": user_id,
            "age_group": profile.age_group,
            "conversation_count": profile.conversation_count,
            "first_seen": profile.first_seen,
            "last_seen": profile.last_seen,
            "abilities": [{"content": a.content, "confidence": a.confidence} for a in abilities],
            "personalities": [{"content": p.content, "confidence": p.confidence} for p in personalities],
            "interests": [{"content": i.content, "confidence": i.confidence} for i in interests],
            "recent_history": [
                {"service": h.service, "summary": h.summary, "created_at": h.created_at}
                for h in history[-5:]  # 最新5件
            ],
            "skills": skills
        }
