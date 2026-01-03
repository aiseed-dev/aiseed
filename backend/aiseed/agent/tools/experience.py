"""
AIseed Spark Experience Tasks
体験タスクによる強み発見

質問しない、正解がない、ラベルを貼らない。
体験させて反応を観察し、傾向を詩的に表現する。
"""
from typing import Optional
from datetime import datetime
from pydantic import BaseModel
from memory.store import UserMemory


# ==================== タスク定義 ====================

TASKS = {
    "observe": {
        "id": "observe",
        "name": "観察 - 何が気になる？",
        "type": "tap_image",
        "instruction": "この写真を見て、最初に目がいったところをタップしてね",
        "duration_sec": 30,
        "asset": "forest.jpg",  # 森の写真
        "analysis": {
            "dimensions": ["全体把握型", "細部注目型"],
            "description": "視点の傾向を見ています"
        }
    },
    "sound": {
        "id": "sound",
        "name": "音と連想",
        "type": "select_image",
        "instruction": "この音を聞いて、何を思い浮かべた？",
        "duration_sec": 15,
        "asset": "rain.mp3",  # 雨音
        "options": [
            {"id": "umbrella", "label": "傘", "image": "umbrella.png"},
            {"id": "window", "label": "窓", "image": "window.png"},
            {"id": "forest", "label": "森", "image": "forest.png"},
            {"id": "sea", "label": "海", "image": "sea.png"},
        ],
        "allow_other": True,
        "analysis": {
            "dimensions": ["具象的連想", "抽象的連想"],
            "description": "連想の傾向を見ています"
        }
    },
    "arrange": {
        "id": "arrange",
        "name": "並べてみる",
        "type": "drag_arrange",
        "instruction": "好きなように並べてみて",
        "duration_sec": 60,
        "items": [
            {"id": "circle", "shape": "circle", "color": "#FF6B6B"},
            {"id": "square", "shape": "square", "color": "#4ECDC4"},
            {"id": "triangle", "shape": "triangle", "color": "#45B7D1"},
            {"id": "star", "shape": "star", "color": "#96CEB4"},
            {"id": "heart", "shape": "heart", "color": "#FFEAA7"},
        ],
        "analysis": {
            "dimensions": ["規則性志向", "自由配置志向", "即断型", "熟考型"],
            "description": "配置パターンと意思決定スタイルを見ています"
        }
    },
    "story": {
        "id": "story",
        "name": "続きを選ぶ",
        "type": "select_image",
        "instruction": "小さな種が風に乗って飛んでいきました。どこに降りた？",
        "duration_sec": 20,
        "options": [
            {"id": "city", "label": "街", "image": "city.png"},
            {"id": "mountain", "label": "山", "image": "mountain.png"},
            {"id": "sea", "label": "海", "image": "sea.png"},
        ],
        "analysis": {
            "dimensions": ["環境への志向性"],
            "description": "好みの環境を見ています"
        }
    },
    "rhythm": {
        "id": "rhythm",
        "name": "リズム",
        "type": "free_tap",
        "instruction": "好きなようにタップしてみて",
        "duration_sec": 10,
        "analysis": {
            "dimensions": ["規則的", "即興的", "活動量"],
            "description": "リズム感と活動パターンを見ています"
        }
    },
    "color": {
        "id": "color",
        "name": "色を選ぶ",
        "type": "color_picker",
        "instruction": "今日の気分に近い色は？",
        "duration_sec": 15,
        "analysis": {
            "dimensions": ["現在の感情状態"],
            "description": "今の気分を参考にします（分析ではなく提案の参考）"
        }
    },
}

# タスクの順序
TASK_ORDER = ["observe", "sound", "arrange", "story", "rhythm", "color"]


# ==================== モデル ====================

class TaskResult(BaseModel):
    """タスク結果"""
    task_id: str
    user_id: str
    session_id: str

    # タスクタイプ別のデータ
    tap_position: Optional[dict] = None  # {"x": 0.5, "y": 0.3} 正規化座標
    selected_option: Optional[str] = None
    other_text: Optional[str] = None
    arranged_positions: Optional[list] = None  # [{"id": "circle", "x": 0.1, "y": 0.2}, ...]
    tap_sequence: Optional[list] = None  # [{"time_ms": 100, "x": 0.5, "y": 0.5}, ...]
    selected_color: Optional[str] = None  # "#FF6B6B"

    # メタデータ
    duration_ms: int  # 実際にかかった時間
    hesitation_count: int = 0  # 迷った回数（タップ修正など）
    completed_at: str = ""

    def __init__(self, **data):
        if not data.get("completed_at"):
            data["completed_at"] = datetime.now().isoformat()
        super().__init__(**data)


class SessionProgress(BaseModel):
    """セッションの進行状況"""
    session_id: str
    user_id: str
    current_task_index: int = 0
    completed_tasks: list[str] = []
    results: list[dict] = []
    started_at: str = ""

    def __init__(self, **data):
        if not data.get("started_at"):
            data["started_at"] = datetime.now().isoformat()
        super().__init__(**data)


# ==================== 分析ロジック ====================

class TaskAnalyzer:
    """タスク結果の分析"""

    @staticmethod
    def analyze_observe(result: TaskResult) -> dict:
        """観察タスクの分析"""
        if not result.tap_position:
            return {}

        x, y = result.tap_position.get("x", 0.5), result.tap_position.get("y", 0.5)

        # 中心に近いか周辺か
        center_distance = ((x - 0.5) ** 2 + (y - 0.5) ** 2) ** 0.5

        if center_distance < 0.2:
            tendency = "全体把握型"
            description = "まず全体を見渡す傾向があるかもしれません"
        else:
            tendency = "細部注目型"
            description = "細かいところに気づく目を持っているかもしれません"

        return {
            "tendency": tendency,
            "description": description,
            "confidence": 0.3  # 初回は低め
        }

    @staticmethod
    def analyze_sound(result: TaskResult) -> dict:
        """音連想タスクの分析"""
        option = result.selected_option

        concrete = ["umbrella", "window"]
        abstract = ["forest", "sea"]

        if option in concrete:
            return {
                "tendency": "具象的連想",
                "description": "目の前のことを具体的に考える傾向があるかもしれません",
                "confidence": 0.3
            }
        elif option in abstract:
            return {
                "tendency": "抽象的連想",
                "description": "イメージを広げて考える傾向があるかもしれません",
                "confidence": 0.3
            }
        else:
            return {
                "tendency": "独自の視点",
                "description": "自分だけの見方を持っているかもしれません",
                "confidence": 0.3
            }

    @staticmethod
    def analyze_arrange(result: TaskResult) -> dict:
        """配置タスクの分析"""
        positions = result.arranged_positions or []
        duration = result.duration_ms

        if len(positions) < 3:
            return {}

        # 規則性の判定（簡易版）
        xs = [p.get("x", 0) for p in positions]
        ys = [p.get("y", 0) for p in positions]

        x_variance = sum((x - sum(xs)/len(xs))**2 for x in xs) / len(xs)
        y_variance = sum((y - sum(ys)/len(ys))**2 for y in ys) / len(ys)

        # 時間による判定
        if duration < 10000:  # 10秒未満
            speed = "即断型"
            speed_desc = "直感で動くタイプかもしれません"
        else:
            speed = "熟考型"
            speed_desc = "じっくり考えるタイプかもしれません"

        # 配置パターンによる判定
        if x_variance < 0.05 or y_variance < 0.05:
            pattern = "規則性志向"
            pattern_desc = "きちんと整理することが好きかもしれません"
        else:
            pattern = "自由配置志向"
            pattern_desc = "自分のリズムを大切にしているかもしれません"

        return {
            "tendency": f"{pattern}・{speed}",
            "description": f"{pattern_desc}。{speed_desc}",
            "confidence": 0.4
        }

    @staticmethod
    def analyze_rhythm(result: TaskResult) -> dict:
        """リズムタスクの分析"""
        taps = result.tap_sequence or []

        if len(taps) < 3:
            return {
                "tendency": "控えめ",
                "description": "慎重に様子を見るタイプかもしれません",
                "confidence": 0.3
            }

        # タップ間隔の分析
        intervals = []
        for i in range(1, len(taps)):
            interval = taps[i].get("time_ms", 0) - taps[i-1].get("time_ms", 0)
            intervals.append(interval)

        if not intervals:
            return {}

        avg_interval = sum(intervals) / len(intervals)
        variance = sum((i - avg_interval)**2 for i in intervals) / len(intervals)

        if variance < 10000:  # 間隔が一定
            return {
                "tendency": "規則的",
                "description": "自分のリズムを持っているかもしれません",
                "confidence": 0.3
            }
        else:
            return {
                "tendency": "即興的",
                "description": "その場の感覚を大切にするタイプかもしれません",
                "confidence": 0.3
            }

    @staticmethod
    def analyze_all(results: list[TaskResult]) -> dict:
        """全タスクの統合分析"""
        tendencies = []
        descriptions = []

        for result in results:
            if result.task_id == "observe":
                analysis = TaskAnalyzer.analyze_observe(result)
            elif result.task_id == "sound":
                analysis = TaskAnalyzer.analyze_sound(result)
            elif result.task_id == "arrange":
                analysis = TaskAnalyzer.analyze_arrange(result)
            elif result.task_id == "rhythm":
                analysis = TaskAnalyzer.analyze_rhythm(result)
            else:
                continue

            if analysis:
                tendencies.append(analysis.get("tendency", ""))
                if analysis.get("description"):
                    descriptions.append(analysis["description"])

        return {
            "tendencies": tendencies,
            "descriptions": descriptions,
            "summary": TaskAnalyzer._generate_poetic_summary(tendencies, descriptions)
        }

    @staticmethod
    def _generate_poetic_summary(tendencies: list, descriptions: list) -> str:
        """詩的なサマリーを生成"""
        if not tendencies:
            return "あなたのこと、もう少し知りたいな"

        summary_parts = ["あなたのこと、少しわかった気がします。\n"]

        # 上位2-3個の傾向を詩的に表現
        for desc in descriptions[:3]:
            summary_parts.append(f"・{desc}\n")

        summary_parts.append("\n（これは可能性です。正解も不正解もありません）")

        return "".join(summary_parts)


# ==================== メインクラス ====================

class SparkExperience:
    """Spark体験タスク管理"""

    def __init__(self, memory: UserMemory):
        self.memory = memory
        self.sessions: dict[str, SessionProgress] = {}

    def start_session(self, user_id: str, session_id: str) -> dict:
        """体験セッションを開始"""
        progress = SessionProgress(
            session_id=session_id,
            user_id=user_id
        )
        self.sessions[session_id] = progress

        return {
            "session_id": session_id,
            "total_tasks": len(TASK_ORDER),
            "first_task": self.get_task(TASK_ORDER[0]),
            "message": "ようこそ！これから少し遊んでみましょう。正解も不正解もありません。感じたままに。"
        }

    def get_task(self, task_id: str) -> dict:
        """タスク情報を取得"""
        task = TASKS.get(task_id)
        if not task:
            return {"error": "Task not found"}

        # 分析情報は返さない（ユーザーに見せない）
        return {
            "id": task["id"],
            "name": task["name"],
            "type": task["type"],
            "instruction": task["instruction"],
            "duration_sec": task["duration_sec"],
            "asset": task.get("asset"),
            "options": task.get("options"),
            "items": task.get("items"),
            "allow_other": task.get("allow_other", False),
        }

    def submit_result(self, result: TaskResult) -> dict:
        """タスク結果を送信"""
        session = self.sessions.get(result.session_id)
        if not session:
            return {"error": "Session not found"}

        # 結果を保存
        session.results.append(result.model_dump())
        session.completed_tasks.append(result.task_id)
        session.current_task_index += 1

        # 次のタスクがあるか
        if session.current_task_index < len(TASK_ORDER):
            next_task_id = TASK_ORDER[session.current_task_index]
            return {
                "status": "continue",
                "completed": session.current_task_index,
                "total": len(TASK_ORDER),
                "next_task": self.get_task(next_task_id)
            }
        else:
            # 全タスク完了 → 分析
            return self._complete_session(session)

    def _complete_session(self, session: SessionProgress) -> dict:
        """セッション完了・分析"""
        # 結果をTaskResultに変換
        results = [TaskResult(**r) for r in session.results]

        # 分析
        analysis = TaskAnalyzer.analyze_all(results)

        # メモリに保存（insightとして記録）
        for tendency in analysis.get("tendencies", []):
            if tendency:
                self.memory.add_insight(
                    user_id=session.user_id,
                    type="personality",
                    content=tendency,
                    context="Spark体験タスクから発見",
                    confidence=0.3  # 体験タスクは確信度低め
                )

        # Grow/Createへの提案を生成
        suggestions = self._generate_suggestions(analysis)

        return {
            "status": "completed",
            "feedback": {
                "summary": analysis.get("summary", ""),
                "tendencies": analysis.get("tendencies", []),
            },
            "suggestions": suggestions,
            "message": "お疲れさまでした！もっと知りたかったら、また遊びに来てね。"
        }

    def _generate_suggestions(self, analysis: dict) -> list:
        """Grow/Createへの提案を生成"""
        tendencies = analysis.get("tendencies", [])
        suggestions = []

        if "細部注目型" in " ".join(tendencies):
            suggestions.append({
                "service": "grow",
                "title": "芽の成長を観察してみる？",
                "description": "小さな変化に気づけるあなたにぴったり"
            })

        if "即興的" in " ".join(tendencies):
            suggestions.append({
                "service": "create",
                "title": "AIと気ままにおしゃべり",
                "description": "思いついたことをそのまま形に"
            })

        if "規則性志向" in " ".join(tendencies):
            suggestions.append({
                "service": "grow",
                "title": "毎日の記録をつけてみる",
                "description": "コツコツ続けることが好きなあなたに"
            })

        # デフォルトの提案
        if not suggestions:
            suggestions.append({
                "service": "grow",
                "title": "野菜を育ててみる？",
                "description": "土に触れる体験から始めてみよう"
            })

        return suggestions
