from config import RAW_DATA_DIR
import json

# --- 1. weed_data.jsonファイルを読み込む ---
# 'utf-8' を指定して文字化けを防ぎます
with open(RAW_DATA_DIR / 'weed_data.json', 'r', encoding='utf-8') as f:
    data = json.load(f)
    # --- 2. 各データに新しい項目を追加する ---
    # forループでリスト内の各辞書を順番に処理します
    for item in data:
        id = item['id']
        with open(RAW_DATA_DIR / "weed_v0.1" / f'w{id}.json', 'r', encoding='utf-8') as f:
            weed_data = json.load(f)
            item['scientific_name'] = weed_data['scientific_name']
            item['family_name'] = weed_data['family_jp']

    # --- 3. weed_data_new.jsonに結果を保存する ---
    # 'w' は書き込みモードを意味します
    with open(RAW_DATA_DIR / 'weed_data_new.json', 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print("項目を追加し、'weed_data_new.json' に保存しました。")