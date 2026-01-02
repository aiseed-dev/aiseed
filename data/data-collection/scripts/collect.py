from config import TEMPLATES_DIR, RAW_DATA_DIR
import google.generativeai as genai
import json
import time
import os
from dotenv import load_dotenv
from datetime import datetime
from pathlib import Path

# --- 設定項目 ---
# 1. ご自身のGoogle APIキーを設定してください
load_dotenv()
a = os.getenv('GOOGLE_API_KEY')
genai.configure(api_key=os.getenv('GOOGLE_API_KEY'))

# 2. Version
VERSION = "v0.1"
TYPE = "crop"
def collect_data(name, model, prompt):
    try:
        response = model.generate_content(prompt)
        return response.text

    except Exception as e:
        print(f"⚠️ {name} の処理中にエラーが発生しました: {e}")
        return None
        # エラー情報を記録しておく


def main():

    """メインの処理を実行する関数"""
    # 保存ディレクトリーの作成
    output_raw_dir = RAW_DATA_DIR / f"{TYPE}_raw_{VERSION}"
    output_raw_dir.mkdir(parents=True, exist_ok=True)
    output_json_dir = RAW_DATA_DIR / f"{TYPE}_{VERSION}"
    output_json_dir.mkdir(parents=True, exist_ok=True)

    model = genai.GenerativeModel('gemini-2.5-pro')
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

    path = TEMPLATES_DIR / f"{TYPE}_prompt_{VERSION}.txt"
    with open(path, "r", encoding="utf-8") as f:
        prompt_template = f.read()
    path = TEMPLATES_DIR / f"{TYPE}_scheme_{VERSION}.txt"
    with open(path, "r", encoding="utf-8") as f:
        scheme = f.read()

    path = RAW_DATA_DIR / f"{TYPE}_data.csv"
    with open(path, "r", encoding="utf-8") as f:
        print("雑草情報の収集を開始します...")
        count = 0
        f.readline()
        for line in f:
            s = line.split(",")
            num = s[0]
            if TYPE == "weed":
                name = s[1]
                prefix = "w"
            else:
                name = s[4]
                prefix = "c"
            raw_path = output_raw_dir / f"{prefix}{num}.txt"
            if raw_path.exists():
                continue
            print(f"--- {name}の情報を収集中 ---")
            prompt = prompt_template.format(name=name) + scheme
            data = collect_data(name, model, prompt)
            if data:
                try:
                    with open(raw_path, "w", encoding="utf-8") as f:
                        f.write(data)
                    # AIの返信からJSON部分のみを抽出
                    # JSONとしてパース
                    # マークダウンのコードブロックを除去
                    start = data.find("```json")
                    if start != -1:
                        response_text = data[start + len("```json"):].lstrip()
                    if response_text.endswith("```"):
                        response_text = response_text.rstrip()[:-3]
                    json_data = json.loads(response_text)
                    output_json_path = output_json_dir / f"{prefix}{num}.json"
                    with open(output_json_path, "w", encoding="utf-8") as f:
                        json.dump(json_data, f, ensure_ascii=False, indent=2)
                    print(f"✔️ {name} の情報を保存しました。")
                    count += 1
                except Exception as e:
                    print(f"⚠️ {name}の情報をファイルの保存中にエラーが発生しました: {e}")
            time.sleep(5)

    print(f"\n✅ {count}件のデータが保存されました。")

if __name__ == "__main__":
    main()