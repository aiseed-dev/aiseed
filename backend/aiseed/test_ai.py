#!/usr/bin/env python3
"""
AIseed AI Tester
AIによる自動テスト - シナリオ生成 + 品質評価

使用方法:
    # シナリオ生成テスト
    python test_ai.py --generate

    # 品質評価テスト（サーバー必要）
    python test_ai.py --evaluate

    # フルテスト（生成 + 実行 + 評価）
    python test_ai.py --full

    # 特定サービスのテスト
    python test_ai.py --service spark
    python test_ai.py --service grow
    python test_ai.py --service create
"""
import sys
import os
import json
import asyncio
from datetime import datetime
from typing import Optional

# パスを追加
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

# ===========================================
# テストシナリオ定義
# ===========================================

# ユーザーペルソナ
PERSONAS = {
    "child": {
        "name": "子ども（10歳）",
        "traits": ["好奇心旺盛", "素直", "短い文"],
        "examples": [
            "ねえねえ、なんで空は青いの？",
            "わたし絵を描くのが好き！",
            "学校で友達とケンカしちゃった...",
        ]
    },
    "teen": {
        "name": "中高生（15歳）",
        "traits": ["自己探求中", "将来への不安", "SNS世代"],
        "examples": [
            "将来何になりたいかわからない",
            "勉強する意味ってあるの？",
            "友達関係がめんどくさい",
        ]
    },
    "adult": {
        "name": "社会人（30歳）",
        "traits": ["キャリア意識", "効率重視", "ストレス"],
        "examples": [
            "仕事でうまくいかないことが多くて",
            "転職を考えているんですが",
            "もっと自分の強みを活かしたい",
        ]
    },
    "parent": {
        "name": "親（40歳）",
        "traits": ["子育て中", "バランス重視", "経験豊富"],
        "examples": [
            "子どもの才能を伸ばしてあげたい",
            "仕事と家庭の両立が大変で",
            "子どもが言うことを聞かなくて",
        ]
    },
}

# サービス別テストシナリオ
SCENARIOS = {
    "spark": {
        "name": "Spark - 自分を知る",
        "goal": "ユーザーの強み・特性を発見する",
        "test_cases": [
            {
                "id": "spark_discovery",
                "name": "強み発見",
                "persona": "adult",
                "messages": [
                    "こんにちは、自分の強みを知りたいです",
                    "IT企業でエンジニアをしています",
                    "複雑な問題を分解して考えるのが得意だと思います",
                    "チームでは相談役になることが多いです",
                ],
                "expected": ["能力の発見", "具体的なフィードバック", "次のステップ提案"]
            },
            {
                "id": "spark_child",
                "name": "子どもの強み発見",
                "persona": "child",
                "messages": [
                    "こんにちは！",
                    "わたしね、レゴで大きなお城を作ったの！",
                    "難しかったけど、何度もやり直したよ",
                    "お友達にも教えてあげたんだ",
                ],
                "expected": ["子ども向けの言葉", "褒める", "具体的な強みの言語化"]
            },
            {
                "id": "spark_uncertain",
                "name": "自信がないユーザー",
                "persona": "teen",
                "messages": [
                    "自分には何も取り柄がない気がする",
                    "勉強も運動も中途半端で",
                    "でもゲームは好きかな、RPGとか",
                    "ストーリーを考えるのが楽しい",
                ],
                "expected": ["共感", "隠れた強みの発見", "自己肯定感サポート"]
            },
        ]
    },
    "grow": {
        "name": "Grow - 育てる",
        "goal": "野菜・子ども・自分を育てるサポート",
        "test_cases": [
            {
                "id": "grow_vegetable",
                "name": "野菜栽培相談",
                "persona": "parent",
                "messages": [
                    "ベランダでトマトを育ててみたいです",
                    "初心者です。何から始めればいいですか？",
                    "子どもと一緒にやりたいんです",
                ],
                "expected": ["具体的なアドバイス", "子どもと楽しめる提案", "段階的な説明"]
            },
            {
                "id": "grow_parenting",
                "name": "子育て相談",
                "persona": "parent",
                "messages": [
                    "5歳の子どもがいるんですが",
                    "最近すぐ怒るようになって困っています",
                    "どう接したらいいでしょうか",
                ],
                "expected": ["共感", "具体的な対応策", "子どもの気持ちの解説"]
            },
        ]
    },
    "create": {
        "name": "Create - BYOA",
        "goal": "ユーザーのAIで創造をサポート",
        "test_cases": [
            {
                "id": "create_catchcopy",
                "name": "キャッチコピー作成",
                "persona": "adult",
                "messages": [
                    "新しいカフェのキャッチコピーを作りたいです",
                    "オーガニックにこだわった健康志向のカフェです",
                    "ターゲットは30代女性です",
                ],
                "expected": ["複数の案", "ターゲットに合った表現", "説明付き"]
            },
            {
                "id": "create_idea",
                "name": "アイデア出し",
                "persona": "teen",
                "messages": [
                    "文化祭の出し物を考えたい",
                    "クラスは30人くらいです",
                    "みんなが参加できるものがいいな",
                ],
                "expected": ["複数のアイデア", "実現可能性", "みんなが楽しめる提案"]
            },
        ]
    },
}

# 評価基準
EVALUATION_CRITERIA = {
    "relevance": {
        "name": "関連性",
        "description": "応答がユーザーの質問・文脈に適切に対応しているか",
        "weight": 0.25
    },
    "helpfulness": {
        "name": "有用性",
        "description": "応答がユーザーにとって役立つ情報を提供しているか",
        "weight": 0.25
    },
    "tone": {
        "name": "トーン",
        "description": "応答のトーンがユーザー（年齢・状況）に適切か",
        "weight": 0.20
    },
    "safety": {
        "name": "安全性",
        "description": "応答が安全で、有害なコンテンツを含まないか",
        "weight": 0.15
    },
    "engagement": {
        "name": "エンゲージメント",
        "description": "会話を続けたくなる応答か",
        "weight": 0.15
    },
}


# ===========================================
# シナリオ生成
# ===========================================

def generate_scenario_prompt(service: str, persona_id: str, context: str = "") -> str:
    """AIにシナリオ生成を依頼するプロンプト"""
    persona = PERSONAS.get(persona_id, PERSONAS["adult"])
    service_info = SCENARIOS.get(service, SCENARIOS["spark"])

    return f"""
あなたはテストシナリオを生成するAIです。
以下の条件でユーザーの発言を5つ生成してください。

【サービス】
{service_info['name']}
目的: {service_info['goal']}

【ユーザーペルソナ】
{persona['name']}
特徴: {', '.join(persona['traits'])}

【追加コンテキスト】
{context or 'なし'}

【出力形式】
JSON形式で出力してください：
{{
    "scenario_name": "シナリオ名",
    "messages": [
        "ユーザーの発言1",
        "ユーザーの発言2",
        "ユーザーの発言3",
        "ユーザーの発言4",
        "ユーザーの発言5"
    ],
    "expected_behavior": ["期待される応答の特徴1", "期待される応答の特徴2"]
}}
"""


def generate_evaluation_prompt(
    service: str,
    conversation: list[dict],
    persona_id: str
) -> str:
    """AIに応答品質評価を依頼するプロンプト"""
    persona = PERSONAS.get(persona_id, PERSONAS["adult"])
    service_info = SCENARIOS.get(service, SCENARIOS["spark"])

    conversation_text = "\n".join([
        f"{'ユーザー' if msg['role'] == 'user' else 'AI'}: {msg['content']}"
        for msg in conversation
    ])

    criteria_text = "\n".join([
        f"- {c['name']}: {c['description']} (重み: {c['weight']})"
        for c in EVALUATION_CRITERIA.values()
    ])

    return f"""
あなたはAI応答の品質を評価するテスターです。
以下の会話を評価してください。

【サービス】
{service_info['name']}
目的: {service_info['goal']}

【ユーザーペルソナ】
{persona['name']}
特徴: {', '.join(persona['traits'])}

【会話】
{conversation_text}

【評価基準】
{criteria_text}

【出力形式】
JSON形式で出力してください：
{{
    "scores": {{
        "relevance": 0.0-1.0,
        "helpfulness": 0.0-1.0,
        "tone": 0.0-1.0,
        "safety": 0.0-1.0,
        "engagement": 0.0-1.0
    }},
    "overall_score": 0.0-1.0,
    "strengths": ["良かった点1", "良かった点2"],
    "improvements": ["改善点1", "改善点2"],
    "critical_issues": ["重大な問題があれば記載"],
    "summary": "全体的な評価コメント"
}}
"""


# ===========================================
# テスト実行
# ===========================================

def print_scenarios():
    """定義済みシナリオを表示"""
    print("=== 定義済みテストシナリオ ===\n")

    for service_id, service in SCENARIOS.items():
        print(f"\n【{service['name']}】")
        print(f"  目的: {service['goal']}")
        print(f"  テストケース:")
        for tc in service["test_cases"]:
            persona = PERSONAS[tc["persona"]]
            print(f"    - {tc['id']}: {tc['name']}")
            print(f"      ペルソナ: {persona['name']}")
            print(f"      期待: {', '.join(tc['expected'])}")


def print_personas():
    """ペルソナ一覧を表示"""
    print("=== ユーザーペルソナ ===\n")

    for persona_id, persona in PERSONAS.items():
        print(f"\n【{persona_id}】 {persona['name']}")
        print(f"  特徴: {', '.join(persona['traits'])}")
        print(f"  例:")
        for ex in persona["examples"]:
            print(f"    - {ex}")


def print_criteria():
    """評価基準を表示"""
    print("=== 評価基準 ===\n")

    for key, criteria in EVALUATION_CRITERIA.items():
        print(f"  {criteria['name']} ({key})")
        print(f"    {criteria['description']}")
        print(f"    重み: {criteria['weight']}")
        print()


async def run_test_scenario(
    service: str,
    test_case: dict,
    api_url: str = "http://localhost:8001"
) -> dict:
    """テストシナリオを実行"""
    import aiohttp

    results = {
        "test_case": test_case["id"],
        "service": service,
        "persona": test_case["persona"],
        "conversation": [],
        "success": True,
        "errors": []
    }

    conversation_history = []

    async with aiohttp.ClientSession() as session:
        for i, message in enumerate(test_case["messages"]):
            print(f"  [{i+1}/{len(test_case['messages'])}] User: {message[:50]}...")

            payload = {
                "user_message": message,
                "conversation_history": conversation_history,
                "user_id": f"ai_tester_{test_case['id']}",
                "session_id": f"test_session_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
            }

            try:
                async with session.post(
                    f"{api_url}/internal/{service}/conversation",
                    json=payload,
                    timeout=aiohttp.ClientTimeout(total=60)
                ) as response:
                    if response.status == 200:
                        data = await response.json()
                        ai_message = data.get("ai_message", "")
                        print(f"       AI: {ai_message[:50]}...")

                        # 会話履歴に追加
                        conversation_history.append({"role": "user", "content": message})
                        conversation_history.append({"role": "assistant", "content": ai_message})

                        results["conversation"].append({
                            "role": "user",
                            "content": message
                        })
                        results["conversation"].append({
                            "role": "assistant",
                            "content": ai_message
                        })
                    else:
                        error = f"API error: {response.status}"
                        results["errors"].append(error)
                        results["success"] = False
                        print(f"       Error: {error}")

            except Exception as e:
                error = f"Request error: {str(e)}"
                results["errors"].append(error)
                results["success"] = False
                print(f"       Error: {error}")
                break

    return results


async def run_service_tests(service: str, api_url: str = "http://localhost:8001"):
    """サービスの全テストを実行"""
    print(f"\n=== {SCENARIOS[service]['name']} テスト ===\n")

    all_results = []
    for test_case in SCENARIOS[service]["test_cases"]:
        print(f"\n--- {test_case['name']} ({test_case['id']}) ---")
        result = await run_test_scenario(service, test_case, api_url)
        all_results.append(result)

    # サマリー
    success_count = sum(1 for r in all_results if r["success"])
    print(f"\n結果: {success_count}/{len(all_results)} テスト成功")

    return all_results


def print_help():
    """ヘルプを表示"""
    print("""
使用方法: python test_ai.py [オプション]

シナリオ確認（オフライン）:
  --scenarios   定義済みシナリオを表示
  --personas    ペルソナ一覧を表示
  --criteria    評価基準を表示

テスト実行（サーバー必要）:
  --service <name>  特定サービスのテスト (spark/grow/create)
  --all             全サービスのテスト

その他:
  --help        このヘルプを表示
""")


if __name__ == "__main__":
    print("AIseed AI Tester\n")

    if "--help" in sys.argv or "-h" in sys.argv:
        print_help()
        sys.exit(0)

    # オフラインモード
    if "--scenarios" in sys.argv:
        print_scenarios()
    elif "--personas" in sys.argv:
        print_personas()
    elif "--criteria" in sys.argv:
        print_criteria()

    # オンラインモード（サーバー必要）
    elif "--service" in sys.argv:
        try:
            idx = sys.argv.index("--service")
            service = sys.argv[idx + 1]
            if service not in SCENARIOS:
                print(f"Error: Unknown service '{service}'")
                print(f"Available: {', '.join(SCENARIOS.keys())}")
                sys.exit(1)

            asyncio.run(run_service_tests(service))
        except (IndexError, ValueError):
            print("Error: --service requires a service name")
            sys.exit(1)
        except Exception as e:
            print(f"Error: {e}")
            print("APIサーバーが起動していることを確認してください")

    elif "--all" in sys.argv:
        async def run_all():
            for service in SCENARIOS.keys():
                await run_service_tests(service)

        try:
            asyncio.run(run_all())
        except Exception as e:
            print(f"Error: {e}")
            print("APIサーバーが起動していることを確認してください")

    else:
        # デフォルト: シナリオ表示
        print("モード: シナリオ確認\n")
        print_scenarios()
        print("\n" + "="*50)
        print("\nテストを実行するには:")
        print("  python test_ai.py --service spark")
        print("  python test_ai.py --all")
