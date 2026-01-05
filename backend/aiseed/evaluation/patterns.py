"""
パターン抽出モジュール

AIの出力からパターンを抽出し、ルールベース実装の元データを作成する

開発フロー:
1. AIでたくさんの入出力を生成
2. パターンを抽出
3. テンプレート/ルールとして保存
4. 公開版で使用
"""
import json
import logging
from datetime import datetime
from pathlib import Path
from typing import Callable, Any
from dataclasses import dataclass, asdict
from collections import defaultdict

logger = logging.getLogger("aiseed.evaluation")


@dataclass
class ExtractedPattern:
    """抽出されたパターン"""
    category: str
    input_pattern: str
    output_template: str
    examples: list[dict]
    confidence: float  # 0.0-1.0
    usage_count: int = 0


class PatternExtractor:
    """
    AIの出力からパターンを抽出

    使用例:
    ```python
    extractor = PatternExtractor(output_path="patterns")

    # AIで多様な入出力を生成
    samples = await extractor.generate_samples(
        feature="feedback_text",
        count=50
    )

    # パターンを抽出
    patterns = await extractor.extract_patterns(samples)

    # テンプレートファイルとして保存
    extractor.save_as_templates("templates/feedback.json")
    ```
    """

    def __init__(
        self,
        ai_query: Callable = None,
        output_path: str = "patterns"
    ):
        self.ai_query = ai_query
        self.output_path = Path(output_path)
        self.output_path.mkdir(parents=True, exist_ok=True)
        self.samples: list[dict] = []
        self.patterns: list[ExtractedPattern] = []

    async def generate_samples(
        self,
        feature: str,
        count: int = 50,
        diversity_prompts: list[str] = None
    ) -> list[dict]:
        """
        AIで多様な入出力サンプルを生成

        Args:
            feature: 機能名
            count: 生成数
            diversity_prompts: 多様性を確保するための追加プロンプト
        """
        samples = []

        # デフォルトの多様性プロンプト
        if diversity_prompts is None:
            diversity_prompts = [
                "シンプルな入力",
                "複雑な入力",
                "省略が多い入力",
                "方言混じりの入力",
                "誤字がある入力",
                "長い入力",
                "短い入力"
            ]

        per_prompt = max(1, count // len(diversity_prompts))

        for prompt_type in diversity_prompts:
            prompt = f"""
{feature}機能のサンプル入出力を{per_prompt}個生成してください。
入力の特徴: {prompt_type}

{self._get_feature_context(feature)}

JSON形式で出力:
[
  {{
    "input": "入力データ",
    "output": "期待される出力",
    "category": "カテゴリ（任意）"
  }}
]
"""
            try:
                response = await self.ai_query(
                    service="create",
                    user_message=prompt,
                    user_id="pattern_extractor",
                    task_name="generate_samples"
                )

                import re
                json_match = re.search(r'\[.*\]', response, re.DOTALL)
                if json_match:
                    batch = json.loads(json_match.group())
                    for item in batch:
                        item["prompt_type"] = prompt_type
                        samples.append(item)

            except Exception as e:
                logger.error(f"サンプル生成エラー: {e}")

        self.samples.extend(samples)
        self._save_samples(feature, samples)
        return samples

    def _get_feature_context(self, feature: str) -> str:
        """機能のコンテキストを取得"""
        contexts = {
            "feedback_text": """
Spark体験タスクのフィードバック文言。
やわらかく詩的に、ユーザーの傾向を伝える。
例: 「細かいところに目がいくあなた。それは大切な才能かもしれません。」
""",
            "shipment_parsing": """
出荷情報の自然言語解析。
入力から日付、時間、場所、商品、価格を抽出。
出力は構造化されたJSON。
""",
            "grow_observation": """
栽培観察記録の分析。
気づきを見つけ、次のアクションを提案。
やさしい言葉で伝える。
"""
        }
        return contexts.get(feature, f"{feature}機能")

    def _save_samples(self, feature: str, samples: list[dict]):
        """サンプルを保存"""
        file_path = self.output_path / f"samples_{feature}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        with open(file_path, "w", encoding="utf-8") as f:
            json.dump(samples, f, ensure_ascii=False, indent=2)

    async def extract_patterns(
        self,
        samples: list[dict] = None
    ) -> list[ExtractedPattern]:
        """
        サンプルからパターンを抽出

        AIを使って共通パターンを見つける
        """
        if samples is None:
            samples = self.samples

        if not samples:
            return []

        # カテゴリ別に分類
        by_category = defaultdict(list)
        for s in samples:
            category = s.get("category", "general")
            by_category[category].append(s)

        patterns = []

        for category, category_samples in by_category.items():
            prompt = f"""
以下のサンプル入出力からパターンを抽出してください。

カテゴリ: {category}

サンプル:
{json.dumps(category_samples[:10], ensure_ascii=False, indent=2)}

以下の形式でパターンを抽出:
[
  {{
    "input_pattern": "入力のパターン（{{変数}}で置換可能な部分を示す）",
    "output_template": "出力のテンプレート（{{変数}}で置換可能な部分を示す）",
    "variables": ["変数1", "変数2"],
    "confidence": 0.8
  }}
]

できるだけ汎用的なパターンを見つけてください。
"""

            try:
                response = await self.ai_query(
                    service="create",
                    user_message=prompt,
                    user_id="pattern_extractor",
                    task_name="extract_patterns"
                )

                import re
                json_match = re.search(r'\[.*\]', response, re.DOTALL)
                if json_match:
                    pattern_data = json.loads(json_match.group())
                    for p in pattern_data:
                        patterns.append(ExtractedPattern(
                            category=category,
                            input_pattern=p.get("input_pattern", ""),
                            output_template=p.get("output_template", ""),
                            examples=category_samples[:3],
                            confidence=float(p.get("confidence", 0.5))
                        ))

            except Exception as e:
                logger.error(f"パターン抽出エラー ({category}): {e}")

        self.patterns = patterns
        return patterns

    def save_as_templates(
        self,
        output_file: str,
        min_confidence: float = 0.7
    ) -> str:
        """
        パターンをテンプレートファイルとして保存

        公開版で使用できる形式で出力
        """
        templates = []
        for p in self.patterns:
            if p.confidence >= min_confidence:
                templates.append({
                    "category": p.category,
                    "input_pattern": p.input_pattern,
                    "output_template": p.output_template,
                    "examples": p.examples[:2]
                })

        output_path = Path(output_file)
        output_path.parent.mkdir(parents=True, exist_ok=True)

        with open(output_path, "w", encoding="utf-8") as f:
            json.dump(templates, f, ensure_ascii=False, indent=2)

        logger.info(f"テンプレート保存: {output_file} ({len(templates)}件)")
        return str(output_path)

    def generate_rule_code(self, feature: str) -> str:
        """
        パターンからルールベース実装のコードを生成

        公開版での置き換え用コードを自動生成
        """
        code_lines = [
            f'"""\nルールベース実装: {feature}\n',
            f"自動生成: {datetime.now().isoformat()}\n",
            f"パターン数: {len(self.patterns)}\n",
            '"""\n\n',
            'import re\n',
            'from typing import Optional, Any\n\n',
        ]

        # テンプレート定義
        code_lines.append("# テンプレート定義\n")
        code_lines.append("TEMPLATES = {\n")
        for p in self.patterns:
            code_lines.append(f'    "{p.category}": {{\n')
            code_lines.append(f'        "pattern": r"{p.input_pattern}",\n')
            code_lines.append(f'        "template": """{p.output_template}""",\n')
            code_lines.append("    },\n")
        code_lines.append("}\n\n")

        # マッチング関数
        code_lines.append(f"def {feature}_rule_based(input_data: dict) -> Optional[Any]:\n")
        code_lines.append('    """ルールベース処理"""\n')
        code_lines.append('    text = input_data.get("text", "")\n\n')
        code_lines.append("    for category, config in TEMPLATES.items():\n")
        code_lines.append('        match = re.search(config["pattern"], text)\n')
        code_lines.append("        if match:\n")
        code_lines.append('            return config["template"].format(**match.groupdict())\n\n')
        code_lines.append("    return None  # マッチしない場合\n")

        return "".join(code_lines)

    def get_stats(self) -> dict:
        """統計情報を取得"""
        return {
            "sample_count": len(self.samples),
            "pattern_count": len(self.patterns),
            "avg_confidence": (
                sum(p.confidence for p in self.patterns) / len(self.patterns)
                if self.patterns else 0
            ),
            "categories": list(set(p.category for p in self.patterns))
        }
