#!/usr/bin/env python3
"""
AIseed API テストスクリプト

使用方法:
    python test_api.py
"""
import requests
import json

BASE_URL = "http://localhost:8000"

def test_root():
    """ルートエンドポイントのテスト"""
    print("=== ルートエンドポイント ===")
    response = requests.get(f"{BASE_URL}/")
    print(f"Status: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), indent=2, ensure_ascii=False)}\n")

def test_public_api():
    """Public API のテスト"""
    print("=== Public API (Web用) ===")
    
    # ステータス確認
    response = requests.get(f"{BASE_URL}/public/")
    print(f"Status: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), indent=2, ensure_ascii=False)}\n")
    
    # 会話テスト (Spark)
    print("--- Spark 会話テスト ---")
    payload = {
        "user_message": "こんにちは！",
        "conversation_history": []
    }
    response = requests.post(f"{BASE_URL}/public/conversation", json=payload)
    print(f"Status: {response.status_code}")
    if response.status_code == 200:
        data = response.json()
        print(f"Service: {data['service']}")
        print(f"AI Response: {data['ai_message'][:100]}...\n")
    else:
        print(f"Error: {response.text}\n")
    
    # 会話テスト (Grow)
    print("--- Grow 会話テスト ---")
    payload = {
        "user_message": "トマトの育て方を教えてください",
        "conversation_history": []
    }
    response = requests.post(f"{BASE_URL}/public/conversation", json=payload)
    print(f"Status: {response.status_code}")
    if response.status_code == 200:
        data = response.json()
        print(f"Service: {data['service']}")
        print(f"AI Response: {data['ai_message'][:100]}...\n")
    else:
        print(f"Error: {response.text}\n")

def test_authenticated_api():
    """Authenticated API のテスト"""
    print("=== Authenticated API (アプリ用) ===")
    
    # ステータス確認
    response = requests.get(f"{BASE_URL}/v1/")
    print(f"Status: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), indent=2, ensure_ascii=False)}\n")
    
    # API キーなしでアクセス（開発モード）
    print("--- Spark 会話テスト (認証なし - 開発モード) ---")
    payload = {
        "user_message": "私の強みを見つけてください",
        "conversation_history": []
    }
    response = requests.post(f"{BASE_URL}/v1/spark/conversation", json=payload)
    print(f"Status: {response.status_code}")
    if response.status_code == 200:
        data = response.json()
        print(f"Service: {data['service']}")
        print(f"AI Response: {data['ai_message'][:100]}...\n")
    else:
        print(f"Error: {response.text}\n")

def test_rate_limit():
    """レート制限のテスト"""
    print("=== レート制限テスト ===")
    print("6回連続でリクエストを送信（5回/分の制限）\n")
    
    for i in range(6):
        payload = {
            "user_message": f"テストメッセージ {i+1}",
            "conversation_history": []
        }
        response = requests.post(f"{BASE_URL}/public/conversation", json=payload)
        print(f"リクエスト {i+1}: Status {response.status_code}")
        if response.status_code == 429:
            print(f"  → レート制限に達しました: {response.json()['detail']}\n")
            break

if __name__ == "__main__":
    print("AIseed API テスト開始\n")
    print("注意: サーバーが起動している必要があります")
    print("起動コマンド: uvicorn main:app --reload\n")
    
    try:
        test_root()
        test_public_api()
        test_authenticated_api()
        test_rate_limit()
        
        print("=== テスト完了 ===")
    except requests.exceptions.ConnectionError:
        print("エラー: サーバーに接続できません")
        print("サーバーを起動してください: uvicorn main:app --reload")
    except Exception as e:
        print(f"エラー: {e}")
