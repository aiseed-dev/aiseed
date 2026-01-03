#!/usr/bin/env python3
"""
AIseed API テストスクリプト

3サービス構成:
- Spark: 自分を知る
- Grow: 自然と向き合い、育てる
- Create: BYOA - あなたのAIで創る

使用方法:
    # オフラインテスト（サーバー不要）
    python test_api.py --config     # 設定確認
    python test_api.py --modules    # モジュール確認
    python test_api.py --offline    # 全オフラインテスト

    # APIテスト（サーバー必要）
    python test_api.py              # Gateway経由
    python test_api.py --direct     # API直接
    python test_api.py --spark      # Sparkおしゃべり
    python test_api.py --experience # Spark体験
    python test_api.py --grow       # Grow
    python test_api.py --create     # Create
    python test_api.py --all        # 全サービス
"""
import sys
import os

# パスを追加（configモジュールのため）
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import json
import uuid

# テスト対象
GATEWAY_URL = "http://localhost:8000"
API_URL = "http://localhost:8001"


# ===========================================
# オフラインテスト（サーバー不要）
# ===========================================

def test_config():
    """設定ファイルの確認（オフライン）"""
    print("=== 設定確認テスト ===\n")

    try:
        from config import (
            AI_PROVIDERS,
            CURRENT_PROVIDER,
            MODEL_ASSIGNMENT,
            TASK_CLASSIFICATION,
            LOG_LEVELS,
            SERVER,
            MEMORY,
            get_model_id,
            get_model_info,
        )
        print("✓ config モジュール読み込み成功\n")

        # プロバイダー設定
        print("--- AI Providers ---")
        for provider, info in AI_PROVIDERS.items():
            print(f"  {provider}: {info['name']}")
            for model_key, model_id in info['models'].items():
                marker = " (default)" if model_key == info['default_model'] else ""
                print(f"    - {model_key}: {model_id}{marker}")
        print(f"\n  現在のプロバイダー: {CURRENT_PROVIDER}\n")

        # モデル割り当て
        print("--- Model Assignment ---")
        for task_type, model_key in MODEL_ASSIGNMENT.items():
            print(f"  {task_type}: {model_key}")
        print()

        # タスク分類
        print("--- Task Classification ---")
        by_type = {}
        for task, task_type in TASK_CLASSIFICATION.items():
            by_type.setdefault(task_type, []).append(task)

        for task_type in ["heavy", "medium", "light"]:
            tasks = by_type.get(task_type, [])
            print(f"  {task_type}:")
            for task in tasks:
                model_info = get_model_info(task)
                print(f"    - {task} → {model_info['model_key']}")
        print()

        # ログ設定
        print("--- Log Levels ---")
        for logger, level in LOG_LEVELS.items():
            print(f"  {logger}: {level}")
        print()

        # サーバー設定
        print("--- Server ---")
        print(f"  Host: {SERVER['host']}")
        print(f"  Port: {SERVER['port']}")
        print()

        # メモリ設定
        print("--- Memory ---")
        print(f"  Base Path: {MEMORY['base_path']}")
        print()

        # 関数テスト
        print("--- Function Tests ---")
        test_tasks = ["spark_conversation", "grow_conversation", "health_check"]
        for task in test_tasks:
            info = get_model_info(task)
            print(f"  get_model_info('{task}'):")
            print(f"    → provider={info['provider']}, model={info['model_key']}, type={info['task_type']}")
        print()

        return True

    except Exception as e:
        print(f"✗ エラー: {e}")
        import traceback
        traceback.print_exc()
        return False


def test_modules():
    """モジュールのインポート確認（オフライン）"""
    print("=== モジュール確認テスト ===\n")

    modules_to_test = [
        ("config", "設定"),
        ("config.settings", "設定値"),
        ("config.logging", "ログ"),
        ("agent.core", "エージェント"),
        ("agent.prompts", "プロンプト"),
        ("agent.tools", "ツール"),
        ("agent.tools.experience", "体験タスク"),
        ("memory.store", "メモリ"),
    ]

    success_count = 0
    for module_name, description in modules_to_test:
        try:
            module = __import__(module_name, fromlist=[''])
            print(f"✓ {module_name} ({description})")

            # モジュールの主要な属性を表示
            attrs = [a for a in dir(module) if not a.startswith('_')]
            if len(attrs) > 0:
                preview = attrs[:5]
                more = f" ... (+{len(attrs)-5})" if len(attrs) > 5 else ""
                print(f"    exports: {', '.join(preview)}{more}")

            success_count += 1
        except Exception as e:
            print(f"✗ {module_name} ({description})")
            print(f"    エラー: {e}")

    print(f"\n結果: {success_count}/{len(modules_to_test)} モジュール成功\n")
    return success_count == len(modules_to_test)


def test_prompts():
    """プロンプト確認（オフライン）"""
    print("=== プロンプト確認テスト ===\n")

    try:
        from agent.prompts import PROMPTS, SERVICES, get_prompt, get_service_info
        print("✓ prompts モジュール読み込み成功\n")

        print("--- Services ---")
        for service_id, info in SERVICES.items():
            print(f"\n  {service_id}: {info['name']}")
            print(f"    {info['description']}")

        print("\n--- Prompts ---")
        for service in SERVICES.keys():
            prompt = get_prompt(service)
            preview = prompt[:100].replace('\n', ' ')
            print(f"\n  [{service}]")
            print(f"    {preview}...")
            print(f"    (全{len(prompt)}文字)")

        return True

    except Exception as e:
        print(f"✗ エラー: {e}")
        import traceback
        traceback.print_exc()
        return False


def test_experience_tasks():
    """体験タスク確認（オフライン）"""
    print("=== 体験タスク確認テスト ===\n")

    try:
        from agent.tools.experience import TASKS, TASK_ORDER, SparkExperience
        print("✓ experience モジュール読み込み成功\n")

        print("--- タスク一覧 ---")
        for i, task_id in enumerate(TASK_ORDER, 1):
            task = TASKS[task_id]
            print(f"\n  {i}. {task_id}: {task['name']}")
            print(f"     タイプ: {task['type']}")
            print(f"     説明: {task['description'][:50]}...")

        print(f"\n合計: {len(TASK_ORDER)} タスク\n")
        return True

    except Exception as e:
        print(f"✗ エラー: {e}")
        import traceback
        traceback.print_exc()
        return False


def test_offline():
    """全オフラインテスト"""
    print("=== 全オフラインテスト ===\n")
    print("サーバーを起動せずにテストできる項目を確認します。\n")

    results = []

    print("="*50)
    results.append(("設定", test_config()))

    print("="*50)
    results.append(("モジュール", test_modules()))

    print("="*50)
    results.append(("プロンプト", test_prompts()))

    print("="*50)
    results.append(("体験タスク", test_experience_tasks()))

    # サマリー
    print("="*50)
    print("\n=== オフラインテスト結果 ===\n")
    for name, success in results:
        status = "✓ 成功" if success else "✗ 失敗"
        print(f"  {name}: {status}")

    success_count = sum(1 for _, s in results if s)
    print(f"\n結果: {success_count}/{len(results)} テスト成功")

    return all(s for _, s in results)


# ===========================================
# APIテスト（サーバー必要）
# ===========================================

def print_response(response, max_chars=200):
    """レスポンスを整形して表示"""
    print(f"Status: {response.status_code}")
    if response.status_code == 200:
        try:
            data = response.json()
            formatted = json.dumps(data, indent=2, ensure_ascii=False)
            if len(formatted) > max_chars:
                print(f"Response: {formatted[:max_chars]}...")
            else:
                print(f"Response: {formatted}")
        except:
            print(f"Response: {response.text[:max_chars]}...")
    else:
        print(f"Error: {response.text}")
    print()


def test_gateway():
    """Gateway経由のテスト"""
    print("=== Gateway テスト ===\n")

    # ルート
    print("--- ルートエンドポイント ---")
    response = requests.get(f"{GATEWAY_URL}/")
    print_response(response)

    # ヘルスチェック
    print("--- ヘルスチェック ---")
    response = requests.get(f"{GATEWAY_URL}/health")
    print_response(response)

    # APIキー作成
    print("--- APIキー作成 ---")
    payload = {"user_id": "test_user", "plan": "free"}
    response = requests.post(f"{GATEWAY_URL}/admin/api-keys", json=payload)
    print_response(response)

    if response.status_code == 200:
        data = response.json()
        api_key = data['api_key']

        # 統計情報
        print("--- 統計情報 ---")
        response = requests.get(f"{GATEWAY_URL}/admin/stats")
        print_response(response)

        # v1 API（認証）
        print("--- v1 API 会話テスト (認証あり) ---")
        headers = {"X-API-Key": api_key}
        payload = {
            "user_message": "こんにちは！",
            "conversation_history": [],
            "user_id": "test_user"
        }
        response = requests.post(
            f"{GATEWAY_URL}/v1/spark/conversation",
            json=payload,
            headers=headers
        )
        print_response(response)


def test_api_direct():
    """API直接テスト"""
    print("=== API直接テスト ===\n")

    # ヘルスチェック
    print("--- ヘルスチェック ---")
    response = requests.get(f"{API_URL}/health")
    print_response(response)

    # Spark会話
    print("--- Spark 会話テスト ---")
    user_id = f"test_{uuid.uuid4().hex[:8]}"
    session_id = f"session_{uuid.uuid4().hex[:8]}"

    payload = {
        "user_message": "こんにちは、私の強みを見つけてください",
        "conversation_history": [],
        "user_id": user_id,
        "session_id": session_id
    }
    response = requests.post(f"{API_URL}/internal/spark/conversation", json=payload)
    print_response(response)

    # ユーザープロファイル
    print(f"--- ユーザープロファイル ({user_id}) ---")
    response = requests.get(f"{API_URL}/internal/user/{user_id}/profile")
    print_response(response)


def test_spark_flow():
    """Sparkの会話フローテスト - 自分を知る"""
    print("=== Spark 会話フローテスト ===")
    print("テーマ: 自分を知る\n")

    user_id = f"spark_test_{uuid.uuid4().hex[:8]}"
    session_id = f"session_{uuid.uuid4().hex[:8]}"
    conversation_history = []

    # Sparkで聞く質問のシミュレーション
    test_messages = [
        "こんにちは！",
        "今は会社員として働いています。IT関係の仕事をしています。",
        "最近はプログラミングに夢中です。特にPythonが好きで、時間を忘れて書いていることがあります。",
        "周りからは『説明が分かりやすい』と言われることがあります。新しいことを教えるのが好きなんです。",
        "困った時はまず自分で調べます。ネットで情報を集めて、試行錯誤するタイプです。",
        "チームでは、みんなの意見をまとめる役割になることが多いです。"
    ]

    for i, message in enumerate(test_messages, 1):
        print(f"--- 会話 {i}/{len(test_messages)} ---")
        print(f"User: {message}")

        payload = {
            "user_message": message,
            "conversation_history": conversation_history,
            "user_id": user_id,
            "session_id": session_id
        }

        response = requests.post(f"{API_URL}/internal/spark/conversation", json=payload)

        if response.status_code == 200:
            data = response.json()
            ai_message = data['ai_message']
            print(f"AI: {ai_message[:150]}..." if len(ai_message) > 150 else f"AI: {ai_message}")

            # 会話履歴に追加
            conversation_history.append({"role": "user", "content": message})
            conversation_history.append({"role": "assistant", "content": ai_message})
        else:
            print(f"Error: {response.text}")
            break

        print()

    # 最終的なプロファイルを確認
    print("--- 最終プロファイル ---")
    response = requests.get(f"{API_URL}/internal/user/{user_id}/profile")
    print_response(response, max_chars=500)

    # スキル生成を試みる
    print("--- スキル生成 (BYOA) ---")
    payload = {
        "user_id": user_id,
        "skill_type": "spark"
    }
    response = requests.post(f"{API_URL}/internal/skill/generate", json=payload)
    print_response(response, max_chars=1000)

    return user_id


def test_grow_flow():
    """Growの会話フローテスト - 自然と向き合い、育てる"""
    print("=== Grow 会話フローテスト ===")
    print("テーマ: 野菜・子ども・自分を育てる\n")

    user_id = f"grow_test_{uuid.uuid4().hex[:8]}"
    session_id = f"session_{uuid.uuid4().hex[:8]}"
    conversation_history = []

    # Growで聞く質問のシミュレーション
    test_messages = [
        "こんにちは！野菜を育ててみたいんですが。",
        "ベランダで育てられる野菜はありますか？初心者です。",
        "子どもと一緒に育てられるものがいいです。5歳の子がいます。",
        "トマトを育ててみたいです。どうすればいいですか？",
    ]

    for i, message in enumerate(test_messages, 1):
        print(f"--- 会話 {i}/{len(test_messages)} ---")
        print(f"User: {message}")

        payload = {
            "user_message": message,
            "conversation_history": conversation_history,
            "user_id": user_id,
            "session_id": session_id
        }

        response = requests.post(f"{API_URL}/internal/grow/conversation", json=payload)

        if response.status_code == 200:
            data = response.json()
            ai_message = data['ai_message']
            print(f"AI: {ai_message[:150]}..." if len(ai_message) > 150 else f"AI: {ai_message}")

            conversation_history.append({"role": "user", "content": message})
            conversation_history.append({"role": "assistant", "content": ai_message})
        else:
            print(f"Error: {response.text}")
            break

        print()

    return user_id


def test_create_flow():
    """Createの会話フローテスト - BYOA"""
    print("=== Create 会話フローテスト ===")
    print("テーマ: BYOA - あなたのAIで創る\n")

    user_id = f"create_test_{uuid.uuid4().hex[:8]}"
    session_id = f"session_{uuid.uuid4().hex[:8]}"
    conversation_history = []

    # Createで聞く質問のシミュレーション
    test_messages = [
        "新しいビジネスのキャッチコピーを作りたいです。",
        "オーガニック野菜の宅配サービスです。ターゲットは30代の共働き夫婦。",
        "シンプルで覚えやすいものがいいです。",
    ]

    for i, message in enumerate(test_messages, 1):
        print(f"--- 会話 {i}/{len(test_messages)} ---")
        print(f"User: {message}")

        payload = {
            "user_message": message,
            "conversation_history": conversation_history,
            "user_id": user_id,
            "session_id": session_id
        }

        response = requests.post(f"{API_URL}/internal/create/conversation", json=payload)

        if response.status_code == 200:
            data = response.json()
            ai_message = data['ai_message']
            print(f"AI: {ai_message[:150]}..." if len(ai_message) > 150 else f"AI: {ai_message}")

            conversation_history.append({"role": "user", "content": message})
            conversation_history.append({"role": "assistant", "content": ai_message})
        else:
            print(f"Error: {response.text}")
            break

        print()

    return user_id


def test_memory():
    """メモリ機能のテスト"""
    print("=== メモリ機能テスト ===\n")

    # まずSparkフローを実行
    user_id = test_spark_flow()

    # プロファイルを再確認
    print("\n--- プロファイル再確認 ---")
    response = requests.get(f"{API_URL}/internal/user/{user_id}/profile")
    print_response(response, max_chars=500)

    # スキル取得
    print("--- スキル取得 ---")
    response = requests.get(f"{API_URL}/internal/skill/{user_id}/spark")
    print_response(response, max_chars=1000)


def test_experience_flow():
    """Spark体験タスクのテスト - 体験で発見"""
    print("=== Spark 体験タスクテスト ===")
    print("テーマ: 🎮 体験で発見\n")

    user_id = f"exp_test_{uuid.uuid4().hex[:8]}"

    # セッション開始
    print("--- セッション開始 ---")
    payload = {"user_id": user_id}
    response = requests.post(f"{API_URL}/internal/spark/experience/start", json=payload)
    print_response(response)

    if response.status_code != 200:
        print("Error: セッション開始に失敗")
        return

    data = response.json()
    session_id = data["session_id"]
    print(f"Session ID: {session_id}")
    print(f"Message: {data.get('message', '')}\n")

    # タスク一覧を取得
    print("--- タスク一覧 ---")
    response = requests.get(f"{API_URL}/internal/spark/experience/tasks")
    print_response(response)

    # 各タスクをシミュレート
    simulated_results = [
        {
            "task_id": "observe",
            "tap_position": {"x": 0.7, "y": 0.3},  # 右上をタップ（細部注目）
            "duration_ms": 5000,
        },
        {
            "task_id": "sound",
            "selected_option": "forest",  # 森を選択（抽象的）
            "duration_ms": 3000,
        },
        {
            "task_id": "arrange",
            "arranged_positions": [
                {"id": "circle", "x": 0.2, "y": 0.2},
                {"id": "square", "x": 0.4, "y": 0.2},
                {"id": "triangle", "x": 0.6, "y": 0.2},
                {"id": "star", "x": 0.8, "y": 0.2},
                {"id": "heart", "x": 0.5, "y": 0.5},
            ],
            "duration_ms": 8000,
        },
        {
            "task_id": "story",
            "selected_option": "mountain",
            "duration_ms": 4000,
        },
        {
            "task_id": "rhythm",
            "tap_sequence": [
                {"time_ms": 0, "x": 0.5, "y": 0.5},
                {"time_ms": 500, "x": 0.5, "y": 0.5},
                {"time_ms": 1000, "x": 0.5, "y": 0.5},
                {"time_ms": 1500, "x": 0.5, "y": 0.5},
                {"time_ms": 2000, "x": 0.5, "y": 0.5},
            ],
            "duration_ms": 10000,
        },
        {
            "task_id": "color",
            "selected_color": "#45B7D1",
            "duration_ms": 2000,
        },
    ]

    for i, result in enumerate(simulated_results, 1):
        print(f"--- タスク {i}/{len(simulated_results)}: {result['task_id']} ---")

        payload = {
            "user_id": user_id,
            "session_id": session_id,
            **result
        }
        response = requests.post(f"{API_URL}/internal/spark/experience/submit", json=payload)

        if response.status_code == 200:
            data = response.json()
            status = data.get("status")
            print(f"Status: {status}")

            if status == "continue":
                next_task = data.get("next_task", {})
                print(f"Next: {next_task.get('name', 'N/A')}")
            elif status == "completed":
                print("\n--- 完了！フィードバック ---")
                feedback = data.get("feedback", {})
                print(f"Summary:\n{feedback.get('summary', '')}")
                print(f"\nTendencies: {feedback.get('tendencies', [])}")
                print(f"\nSuggestions:")
                for sug in data.get("suggestions", []):
                    print(f"  - [{sug.get('service')}] {sug.get('title')}")
        else:
            print(f"Error: {response.text}")
            break

        print()

    # プロファイルを確認
    print("--- 最終プロファイル ---")
    response = requests.get(f"{API_URL}/internal/user/{user_id}/profile")
    print_response(response, max_chars=500)

    return user_id


def test_rate_limit():
    """レート制限テスト"""
    print("=== レート制限テスト ===")
    print("6回連続でリクエストを送信（Public API: 5回/分制限）\n")

    for i in range(6):
        payload = {"user_message": f"テスト {i+1}", "conversation_history": []}
        response = requests.post(f"{GATEWAY_URL}/public/conversation", json=payload)
        print(f"リクエスト {i+1}: Status {response.status_code}")
        if response.status_code == 429:
            print(f"  → レート制限に達しました\n")
            break


def print_services():
    """サービス一覧を表示"""
    print("""
=== aiseed 3サービス ===

✨ Spark: 自分を知る
   💬 おしゃべりで発見
   🎮 体験で発見（NEW）

🌱 Grow: 自然と向き合い、育てる
   野菜・子ども・自分を育てる

🎨 Create: あなたのAIで創る
   BYOA（Bring Your Own AI）
""")


def print_help():
    """ヘルプを表示"""
    print("""
使用方法: python test_api.py [オプション]

オフラインテスト（サーバー不要）:
  --config      設定ファイルの確認
  --modules     モジュールのインポート確認
  --prompts     プロンプトの確認
  --tasks       体験タスクの確認
  --offline     全オフラインテスト

APIテスト（サーバー必要）:
  (なし)        Gateway経由テスト
  --direct      API直接テスト
  --spark       Spark会話フローテスト（💬 おしゃべり）
  --experience  Spark体験タスクテスト（🎮 体験）
  --grow        Grow会話フローテスト
  --create      Create会話フローテスト
  --memory      メモリ機能テスト
  --rate        レート制限テスト
  --compare     Spark比較テスト（おしゃべり vs 体験）
  --all         全サービステスト

その他:
  --help        このヘルプを表示
""")


if __name__ == "__main__":
    print("AIseed API テスト\n")

    # ヘルプ
    if "--help" in sys.argv or "-h" in sys.argv:
        print_help()
        sys.exit(0)

    # オフラインテストの判定
    offline_modes = ["--config", "--modules", "--prompts", "--tasks", "--offline"]
    is_offline = any(mode in sys.argv for mode in offline_modes)

    if is_offline:
        # オフラインテスト
        if "--config" in sys.argv:
            print("モード: 設定確認テスト\n")
            test_config()
        elif "--modules" in sys.argv:
            print("モード: モジュール確認テスト\n")
            test_modules()
        elif "--prompts" in sys.argv:
            print("モード: プロンプト確認テスト\n")
            test_prompts()
        elif "--tasks" in sys.argv:
            print("モード: 体験タスク確認テスト\n")
            test_experience_tasks()
        elif "--offline" in sys.argv:
            print("モード: 全オフラインテスト\n")
            test_offline()
        print("=== テスト完了 ===")
    else:
        # APIテスト（requestsが必要）
        import requests

        print_services()

        mode = "gateway"  # デフォルト
        if "--direct" in sys.argv:
            mode = "direct"
        elif "--spark" in sys.argv:
            mode = "spark"
        elif "--experience" in sys.argv:
            mode = "experience"
        elif "--grow" in sys.argv:
            mode = "grow"
        elif "--create" in sys.argv:
            mode = "create"
        elif "--memory" in sys.argv:
            mode = "memory"
        elif "--rate" in sys.argv:
            mode = "rate"
        elif "--all" in sys.argv:
            mode = "all"
        elif "--compare" in sys.argv:
            mode = "compare"

        try:
            if mode == "direct":
                print("モード: API直接テスト\n")
                test_api_direct()
            elif mode == "spark":
                print("モード: Spark会話フローテスト（💬 おしゃべり）\n")
                test_spark_flow()
            elif mode == "experience":
                print("モード: Spark体験タスクテスト（🎮 体験）\n")
                test_experience_flow()
            elif mode == "grow":
                print("モード: Grow会話フローテスト\n")
                test_grow_flow()
            elif mode == "create":
                print("モード: Create会話フローテスト\n")
                test_create_flow()
            elif mode == "memory":
                print("モード: メモリ機能テスト\n")
                test_memory()
            elif mode == "rate":
                print("モード: レート制限テスト\n")
                test_rate_limit()
            elif mode == "compare":
                print("モード: Spark比較テスト（おしゃべり vs 体験）\n")
                print("="*50)
                print("💬 おしゃべりで発見")
                print("="*50 + "\n")
                test_spark_flow()
                print("\n" + "="*50)
                print("🎮 体験で発見")
                print("="*50 + "\n")
                test_experience_flow()
            elif mode == "all":
                print("モード: 全サービステスト\n")
                test_spark_flow()
                print("\n" + "="*50 + "\n")
                test_experience_flow()
                print("\n" + "="*50 + "\n")
                test_grow_flow()
                print("\n" + "="*50 + "\n")
                test_create_flow()
            else:
                print("モード: Gateway経由テスト\n")
                print("注意: Gateway と API の両方が起動している必要があります\n")
                test_gateway()
                test_rate_limit()

            print("=== テスト完了 ===")
        except requests.exceptions.ConnectionError as e:
            print(f"エラー: サーバーに接続できません")
            if mode in ["direct", "spark", "experience", "grow", "create", "memory", "all", "compare"]:
                print(f"API Server ({API_URL}) を起動してください")
                print("起動コマンド: cd backend/aiseed && python main.py")
            else:
                print(f"Gateway ({GATEWAY_URL}) を起動してください")
        except Exception as e:
            print(f"エラー: {e}")
            import traceback
            traceback.print_exc()
