#!/usr/bin/env python3
"""
AIseed API テストスクリプト

3サービス構成:
- Spark: 自分を知る
- Grow: 自然と向き合い、育てる
- Create: BYOA - あなたのAIで創る

使用方法:
    # Gateway経由でテスト
    python test_api.py

    # API直接テスト
    python test_api.py --direct

    # Sparkテスト
    python test_api.py --spark

    # Growテスト
    python test_api.py --grow

    # Createテスト
    python test_api.py --create
"""
import requests
import json
import sys
import uuid

# テスト対象
GATEWAY_URL = "http://localhost:8000"
API_URL = "http://localhost:8001"

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
   対話から能力と「らしさ」を発見

🌱 Grow: 自然と向き合い、育てる
   野菜・子ども・自分を育てる

🎨 Create: あなたのAIで創る
   BYOA（Bring Your Own AI）
""")


if __name__ == "__main__":
    print("AIseed API テスト\n")
    print_services()

    mode = "gateway"  # デフォルト
    if "--direct" in sys.argv:
        mode = "direct"
    elif "--spark" in sys.argv:
        mode = "spark"
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

    try:
        if mode == "direct":
            print("モード: API直接テスト\n")
            test_api_direct()
        elif mode == "spark":
            print("モード: Spark会話フローテスト\n")
            test_spark_flow()
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
        elif mode == "all":
            print("モード: 全サービステスト\n")
            test_spark_flow()
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
        if mode in ["direct", "spark", "grow", "create", "memory", "all"]:
            print(f"API Server ({API_URL}) を起動してください")
            print("起動コマンド: cd backend/aiseed && python main.py")
        else:
            print(f"Gateway ({GATEWAY_URL}) を起動してください")
    except Exception as e:
        print(f"エラー: {e}")
        import traceback
        traceback.print_exc()
