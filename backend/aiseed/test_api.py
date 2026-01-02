#!/usr/bin/env python3
"""
AIseed API テストスクリプト

使用方法:
    # Gateway経由でテスト
    python test_api.py

    # API直接テスト
    python test_api.py --direct
"""
import requests
import json
import sys

# テスト対象
GATEWAY_URL = "http://localhost:8000"
API_URL = "http://localhost:8001"

def test_gateway():
    """Gateway経由のテスト"""
    print("=== Gateway テスト ===\n")

    # ルート
    print("--- ルートエンドポイント ---")
    response = requests.get(f"{GATEWAY_URL}/")
    print(f"Status: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), indent=2, ensure_ascii=False)}\n")

    # ヘルスチェック
    print("--- ヘルスチェック ---")
    response = requests.get(f"{GATEWAY_URL}/health")
    print(f"Status: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), indent=2, ensure_ascii=False)}\n")

    # APIキー作成
    print("--- APIキー作成 ---")
    payload = {"user_id": "test_user", "plan": "free"}
    response = requests.post(f"{GATEWAY_URL}/admin/api-keys", json=payload)
    print(f"Status: {response.status_code}")
    if response.status_code == 200:
        data = response.json()
        print(f"API Key: {data['api_key'][:20]}...")
        api_key = data['api_key']
    else:
        print(f"Error: {response.text}")
        api_key = None
    print()

    # 統計情報
    print("--- 統計情報 ---")
    response = requests.get(f"{GATEWAY_URL}/admin/stats")
    print(f"Status: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), indent=2, ensure_ascii=False)}\n")

    # Public API
    print("--- Public API 会話テスト ---")
    payload = {"user_message": "こんにちは！", "conversation_history": []}
    response = requests.post(f"{GATEWAY_URL}/public/conversation", json=payload)
    print(f"Status: {response.status_code}")
    if response.status_code == 200:
        data = response.json()
        print(f"Service: {data['service']}")
        print(f"AI Response: {data['ai_message'][:100]}...\n")
    else:
        print(f"Error: {response.text}\n")

    # v1 API（認証）
    if api_key:
        print("--- v1 API 会話テスト (認証あり) ---")
        headers = {"X-API-Key": api_key}
        payload = {"user_message": "Pythonでループの書き方を教えて", "conversation_history": []}
        response = requests.post(
            f"{GATEWAY_URL}/v1/learn/conversation",
            json=payload,
            headers=headers
        )
        print(f"Status: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"Service: {data['service']}")
            print(f"AI Response: {data['ai_message'][:100]}...\n")
        else:
            print(f"Error: {response.text}\n")


def test_api_direct():
    """API直接テスト"""
    print("=== API直接テスト ===\n")

    # ヘルスチェック
    print("--- ヘルスチェック ---")
    response = requests.get(f"{API_URL}/health")
    print(f"Status: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), indent=2, ensure_ascii=False)}\n")

    # Spark
    print("--- Spark 会話テスト ---")
    payload = {"user_message": "私の強みを見つけてください", "conversation_history": []}
    response = requests.post(f"{API_URL}/internal/spark/conversation", json=payload)
    print(f"Status: {response.status_code}")
    if response.status_code == 200:
        data = response.json()
        print(f"Service: {data['service']}")
        print(f"AI Response: {data['ai_message'][:100]}...\n")
    else:
        print(f"Error: {response.text}\n")


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


if __name__ == "__main__":
    print("AIseed API テスト\n")

    direct_mode = "--direct" in sys.argv

    try:
        if direct_mode:
            print("モード: API直接テスト\n")
            test_api_direct()
        else:
            print("モード: Gateway経由テスト\n")
            print("注意: Gateway と API の両方が起動している必要があります")
            print("起動: docker-compose up -d\n")
            test_gateway()
            test_rate_limit()

        print("=== テスト完了 ===")
    except requests.exceptions.ConnectionError as e:
        print(f"エラー: サーバーに接続できません")
        if direct_mode:
            print(f"API Server ({API_URL}) を起動してください")
        else:
            print(f"docker-compose up -d を実行してください")
    except Exception as e:
        print(f"エラー: {e}")
