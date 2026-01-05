"""
AIテスターモジュール

Claude Maxを使って、ルールベース実装を様々なペルソナでテスト・評価する

開発フロー:
1. AIテスターが様々なペルソナで入力を生成
2. ルールベース実装を実行
3. AIテスターが出力を評価
4. 改善点を抽出
"""
import json
import logging
from datetime import datetime
from pathlib import Path
from typing import Callable, Optional, Any
from dataclasses import dataclass, asdict

logger = logging.getLogger("aiseed.evaluation")


@dataclass
class TestCase:
    """テストケース"""
    persona: str
    scenario: str
    input_data: dict
    expected_behavior: str


@dataclass
class TestResult:
    """テスト結果"""
    test_case: TestCase
    actual_output: Any
    evaluation: str
    score: float  # 0.0-1.0
    improvement_suggestions: list[str]
    timestamp: str = ""

    def __post_init__(self):
        if not self.timestamp:
            self.timestamp = datetime.now().isoformat()


class AITester:
    """
    AIテスター

    Claude Maxを使って:
    1. 様々なペルソナでテストケースを生成
    2. ルールベース実装を評価
    3. 改善点を抽出

    使用例:
    ```python
    tester = AITester(ai_query=agent.chat)

    # テストケース生成
    cases = await tester.generate_test_cases(
        feature="shipment_parsing",
        personas=["視覚優位の10歳", "ADHD傾向のある大人"]
    )

    # ルールベース実装をテスト
    results = await tester.run_tests(
        test_cases=cases,
        handler=rule_based_parser
    )

    # 改善点を抽出
    improvements = tester.extract_improvements(results)
    ```
    """

    # ペルソナ定義
    PERSONAS = {
        "child_visual": {
            "name": "視覚優位の10歳の子供",
            "description": "絵や図で考えることが得意。文章より画像で理解する。",
            "input_style": "シンプルで具体的な言葉を使う"
        },
        "child_adhd": {
            "name": "ADHD傾向のある子供",
            "description": "注意が移りやすい。短い文章で要点を伝える必要がある。",
            "input_style": "短く、要点を先に言う"
        },
        "adult_dyslexia": {
            "name": "ディスレクシアの大人",
            "description": "読み書きに困難がある。音声入力を好む。",
            "input_style": "話し言葉のような自然な表現"
        },
        "farmer_elderly": {
            "name": "高齢の農家",
            "description": "スマホに不慣れ。方言を使うことがある。",
            "input_style": "簡潔で方言混じり"
        },
        "shop_owner_busy": {
            "name": "忙しい店主",
            "description": "時間がない。最小限の入力で済ませたい。",
            "input_style": "省略が多い、キーワードのみ"
        }
    }

    def __init__(
        self,
        ai_query: Callable,
        log_path: str = "test_logs"
    ):
        """
        Args:
            ai_query: AI問い合わせ関数（Claude Max）
            log_path: ログ保存先
        """
        self.ai_query = ai_query
        self.log_path = Path(log_path)
        self.log_path.mkdir(parents=True, exist_ok=True)
        self.results: list[TestResult] = []

    async def generate_test_cases(
        self,
        feature: str,
        personas: list[str] = None,
        count_per_persona: int = 3
    ) -> list[TestCase]:
        """
        テストケースを生成

        Args:
            feature: テスト対象機能（例: "shipment_parsing", "feedback_text"）
            personas: 使用するペルソナのキー（Noneで全て）
            count_per_persona: ペルソナごとのケース数
        """
        if personas is None:
            personas = list(self.PERSONAS.keys())

        test_cases = []

        for persona_key in personas:
            persona = self.PERSONAS.get(persona_key, {
                "name": persona_key,
                "description": "",
                "input_style": ""
            })

            prompt = f"""
あなたは「{persona['name']}」として、{feature}機能をテストするための入力を{count_per_persona}個生成してください。

ペルソナの特徴:
- {persona['description']}
- 入力スタイル: {persona['input_style']}

機能の説明:
{self._get_feature_description(feature)}

JSON形式で出力:
[
  {{
    "scenario": "どういう状況か",
    "input": "実際の入力テキストまたはデータ",
    "expected_behavior": "期待される動作"
  }}
]
"""

            try:
                response = await self.ai_query(
                    service="create",
                    user_message=prompt,
                    user_id="ai_tester",
                    task_name="generate_test_cases"
                )

                # JSONを抽出
                import re
                json_match = re.search(r'\[.*\]', response, re.DOTALL)
                if json_match:
                    cases_data = json.loads(json_match.group())
                    for case_data in cases_data:
                        test_cases.append(TestCase(
                            persona=persona['name'],
                            scenario=case_data.get('scenario', ''),
                            input_data={"text": case_data.get('input', '')},
                            expected_behavior=case_data.get('expected_behavior', '')
                        ))
            except Exception as e:
                logger.error(f"テストケース生成エラー ({persona_key}): {e}")

        return test_cases

    def _get_feature_description(self, feature: str) -> str:
        """機能の説明を取得"""
        descriptions = {
            "shipment_parsing": """
出荷情報の自然言語解析機能。
入力例: "今日10時に道の駅ひまわりにトマト100円"
出力: 日付、時間、場所、商品と価格を抽出
""",
            "feedback_text": """
Spark体験タスクのフィードバック文言生成。
入力: ユーザーの行動パターン（タップ位置、反応時間など）
出力: やわらかく詩的な強み発見の文言
""",
            "skills_extraction": """
会話からスキルズを抽出する機能。
入力: 会話履歴
出力: 発見した強み、興味、特性
""",
            "grow_analysis": """
栽培記録の分析機能。
入力: 観察記録のテキスト
出力: 気づきポイント、次のアクション提案
"""
        }
        return descriptions.get(feature, f"{feature}機能のテスト")

    async def run_tests(
        self,
        test_cases: list[TestCase],
        handler: Callable
    ) -> list[TestResult]:
        """
        テストを実行

        Args:
            test_cases: テストケースのリスト
            handler: テスト対象のハンドラー関数
        """
        import asyncio

        results = []

        for case in test_cases:
            # ハンドラー実行
            try:
                if asyncio.iscoroutinefunction(handler):
                    output = await handler(case.input_data)
                else:
                    output = handler(case.input_data)
            except Exception as e:
                output = {"error": str(e)}

            # AIで評価
            evaluation, score, suggestions = await self._evaluate_output(
                case, output
            )

            result = TestResult(
                test_case=case,
                actual_output=output,
                evaluation=evaluation,
                score=score,
                improvement_suggestions=suggestions
            )
            results.append(result)
            self.results.append(result)

            # ログ保存
            self._log_result(result)

        return results

    async def _evaluate_output(
        self,
        case: TestCase,
        output: Any
    ) -> tuple[str, float, list[str]]:
        """AIで出力を評価"""
        prompt = f"""
以下のテストケースと出力を評価してください。

【ペルソナ】
{case.persona}

【シナリオ】
{case.scenario}

【入力】
{json.dumps(case.input_data, ensure_ascii=False)}

【期待される動作】
{case.expected_behavior}

【実際の出力】
{json.dumps(output, ensure_ascii=False, default=str)}

JSON形式で評価:
{{
  "evaluation": "評価コメント（1-2文）",
  "score": 0.8,  // 0.0-1.0
  "improvements": ["改善点1", "改善点2"]
}}
"""

        try:
            response = await self.ai_query(
                service="create",
                user_message=prompt,
                user_id="ai_tester",
                task_name="evaluate_output"
            )

            import re
            json_match = re.search(r'\{.*\}', response, re.DOTALL)
            if json_match:
                eval_data = json.loads(json_match.group())
                return (
                    eval_data.get('evaluation', '評価不明'),
                    float(eval_data.get('score', 0.5)),
                    eval_data.get('improvements', [])
                )
        except Exception as e:
            logger.error(f"評価エラー: {e}")

        return "評価エラー", 0.0, []

    def _log_result(self, result: TestResult):
        """結果をログに保存"""
        log_file = self.log_path / f"test_{datetime.now().strftime('%Y%m%d')}.jsonl"
        with open(log_file, "a", encoding="utf-8") as f:
            data = {
                "test_case": asdict(result.test_case),
                "actual_output": result.actual_output,
                "evaluation": result.evaluation,
                "score": result.score,
                "improvement_suggestions": result.improvement_suggestions,
                "timestamp": result.timestamp
            }
            f.write(json.dumps(data, ensure_ascii=False, default=str) + "\n")

    def extract_improvements(
        self,
        results: list[TestResult] = None
    ) -> dict:
        """
        改善点を抽出・集約

        Returns:
            {
                "low_score_cases": [...],  # スコアが低いケース
                "common_issues": [...],     # 共通の問題
                "persona_issues": {...}     # ペルソナ別の問題
            }
        """
        if results is None:
            results = self.results

        # スコアが低いケース
        low_score = [r for r in results if r.score < 0.7]

        # 改善提案を集約
        all_suggestions = []
        for r in results:
            all_suggestions.extend(r.improvement_suggestions)

        # 共通の問題（複数回出現）
        from collections import Counter
        suggestion_counts = Counter(all_suggestions)
        common_issues = [
            s for s, count in suggestion_counts.items()
            if count >= 2
        ]

        # ペルソナ別
        persona_issues = {}
        for r in results:
            persona = r.test_case.persona
            if persona not in persona_issues:
                persona_issues[persona] = {
                    "avg_score": 0,
                    "count": 0,
                    "issues": []
                }
            persona_issues[persona]["count"] += 1
            persona_issues[persona]["avg_score"] += r.score
            persona_issues[persona]["issues"].extend(r.improvement_suggestions)

        for persona in persona_issues:
            count = persona_issues[persona]["count"]
            persona_issues[persona]["avg_score"] /= count

        return {
            "low_score_cases": [
                {
                    "persona": r.test_case.persona,
                    "scenario": r.test_case.scenario,
                    "score": r.score,
                    "evaluation": r.evaluation
                }
                for r in low_score
            ],
            "common_issues": common_issues,
            "persona_issues": persona_issues
        }

    def get_stats(self) -> dict:
        """統計情報を取得"""
        if not self.results:
            return {"count": 0}

        scores = [r.score for r in self.results]
        return {
            "count": len(self.results),
            "avg_score": sum(scores) / len(scores),
            "min_score": min(scores),
            "max_score": max(scores),
            "pass_rate": len([s for s in scores if s >= 0.7]) / len(scores)
        }
