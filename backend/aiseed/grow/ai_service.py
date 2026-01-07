"""
栽培AI分析サービス（BYOA対応）

ユーザーが自分のAI（Claude/ChatGPT等）を使って高度な分析を行う

使用パターン:
1. 開発版: Claude Max で分析（運営負担）
2. 公開版: BYOA（ユーザー負担）
"""
import json
import logging
from datetime import datetime
from typing import Callable, Optional, Any
from dataclasses import dataclass

from .models import Plant, Observation

logger = logging.getLogger("aiseed.grow.ai")


@dataclass
class GrowthAnalysis:
    """成長分析結果"""
    summary: str  # 現在の状況まとめ
    health_score: float  # 健康度 0.0-1.0
    insights: list[str]  # 気づき
    concerns: list[str]  # 懸念点
    recommendations: list[str]  # アドバイス
    next_actions: list[str]  # 次にやること
    growth_stage: str  # 成長段階


@dataclass
class ProblemDiagnosis:
    """問題診断結果"""
    problem_type: str  # pest, disease, nutrient, water, light, etc.
    confidence: float  # 確信度
    description: str  # 問題の説明
    possible_causes: list[str]  # 考えられる原因
    solutions: list[str]  # 解決策
    urgency: str  # high, medium, low


@dataclass
class HarvestPrediction:
    """収穫予測"""
    estimated_date: str  # 予想収穫日
    confidence: float
    conditions: list[str]  # 条件
    tips: list[str]  # 収穫のコツ


class GrowAIService:
    """
    栽培AI分析サービス

    BYOA（Bring Your Own AI）対応:
    - ai_query: ユーザーのAI呼び出し関数を注入
    - ユーザーが自分のAPIキーで分析
    - 運営コスト = 0

    使用例:
    ```python
    # 開発版（運営のAI）
    ai_service = GrowAIService(ai_query=agent.chat)

    # 公開版（ユーザーのAI）
    user_ai = create_user_ai_client(user_api_key)
    ai_service = GrowAIService(ai_query=user_ai.query)
    ```
    """

    def __init__(self, ai_query: Callable = None):
        """
        Args:
            ai_query: AI問い合わせ関数
                      async def query(prompt: str) -> str
        """
        self.ai_query = ai_query

    async def analyze_growth(
        self,
        plant: Plant,
        observations: list[Observation],
        recent_days: int = 7
    ) -> GrowthAnalysis:
        """
        成長を総合分析

        Args:
            plant: 植物情報
            observations: 観察記録リスト
            recent_days: 直近何日分を重視するか
        """
        if not self.ai_query:
            return self._fallback_analysis(plant, observations)

        # 直近の観察をまとめる
        recent_obs = self._format_observations(observations[:recent_days])

        prompt = f"""
あなたは経験豊富な園芸アドバイザーです。
以下の植物と観察記録を分析して、やさしくアドバイスしてください。

【植物情報】
- 名前: {plant.name}
- 品種: {plant.variety or '不明'}
- 場所: {plant.location or '不明'}
- 栽培開始: {plant.started_at}

【最近の観察記録】
{recent_obs}

JSON形式で出力してください:
{{
  "summary": "現在の状況を1-2文で",
  "health_score": 0.8,  // 0.0-1.0
  "growth_stage": "発芽期/成長期/開花期/結実期/収穫期 のいずれか",
  "insights": ["気づき1", "気づき2"],
  "concerns": ["懸念があれば"],
  "recommendations": ["アドバイス1", "アドバイス2"],
  "next_actions": ["次にやること1", "次にやること2"]
}}

やさしい言葉で、初心者にもわかりやすく伝えてください。
"""

        try:
            response = await self.ai_query(prompt)
            return self._parse_growth_analysis(response)
        except Exception as e:
            logger.error(f"AI分析エラー: {e}")
            return self._fallback_analysis(plant, observations)

    async def diagnose_problem(
        self,
        plant: Plant,
        problem_description: str,
        observations: list[Observation] = None
    ) -> ProblemDiagnosis:
        """
        問題を診断

        Args:
            plant: 植物情報
            problem_description: 問題の説明（写真の代わりにテキスト）
            observations: 関連する観察記録
        """
        if not self.ai_query:
            return self._fallback_diagnosis(problem_description)

        obs_text = ""
        if observations:
            obs_text = f"\n【最近の観察】\n{self._format_observations(observations[:5])}"

        prompt = f"""
あなたは植物の病害虫診断の専門家です。
以下の情報から問題を診断してください。

【植物】
- 名前: {plant.name}
- 品種: {plant.variety or '不明'}
- 場所: {plant.location or '不明'}

【問題の説明】
{problem_description}
{obs_text}

JSON形式で出力:
{{
  "problem_type": "pest/disease/nutrient/water/light/temperature/other",
  "confidence": 0.7,
  "description": "問題の説明",
  "possible_causes": ["原因1", "原因2"],
  "solutions": ["解決策1", "解決策2", "解決策3"],
  "urgency": "high/medium/low"
}}

やさしい言葉で、具体的な対処法を教えてください。
"""

        try:
            response = await self.ai_query(prompt)
            return self._parse_diagnosis(response)
        except Exception as e:
            logger.error(f"診断エラー: {e}")
            return self._fallback_diagnosis(problem_description)

    async def predict_harvest(
        self,
        plant: Plant,
        observations: list[Observation]
    ) -> HarvestPrediction:
        """
        収穫時期を予測

        Args:
            plant: 植物情報
            observations: 観察記録
        """
        if not self.ai_query:
            return self._fallback_harvest_prediction(plant)

        obs_text = self._format_observations(observations[:10])

        prompt = f"""
あなたは園芸の専門家です。
以下の植物の収穫時期を予測してください。

【植物】
- 名前: {plant.name}
- 品種: {plant.variety or '不明'}
- 栽培開始: {plant.started_at}
- 今日の日付: {datetime.now().strftime('%Y-%m-%d')}

【観察記録】
{obs_text}

JSON形式で出力:
{{
  "estimated_date": "YYYY-MM-DD",
  "confidence": 0.6,
  "conditions": ["順調に育てば", "天候が良ければ"],
  "tips": ["収穫のコツ1", "収穫のコツ2"]
}}

収穫できる野菜/果物でない場合は、開花時期などを予測してください。
"""

        try:
            response = await self.ai_query(prompt)
            return self._parse_harvest_prediction(response)
        except Exception as e:
            logger.error(f"予測エラー: {e}")
            return self._fallback_harvest_prediction(plant)

    async def generate_observation_prompt(
        self,
        plant: Plant,
        last_observation: Optional[Observation] = None
    ) -> str:
        """
        観察の促しメッセージを生成

        「今日は何を観察しましたか？」的なパーソナライズされた質問
        """
        if not self.ai_query:
            return self._fallback_observation_prompt(plant, last_observation)

        last_obs_text = ""
        if last_observation:
            last_obs_text = f"\n前回の観察（{last_observation.date}）: {last_observation.text}"

        prompt = f"""
ユーザーが栽培している植物の観察を促すメッセージを作ってください。

【植物】
- 名前: {plant.name}
- 品種: {plant.variety or ''}
{last_obs_text}

1-2文で、やさしく観察を促してください。
具体的な観察ポイントを含めてください。
絵文字は1つまで使ってOKです。
"""

        try:
            response = await self.ai_query(prompt)
            return response.strip()
        except Exception as e:
            logger.error(f"プロンプト生成エラー: {e}")
            return self._fallback_observation_prompt(plant, last_observation)

    async def extract_insights(
        self,
        observation_text: str,
        plant: Plant
    ) -> list[str]:
        """
        観察テキストから気づきを抽出（AIバージョン）

        ルールベースより深い気づきを抽出
        """
        if not self.ai_query:
            return []

        prompt = f"""
以下の観察記録から、栽培に役立つ気づきを抽出してください。

【植物】{plant.name}
【観察】{observation_text}

気づきを3つまで、短い文章で出力してください。
配列で出力: ["気づき1", "気づき2"]

気づきがない場合は空配列 [] を返してください。
やさしい言葉で、励ましを含めてください。
"""

        try:
            response = await self.ai_query(prompt)
            # JSON配列を抽出
            import re
            match = re.search(r'\[.*\]', response, re.DOTALL)
            if match:
                return json.loads(match.group())
            return []
        except Exception as e:
            logger.error(f"気づき抽出エラー: {e}")
            return []

    # ==================== ヘルパー ====================

    def _format_observations(self, observations: list[Observation]) -> str:
        """観察記録をテキストにフォーマット"""
        if not observations:
            return "（まだ観察記録がありません）"

        lines = []
        for obs in observations:
            actions = []
            if obs.watered:
                actions.append("水やり")
            if obs.fertilized:
                actions.append("肥料")
            if obs.harvested:
                actions.append(f"収穫({obs.harvest_amount or ''})")

            action_text = f" [{', '.join(actions)}]" if actions else ""
            weather_text = f" 天気:{obs.weather}" if obs.weather else ""
            temp_text = f" {obs.temperature}℃" if obs.temperature else ""

            lines.append(f"- {obs.date}: {obs.text}{action_text}{weather_text}{temp_text}")

        return "\n".join(lines)

    def _parse_growth_analysis(self, response: str) -> GrowthAnalysis:
        """AI応答をパース"""
        import re
        match = re.search(r'\{.*\}', response, re.DOTALL)
        if match:
            data = json.loads(match.group())
            return GrowthAnalysis(
                summary=data.get("summary", ""),
                health_score=float(data.get("health_score", 0.5)),
                insights=data.get("insights", []),
                concerns=data.get("concerns", []),
                recommendations=data.get("recommendations", []),
                next_actions=data.get("next_actions", []),
                growth_stage=data.get("growth_stage", "成長期")
            )
        raise ValueError("JSON解析失敗")

    def _parse_diagnosis(self, response: str) -> ProblemDiagnosis:
        """診断応答をパース"""
        import re
        match = re.search(r'\{.*\}', response, re.DOTALL)
        if match:
            data = json.loads(match.group())
            return ProblemDiagnosis(
                problem_type=data.get("problem_type", "other"),
                confidence=float(data.get("confidence", 0.5)),
                description=data.get("description", ""),
                possible_causes=data.get("possible_causes", []),
                solutions=data.get("solutions", []),
                urgency=data.get("urgency", "medium")
            )
        raise ValueError("JSON解析失敗")

    def _parse_harvest_prediction(self, response: str) -> HarvestPrediction:
        """収穫予測応答をパース"""
        import re
        match = re.search(r'\{.*\}', response, re.DOTALL)
        if match:
            data = json.loads(match.group())
            return HarvestPrediction(
                estimated_date=data.get("estimated_date", ""),
                confidence=float(data.get("confidence", 0.5)),
                conditions=data.get("conditions", []),
                tips=data.get("tips", [])
            )
        raise ValueError("JSON解析失敗")

    # ==================== フォールバック（AI不使用） ====================

    def _fallback_analysis(
        self,
        plant: Plant,
        observations: list[Observation]
    ) -> GrowthAnalysis:
        """AIなしのフォールバック分析"""
        # 簡易的なルールベース分析
        health_score = 0.7
        insights = []
        concerns = []

        if observations:
            # 水やり頻度チェック
            watered_count = sum(1 for o in observations[:7] if o.watered)
            if watered_count == 0:
                concerns.append("最近水やりの記録がありません")
                health_score -= 0.1
            elif watered_count > 5:
                concerns.append("水やりが多いかもしれません")

            # 観察頻度
            if len(observations) > 3:
                insights.append("こまめに観察していますね")

        return GrowthAnalysis(
            summary=f"{plant.name}の栽培記録です",
            health_score=max(0.3, health_score),
            insights=insights or ["観察を続けましょう"],
            concerns=concerns,
            recommendations=["定期的な観察を続けてください"],
            next_actions=["今日の様子を記録しましょう"],
            growth_stage="成長期"
        )

    def _fallback_diagnosis(self, problem: str) -> ProblemDiagnosis:
        """AIなしのフォールバック診断"""
        # キーワードベースの簡易診断
        problem_lower = problem.lower()

        if any(w in problem_lower for w in ["虫", "むし", "アブラムシ", "害虫"]):
            return ProblemDiagnosis(
                problem_type="pest",
                confidence=0.5,
                description="害虫の可能性があります",
                possible_causes=["風通しが悪い", "他の植物から移った"],
                solutions=["害虫を手で取り除く", "木酢液を薄めてスプレー", "風通しを良くする"],
                urgency="medium"
            )

        if any(w in problem_lower for w in ["黄色", "きいろ", "枯れ", "しおれ"]):
            return ProblemDiagnosis(
                problem_type="water",
                confidence=0.4,
                description="水やりの問題かもしれません",
                possible_causes=["水不足", "水のやりすぎ", "根腐れ"],
                solutions=["土の乾き具合を確認", "排水を良くする", "水やりの頻度を調整"],
                urgency="medium"
            )

        return ProblemDiagnosis(
            problem_type="other",
            confidence=0.3,
            description="詳しい情報が必要です",
            possible_causes=["様々な原因が考えられます"],
            solutions=["専門家に相談する", "写真を撮って記録する"],
            urgency="low"
        )

    def _fallback_harvest_prediction(self, plant: Plant) -> HarvestPrediction:
        """AIなしのフォールバック予測"""
        return HarvestPrediction(
            estimated_date="",
            confidence=0.0,
            conditions=["AI分析を使用すると予測できます"],
            tips=["実が色づいたら収穫時期です", "朝の涼しい時間に収穫がおすすめ"]
        )

    def _fallback_observation_prompt(
        self,
        plant: Plant,
        last_obs: Optional[Observation]
    ) -> str:
        """AIなしのフォールバックプロンプト"""
        if last_obs:
            return f"🌱 {plant.name}の今日の様子はどうですか？"
        return f"🌱 {plant.name}を観察してみましょう！葉っぱの色や大きさはどうですか？"
