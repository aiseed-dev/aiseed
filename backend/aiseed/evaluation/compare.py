"""
レスポンス比較モジュール

AIバージョンとルールベースバージョンの出力を比較・評価する
"""
import json
import logging
from datetime import datetime
from pathlib import Path
from typing import Callable, Optional, Any
from dataclasses import dataclass, asdict

logger = logging.getLogger("aiseed.evaluation")


@dataclass
class ComparisonResult:
    """比較結果"""
    input_data: dict
    ai_response: Any
    rule_response: Any
    ai_time_ms: float
    rule_time_ms: float
    match_score: float  # 0.0-1.0
    evaluation: Optional[str] = None  # AIテスターによる評価
    timestamp: str = ""

    def __post_init__(self):
        if not self.timestamp:
            self.timestamp = datetime.now().isoformat()


class ResponseComparer:
    """
    AIバージョンとルールベースバージョンのレスポンスを比較

    使用例:
    ```python
    comparer = ResponseComparer(log_path="comparison_logs")

    # AIバージョン
    async def ai_handler(input):
        return await agent.chat(...)

    # ルールベースバージョン
    def rule_handler(input):
        return template_response(...)

    # 比較実行
    result = await comparer.compare(
        input_data={"message": "トマト100円"},
        ai_handler=ai_handler,
        rule_handler=rule_handler
    )
    ```
    """

    def __init__(self, log_path: str = "comparison_logs"):
        self.log_path = Path(log_path)
        self.log_path.mkdir(parents=True, exist_ok=True)
        self.results: list[ComparisonResult] = []

    async def compare(
        self,
        input_data: dict,
        ai_handler: Callable,
        rule_handler: Callable,
        evaluator: Optional[Callable] = None
    ) -> ComparisonResult:
        """
        AIとルールベースを両方実行して比較

        Args:
            input_data: 入力データ
            ai_handler: AI処理関数（async）
            rule_handler: ルールベース処理関数
            evaluator: 評価関数（任意）
        """
        import asyncio
        import time

        # AI実行
        ai_start = time.perf_counter()
        try:
            if asyncio.iscoroutinefunction(ai_handler):
                ai_response = await ai_handler(input_data)
            else:
                ai_response = ai_handler(input_data)
        except Exception as e:
            ai_response = {"error": str(e)}
        ai_time = (time.perf_counter() - ai_start) * 1000

        # ルールベース実行
        rule_start = time.perf_counter()
        try:
            if asyncio.iscoroutinefunction(rule_handler):
                rule_response = await rule_handler(input_data)
            else:
                rule_response = rule_handler(input_data)
        except Exception as e:
            rule_response = {"error": str(e)}
        rule_time = (time.perf_counter() - rule_start) * 1000

        # 一致度計算
        match_score = self._calculate_match_score(ai_response, rule_response)

        # 評価（オプション）
        evaluation = None
        if evaluator:
            try:
                evaluation = await evaluator(input_data, ai_response, rule_response)
            except Exception as e:
                evaluation = f"評価エラー: {e}"

        result = ComparisonResult(
            input_data=input_data,
            ai_response=ai_response,
            rule_response=rule_response,
            ai_time_ms=ai_time,
            rule_time_ms=rule_time,
            match_score=match_score,
            evaluation=evaluation
        )

        self.results.append(result)
        self._log_result(result)

        return result

    def _calculate_match_score(self, ai_response: Any, rule_response: Any) -> float:
        """一致度を計算（0.0-1.0）"""
        if ai_response == rule_response:
            return 1.0

        # 両方が辞書の場合
        if isinstance(ai_response, dict) and isinstance(rule_response, dict):
            if not ai_response or not rule_response:
                return 0.0
            common_keys = set(ai_response.keys()) & set(rule_response.keys())
            if not common_keys:
                return 0.0
            matches = sum(
                1 for k in common_keys
                if ai_response.get(k) == rule_response.get(k)
            )
            return matches / max(len(ai_response), len(rule_response))

        # 両方が文字列の場合
        if isinstance(ai_response, str) and isinstance(rule_response, str):
            # 簡易的な類似度（共通単語の割合）
            ai_words = set(ai_response.split())
            rule_words = set(rule_response.split())
            if not ai_words or not rule_words:
                return 0.0
            common = ai_words & rule_words
            return len(common) / max(len(ai_words), len(rule_words))

        return 0.0

    def _log_result(self, result: ComparisonResult):
        """結果をログファイルに保存"""
        log_file = self.log_path / f"comparison_{datetime.now().strftime('%Y%m%d')}.jsonl"
        with open(log_file, "a", encoding="utf-8") as f:
            f.write(json.dumps(asdict(result), ensure_ascii=False, default=str) + "\n")

    def get_stats(self) -> dict:
        """統計情報を取得"""
        if not self.results:
            return {"count": 0}

        scores = [r.match_score for r in self.results]
        ai_times = [r.ai_time_ms for r in self.results]
        rule_times = [r.rule_time_ms for r in self.results]

        return {
            "count": len(self.results),
            "avg_match_score": sum(scores) / len(scores),
            "min_match_score": min(scores),
            "max_match_score": max(scores),
            "avg_ai_time_ms": sum(ai_times) / len(ai_times),
            "avg_rule_time_ms": sum(rule_times) / len(rule_times),
            "speedup": sum(ai_times) / sum(rule_times) if sum(rule_times) > 0 else 0,
        }

    def export_for_review(self, output_path: str = "review_data.json"):
        """レビュー用にエクスポート"""
        with open(output_path, "w", encoding="utf-8") as f:
            json.dump(
                [asdict(r) for r in self.results],
                f,
                ensure_ascii=False,
                indent=2,
                default=str
            )
        return output_path
