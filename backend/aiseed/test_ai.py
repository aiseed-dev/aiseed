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
        "name": "Grow 🌱 育てる - 栽培・遊び",
        "goal": "親子で楽しむ栽培体験と遊びのサポート",
        "test_cases": [
            # === 栽培（親子向け） ===
            {
                "id": "grow_vegetable",
                "name": "親子で野菜栽培",
                "persona": "parent",
                "messages": [
                    "ベランダでトマトを育ててみたいです",
                    "初心者です。何から始めればいいですか？",
                    "5歳の子どもと一緒にやりたいんです",
                ],
                "expected": ["具体的なアドバイス", "子どもと楽しめる提案", "年齢に合わせた役割分担"]
            },
            {
                "id": "grow_observe",
                "name": "観察日記サポート",
                "persona": "child",
                "messages": [
                    "あさがおを育ててるの！",
                    "毎日見てるけど、変わらないよ？",
                    "どこを見たらいいの？",
                ],
                "expected": ["観察ポイントの説明", "楽しい発見の促し", "子ども向けの言葉"]
            },
            # === 遊び（親子向け） ===
            {
                "id": "grow_play_indoor",
                "name": "室内遊び提案",
                "persona": "parent",
                "messages": [
                    "雨の日に4歳の子どもと何して遊べますか？",
                    "あまりお金をかけずにできることがいいです",
                    "家にあるものでできる遊びを教えてください",
                ],
                "expected": ["具体的な遊びの提案", "準備物のリスト", "年齢に合った難易度"]
            },
            {
                "id": "grow_play_outdoor",
                "name": "外遊び提案",
                "persona": "parent",
                "messages": [
                    "公園で6歳と3歳の子どもと遊ぶんですが",
                    "二人とも楽しめる遊びありますか？",
                    "ボールは持っています",
                ],
                "expected": ["年齢差を考慮した提案", "安全への配慮", "親も参加できる遊び"]
            },
            {
                "id": "grow_play_creative",
                "name": "工作遊び",
                "persona": "child",
                "messages": [
                    "なにか作りたい！",
                    "ダンボールがあるよ",
                    "かっこいいのがいい！",
                ],
                "expected": ["子どもの興味を引く提案", "段階的な手順", "達成感を得られる工夫"]
            },
            {
                "id": "grow_play_learning",
                "name": "遊びながら学習",
                "persona": "parent",
                "messages": [
                    "5歳の子に数を教えたいんですが",
                    "勉強っぽくなると嫌がります",
                    "遊びの中で自然に学べる方法ありますか？",
                ],
                "expected": ["遊びと学習の融合", "具体的なゲーム提案", "無理強いしない姿勢"]
            },
            # === リアル質問（自然農グループ風） ===
            {
                "id": "grow_real_tomato_disease",
                "name": "[リアル] トマトの病気",
                "source": "自然農グループ",
                "persona": "adult",
                "messages": [
                    "トマトの葉が下から黄色くなってきました",
                    "農薬は使いたくないんですが、何か対策ありますか？",
                    "自然農法で育てています",
                ],
                "images": [
                    # 画像パス（実際のFacebook投稿から取得時に追加）
                    # "test_data/grow/tomato_yellow_leaf_01.jpg",
                ],
                "expected": ["病気の可能性の説明", "自然な対処法", "予防策"]
            },
            {
                "id": "grow_real_companion",
                "name": "[リアル] コンパニオンプランツ",
                "source": "自然農グループ",
                "persona": "adult",
                "messages": [
                    "コンパニオンプランツって本当に効果ありますか？",
                    "トマトとバジルを一緒に植えようと思っています",
                    "他におすすめの組み合わせがあれば教えてください",
                ],
                "expected": ["科学的根拠の説明", "具体的な組み合わせ例", "注意点"]
            },
            {
                "id": "grow_real_beginner_sept",
                "name": "[リアル] 9月からの野菜",
                "source": "家庭菜園グループ",
                "persona": "adult",
                "messages": [
                    "9月から始められる野菜って何がありますか？",
                    "マンションのベランダで、日当たりは半日程度です",
                    "初心者なので失敗しにくいものがいいです",
                ],
                "expected": ["時期に合った野菜の提案", "条件に合わせた選択", "初心者向けアドバイス"]
            },
            {
                "id": "grow_real_pest_natural",
                "name": "[リアル] 自然な虫除け",
                "source": "自然農グループ",
                "persona": "parent",
                "messages": [
                    "子どもと一緒に野菜を育てているんですが",
                    "虫がついてきて困っています",
                    "子どもに安全な虫除けの方法を教えてください",
                ],
                "expected": ["安全な方法の提案", "子どもと一緒にできる対策", "具体的な手順"]
            },
            # === リアル質問（子育て・遊びグループ風） ===
            {
                "id": "grow_real_rainy_day",
                "name": "[リアル] 雨の日の過ごし方",
                "source": "子育て遊びグループ",
                "persona": "parent",
                "messages": [
                    "雨の日が続いて子どもが暇を持て余してます",
                    "3歳なんですが、一人遊びがまだ難しくて",
                    "テレビ以外で楽しめることありますか？",
                ],
                "expected": ["共感", "年齢に合った遊び提案", "親子で楽しめるアイデア"]
            },
            {
                "id": "grow_real_screen_time",
                "name": "[リアル] スクリーンタイム代替",
                "source": "子育て遊びグループ",
                "persona": "parent",
                "messages": [
                    "4歳の子がYouTubeばかり見たがります",
                    "やめさせると癇癪を起こすんです",
                    "YouTubeより楽しい遊びってありますか？",
                ],
                "expected": ["共感", "魅力的な代替遊び提案", "段階的な切り替え方法"]
            },
            {
                "id": "grow_real_sibling_play",
                "name": "[リアル] きょうだいで遊ぶ",
                "source": "子育て遊びグループ",
                "persona": "parent",
                "messages": [
                    "6歳と3歳のきょうだいがいます",
                    "年齢差があって一緒に遊べるものが少なくて",
                    "二人で仲良く遊べる遊びを教えてください",
                ],
                "expected": ["年齢差を考慮した遊び", "上の子の役割提案", "安全への配慮"]
            },
            {
                "id": "grow_real_nature_play",
                "name": "[リアル] 自然遊び",
                "source": "子育て遊びグループ",
                "persona": "parent",
                "messages": [
                    "虫や植物に興味がある5歳の息子がいます",
                    "公園で自然遊びをしたいんですが",
                    "どんなことをすると楽しいですか？",
                ],
                "expected": ["自然観察の提案", "安全な虫・植物の紹介", "親子で楽しめる活動"]
            },
            # === 画像付きリアル質問 ===
            {
                "id": "grow_img_pest_identify",
                "name": "[画像] 害虫の特定",
                "source": "自然農グループ",
                "persona": "adult",
                "messages": [
                    "この虫は何でしょうか？",
                    "葉っぱについていたんですが、駆除した方がいいですか？",
                ],
                "images": [
                    # "test_data/grow/pest_01.jpg",
                ],
                "expected": ["虫の特定", "益虫/害虫の判断", "対処法"]
            },
            {
                "id": "grow_img_disease_diagnosis",
                "name": "[画像] 病気診断",
                "source": "家庭菜園グループ",
                "persona": "adult",
                "messages": [
                    "キュウリの葉にこんな斑点が出てきました",
                    "これは病気ですか？何か対策はありますか？",
                ],
                "images": [
                    # "test_data/grow/cucumber_spots_01.jpg",
                ],
                "expected": ["病気の可能性", "原因の説明", "治療・予防策"]
            },
            {
                "id": "grow_img_growth_check",
                "name": "[画像] 生育確認",
                "source": "家庭菜園グループ",
                "persona": "parent",
                "messages": [
                    "トマトを植えて2週間です",
                    "順調に育っていますか？何かした方がいいことありますか？",
                ],
                "images": [
                    # "test_data/grow/tomato_seedling_01.jpg",
                ],
                "expected": ["生育状況の評価", "次のステップのアドバイス", "注意点"]
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

        # 合成、リアル（テキスト）、リアル（画像付き）を分けて表示
        synthetic = [tc for tc in service["test_cases"] if "source" not in tc]
        real_text = [tc for tc in service["test_cases"]
                     if "source" in tc and "images" not in tc]
        real_image = [tc for tc in service["test_cases"]
                      if "source" in tc and "images" in tc]

        if synthetic:
            print(f"  テストケース（合成）:")
            for tc in synthetic:
                persona = PERSONAS[tc["persona"]]
                print(f"    - {tc['id']}: {tc['name']}")
                print(f"      ペルソナ: {persona['name']}")

        if real_text:
            print(f"  テストケース（リアル質問）:")
            for tc in real_text:
                persona = PERSONAS[tc["persona"]]
                print(f"    - {tc['id']}: {tc['name']}")
                print(f"      ソース: {tc['source']} / ペルソナ: {persona['name']}")

        if real_image:
            print(f"  テストケース（画像付き）:")
            for tc in real_image:
                persona = PERSONAS[tc["persona"]]
                img_count = len([i for i in tc.get("images", []) if i])
                img_status = f"{img_count}枚" if img_count > 0 else "未設定"
                print(f"    - {tc['id']}: {tc['name']} [{img_status}]")
                print(f"      ソース: {tc['source']} / ペルソナ: {persona['name']}")


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
